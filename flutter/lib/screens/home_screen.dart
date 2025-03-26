import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample entries (replace with real data later)
    final List<Map<String, String>> journalEntries = [
      {
        "title": "A Day in Tokyo",
        "preview": "Explored Shibuya and found the coziest ramen spot..."
      },
      {
        "title": "Thoughts on Creativity",
        "preview":
            "Today I reflected on the role of solitude in creative work..."
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Journal Organizer"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: journalEntries.isEmpty
            ? const Center(
                child: Text(
                  "No journal entries yet.\nStart writing!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.separated(
                itemCount: journalEntries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final entry = journalEntries[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: ListTile(
                      title: Text(entry['title']!,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        entry['preview']!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        // TODO: Navigate to full entry view
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create journal screen
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
        tooltip: "New Entry",
      ),
    );
  }
}
