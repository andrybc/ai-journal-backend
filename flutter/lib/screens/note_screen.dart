import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/journal_service.dart';
import '../components/sidenav.dart';
import '../screens/profile_screen.dart';
import '../styles/index.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({
    super.key,
    this.title = '',
    this.content = '',
    this.notebookId,
  });

  final String title;
  final String content;
  final String? notebookId;

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
  bool _noNoteSelected = false;
  final FocusNode _contentFocusNode = FocusNode();
  final FocusNode _titleFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController(text: widget.content);
    _titleController = TextEditingController(text: widget.title);
    _noNoteSelected =
        widget.notebookId == null &&
        widget.title.isEmpty &&
        widget.content.isEmpty;
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

        if (data is Map<String, dynamic> && data.containsKey('notebook')) {
          final notebook = data['notebook'];
          if (notebook is Map<String, dynamic>) {
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
        'userId': _userId,
      };

      Map<String, dynamic> response;
      if (widget.notebookId != null) {
        response = await JournalService.updateNotebook(
          widget.notebookId!,
          notebookData,
          _authToken!,
        );
      } else {
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

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Notebook saved successfully'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green.shade700,
              duration: const Duration(seconds: 2),
            ),
          );
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

  Future<void> _deleteNotebook() async {
    if (_authToken == null) {
      setState(() {
        _errorMessage = 'Not authenticated';
      });
      return;
    }

    if (widget.notebookId == null) {
      setState(() {
        _errorMessage = 'Cannot delete an unsaved notebook';
      });
      return;
    }

    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
            'Are you sure you want to delete this notebook? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete != true) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await JournalService.deleteNotebook(
        widget.notebookId!,
        _authToken!,
      );

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notebook deleted successfully'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        setState(() {
          _isSaving = false;
          _errorMessage = response['error'] ?? 'Failed to delete notebook';
        });
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
        _errorMessage = 'Network error: $e';
      });
    }
  }

  void _loadNotebook(String notebookId) {
    if (_authToken != null) {
      _fetchNotebookContent(notebookId, _authToken!);
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<Map<String, dynamic>> _searchNotebooks(
    String query,
    String token,
    String userId,
  ) async {
    return JournalService.searchNotebooks(query, token, userId);
  }

  String _extractNotebookTitle(Map<String, dynamic> notebook) {
    return notebook["title"] ?? "Untitled";
  }

  @override
  void dispose() {
    _editingController.dispose();
    _titleController.dispose();
    _contentFocusNode.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      drawerScrimColor: Colors.black.withOpacity(0.75),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width * 0.2,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
        toolbarHeight: 53.5,
        title:
            _isEditMode
                ? TextField(
                  controller: _titleController,
                  focusNode: _titleFocusNode,
                  style: AppTextStyle.appBarTitle,
                  decoration: const InputDecoration(
                    hintText: 'Enter title',
                    border: InputBorder.none,
                  ),
                )
                : Text(
                  _noNoteSelected ? 'No Note Selected' : _titleController.text,
                  style: AppTextStyle.appBarTitle,
                ),
        actions: [
          if (widget.notebookId != null)
            IconButton(
              onPressed: _isSaving ? null : _deleteNotebook,
              icon:
                  _isSaving
                      ? AppUI.loadingIndicator()
                      : const Icon(Icons.delete),
              tooltip: 'Delete notebook',
            ),
          if (!_noNoteSelected)
            IconButton(
              onPressed: _isSaving ? null : _saveNotebook,
              icon:
                  _isSaving ? AppUI.loadingIndicator() : const Icon(Icons.save),
              tooltip: 'Save notebook',
            ),
        ],
      ),
      drawer: SideNav(
        userId: _userId,
        selectedItemId: widget.notebookId,
        token: _authToken,
        showSnackBar: _showSnackBar,
        searchFunction: _searchNotebooks,
        titleExtractor: _extractNotebookTitle,
        searchPlaceholder: "Search Notebooks",
        dataKey: "notebooks",
        onItemSelected: _loadNotebook,
        isNotesActive: true,
        isPeopleActive: false,
        onNotesPageSelected: () {
          Navigator.pop(context);
        },
        onPeoplePageSelected: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RelationshipPage()),
          );
        },
        onItemTap: (context, noteId) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NoteScreen(notebookId: noteId),
            ),
          );
        },
      ),
      body:
          _noNoteSelected
              ? AppUI.emptyState(
                icon: "assets/icons/ghost-icon.svg",
                title: "No Note Selected",
                subtitle: 'Select a note from the sidebar or create a new one',
                onActionPressed: () {
                  setState(() {
                    _noNoteSelected = false;
                    _isEditMode = true;
                    _titleController.text = 'New Note';
                    _editingController.text = '';
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      FocusScope.of(context).requestFocus(_titleFocusNode);
                    });
                  });
                },
                actionText: "Create New Note",
              )
              : SafeArea(
                child: Column(
                  children: [
                    AppUI.messageCard(
                      context: context,
                      message: _errorMessage ?? _successMessage,
                      isError: _errorMessage != null,
                    ),
                    Expanded(
                      child:
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : SingleChildScrollView(
                                child: Center(
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 900,
                                    ),
                                    alignment: Alignment.topLeft,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 32,
                                    ),
                                    child:
                                        _isEditMode
                                            ? TextField(
                                              controller: _editingController,
                                              focusNode: _contentFocusNode,
                                              maxLines: null,
                                              style: AppTextStyle.body,
                                              decoration:
                                                  AppMarkdownStyle.editorDecoration(),
                                            )
                                            : MarkdownBody(
                                              data: _editingController.text,
                                              selectable: true,
                                              styleSheet:
                                                  AppMarkdownStyle.markdownStyleSheet(
                                                    colorScheme,
                                                  ),
                                              extensionSet:
                                                  AppMarkdownStyle.extensionSet,
                                            ),
                                  ),
                                ),
                              ),
                    ),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_noNoteSelected) {
              _noNoteSelected = false;
              _isEditMode = true;
              _titleController.text = 'New Note';
              _editingController.text = '';
            } else {
              _isEditMode = !_isEditMode;
              _errorMessage = null;
              _successMessage = null;
            }

            if (_isEditMode) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                FocusScope.of(context).requestFocus(_contentFocusNode);
              });
            }
          });
        },
        tooltip:
            _noNoteSelected
                ? 'Create New Note'
                : (_isEditMode ? 'View' : 'Edit'),
        child: Icon(
          _noNoteSelected
              ? Icons.add
              : (_isEditMode ? Icons.visibility : Icons.edit),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
