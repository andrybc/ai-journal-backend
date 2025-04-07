import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/journal_service.dart';
import '../components/sidenav.dart';
import '../screens/profile_screen.dart';

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

          // Show a snackbar for better feedback
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

    // Show confirmation dialog
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
      _isSaving = true; // Reuse the loading state
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await JournalService.deleteNotebook(
        widget.notebookId!,
        _authToken!,
      );

      if (response['success']) {
        // Show temporary success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notebook deleted successfully'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate back to previous screen
        if (mounted) {
          Navigator.of(
            context,
          ).pop(true); // Pop with result to refresh previous screen
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

  // Notebook-specific search function
  Future<Map<String, dynamic>> _searchNotebooks(
    String query,
    String token,
    String userId,
  ) async {
    return JournalService.searchNotebooks(query, token, userId);
  }

  // Notebook-specific title extractor
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    letterSpacing: 1.05,
                    height: 1.75 / 1.125,
                    fontFamily: "Montserrat",
                    fontFamilyFallback: ["sans-serif"],
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Enter title',
                    border: InputBorder.none,
                  ),
                )
                : Text(
                  _noNoteSelected ? 'No Note Selected' : _titleController.text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    letterSpacing: 1.05,
                    height: 1.75 / 1.125,
                    fontFamily: "Montserrat",
                    fontFamilyFallback: ["sans-serif"],
                  ),
                ),
        actions: [
          // Delete button
          if (widget.notebookId !=
              null) // Only show delete for existing notebooks
            IconButton(
              onPressed: _isSaving ? null : _deleteNotebook,
              icon:
                  _isSaving
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.delete),
              tooltip: 'Delete notebook',
            ),
          // Save button
          if (!_noNoteSelected)
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
          // Already on notes page, just close drawer
          Navigator.pop(context);
        },
        onPeoplePageSelected: () {
          // Navigate to relationship page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RelationshipPage()),
          );
        },
        onItemTap: (context, noteId) {
          // Navigate to selected note
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
              ? Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/icons/ghost-icon.svg",
                      semanticsLabel: "No notes available",
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                      width: 75,
                      height: 75,
                      placeholderBuilder:
                          (context) => Container(
                            padding: const EdgeInsets.all(15),
                            child: const CircularProgressIndicator(),
                          ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "No Note Selected",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                        height: 1.3333,
                        fontFamily: "Montserrat",
                        fontFamilyFallback: const ["sans-serif"],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Select a note from the sidebar or create a new one',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 30),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          _noNoteSelected = false;
                          _isEditMode = true;
                          _titleController.text = 'New Note';
                          _editingController.text = '';
                          // Focus on title after creating new note
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            FocusScope.of(
                              context,
                            ).requestFocus(_titleFocusNode);
                          });
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Create New Note"),
                    ),
                  ],
                ),
              )
              : SafeArea(
                child: Column(
                  children: [
                    // Message area for success/error
                    if (_errorMessage != null || _successMessage != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(8),
                        child: Card(
                          color:
                              _errorMessage != null
                                  ? colorScheme.errorContainer
                                  : colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              _errorMessage ?? _successMessage ?? '',
                              style: TextStyle(
                                color:
                                    _errorMessage != null
                                        ? colorScheme.onErrorContainer
                                        : colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Main content
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
                                              style: const TextStyle(
                                                fontSize: 18,
                                                height: 1.6,
                                              ),
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                hintText:
                                                    'Edit your markdown here',
                                                contentPadding:
                                                    const EdgeInsets.all(16),
                                              ),
                                            )
                                            : MarkdownBody(
                                              data: _editingController.text,
                                              selectable: true,
                                              styleSheet: MarkdownStyleSheet(
                                                p: const TextStyle(
                                                  fontSize: 18,
                                                  height: 1.6,
                                                ),
                                                h1: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 32,
                                                  height: 1.2,
                                                  fontFamily: "Montserrat",
                                                  fontFamilyFallback: [
                                                    "sans-serif",
                                                  ],
                                                ),
                                                h2: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 28,
                                                  height: 1.3,
                                                  fontFamily: "Montserrat",
                                                  fontFamilyFallback: [
                                                    "sans-serif",
                                                  ],
                                                ),
                                                h3: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 24,
                                                  height: 1.3,
                                                  fontFamily: "Montserrat",
                                                  fontFamilyFallback: [
                                                    "sans-serif",
                                                  ],
                                                ),
                                                blockquote: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color:
                                                      colorScheme
                                                          .onSurfaceVariant,
                                                ),
                                                code: TextStyle(
                                                  backgroundColor:
                                                      colorScheme
                                                          .surfaceContainerHighest,
                                                  color: colorScheme.primary,
                                                  fontFamily: 'monospace',
                                                ),
                                                codeblockDecoration: BoxDecoration(
                                                  color:
                                                      colorScheme
                                                          .surfaceContainerHighest,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              extensionSet:
                                                  _markdownExtensionSet,
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
              // Clear messages when toggling edit mode
              _errorMessage = null;
              _successMessage = null;
            }

            // Request focus on the appropriate field when entering edit mode
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
      // Add floating action button position for better usability
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
