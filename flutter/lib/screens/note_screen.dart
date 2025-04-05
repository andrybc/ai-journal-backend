import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/journal_service.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({
    super.key,
    required this.title,
    required this.content,
    this.notebookId,
  });

  final String title;
  final String content;
  final String?
  notebookId; // Added notebookId to support editing existing notebooks

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  bool _isEditMode = false;
  bool _isSaving = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  late final TextEditingController _editingController;
  late final TextEditingController _titleController;
  String? _authToken;
  String? _userId;

  // Custom extension set with emoji support
  final _markdownExtensionSet = md.ExtensionSet(
    md.ExtensionSet.gitHubFlavored.blockSyntaxes,
    <md.InlineSyntax>[
      md.EmojiSyntax(),
      ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
    ],
  );

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the journal entry content
    _editingController = TextEditingController(text: widget.content);
    _titleController = TextEditingController(text: widget.title);
    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getString('user_id');

      setState(() {
        _authToken = token;
        _userId = userId;
      });

      if (token == null) {
        setState(() {
          _errorMessage = 'Authentication token not found';
        });
      }

      if (userId == null) {
        setState(() {
          _errorMessage = 'User ID not found';
        });
      }

      // If this is an existing notebook, fetch its content
      if (widget.notebookId != null && token != null) {
        _fetchNotebookContent(widget.notebookId!, token);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load authentication: $e';
      });
    }
  }

  Future<void> _fetchNotebookContent(String notebookId, String token) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await JournalService.readNotebook(notebookId, token);

      if (response['success']) {
        final data = response['data'];

        // Extract notebook content based on the actual structure
        if (data is Map<String, dynamic> && data.containsKey('notebook')) {
          final notebook = data['notebook'];
          if (notebook is Map<String, dynamic>) {
            // Update content and title from notebook data
            setState(() {
              _editingController.text = notebook['content']?.toString() ?? '';
              _titleController.text =
                  notebook['title']?.toString() ?? widget.title;
            });
          }
        } else {
          setState(() {
            _errorMessage = 'Unexpected notebook data format';
          });
        }
      } else {
        setState(() {
          _errorMessage = response['error'] ?? 'Failed to fetch notebook';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveNotebook() async {
    if (_authToken == null) {
      setState(() {
        _errorMessage = 'Not authenticated';
      });
      return;
    }

    if (_userId == null) {
      setState(() {
        _errorMessage = 'User ID not available';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final notebookData = {
        'title': _titleController.text,
        'content': _editingController.text,
        'userId': _userId, // Include userId in the request
      };

      Map<String, dynamic> response;
      if (widget.notebookId != null) {
        // Update existing notebook
        response = await JournalService.updateNotebook(
          widget.notebookId!,
          notebookData,
          _authToken!,
        );
      } else {
        // Create new notebook
        response = await JournalService.createNotebook(
          notebookData,
          _authToken!,
        );
      }

      setState(() {
        _isSaving = false;
        if (response['success']) {
          _successMessage = 'Notebook saved successfully';
          _isEditMode = false;
        } else {
          _errorMessage = response['error'] ?? 'Failed to save notebook';
        }
      });
    } catch (e) {
      setState(() {
        _isSaving = false;
        _errorMessage = 'Network error: $e';
      });
    }
  }

  @override
  void dispose() {
    _editingController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title:
            _isEditMode
                ? TextField(
                  controller: _titleController,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: 'Enter title',
                    border: InputBorder.none,
                  ),
                )
                : Text(_titleController.text),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _saveNotebook,
            icon:
                _isSaving
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (_successMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  _successMessage!,
                  style: const TextStyle(color: Colors.green),
                ),
              ),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _isEditMode
                      ? TextField(
                        controller: _editingController,
                        maxLines: null,
                        expands: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Edit your markdown here',
                        ),
                      )
                      : Markdown(
                        data: _editingController.text,
                        selectable: true,
                        extensionSet: _markdownExtensionSet,
                        onTapText: () {
                          try {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Text tapped')),
                            );
                          } catch (e) {
                            // Handle the error, e.g., show an error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          }
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isEditMode = !_isEditMode;
            // Clear messages when toggling edit mode
            _errorMessage = null;
            _successMessage = null;
          });
        },
        tooltip: _isEditMode ? 'View' : 'Edit',
        child: Icon(_isEditMode ? Icons.visibility : Icons.edit),
      ),
    );
  }
}
