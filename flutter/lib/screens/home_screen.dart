import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'note_screen.dart';
import '../services/journal_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> notebooks = [];
  bool isLoading = true;
  String? errorMessage;
  String? userId;
  String? authToken;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final id = prefs.getString('user_id');

      if (token != null && id != null) {
        setState(() {
          authToken = token;
          userId = id;
        });
        _fetchNotebooks(id, token);
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Please log in again';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading user data: $e';
      });
    }
  }

  Future<void> _fetchNotebooks(String userId, String token) async {
    try {
      final response = await JournalService.getAllNotebooks(userId, token);

      if (response['success']) {
        setState(() {
          notebooks = List<Map<String, dynamic>>.from(response['data']);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response['error'] ?? 'Failed to fetch notebooks';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Journal Organizer"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
                : notebooks.isEmpty
                ? const Center(
                  child: Text(
                    "No journal entries yet.\nStart writing!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
                : ListView.separated(
                  itemCount: notebooks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final notebook = notebooks[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: ListTile(
                        title: Text(
                          notebook['title'] ?? 'Untitled',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          notebook['previewText'] ?? 'No preview available',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => NoteScreen(
                                    title: notebook['title'] ?? 'Untitled',
                                    content: notebook['content'] ?? '',
                                    notebookId:
                                        notebook['id'], // Pass the notebook ID
                                  ),
                            ),
                          ).then((_) {
                            // Refresh notebooks when returning from the note screen
                            if (userId != null && authToken != null) {
                              _fetchNotebooks(userId!, authToken!);
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => const NoteScreen(
                    title: 'New Entry',
                    content: '',
                    // No notebookId means we're creating a new notebook
                  ),
            ),
          ).then((_) {
            // Refresh notebooks when returning from creating a new entry
            if (userId != null && authToken != null) {
              _fetchNotebooks(userId!, authToken!);
            }
          });
        },
        backgroundColor: Colors.deepPurple,
        tooltip: "New Entry",
        child: const Icon(Icons.add),
      ),
    );
  }
}
