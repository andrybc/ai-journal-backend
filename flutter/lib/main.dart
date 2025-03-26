import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // or home_screen.dart depending on entry

void main() {
  runApp(const JournalApp());
}

class JournalApp extends StatelessWidget {
  const JournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Journal Organizer',
      theme: ThemeData.dark(),
      home: const LoginScreen(), // Set your actual starting screen
    );
  }
}
