import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Updated import to use AuthService specifically

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String token;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final codeController = TextEditingController();
  String? error;
  bool success = false;

  void verifyCode() async {
    if (codeController.text.trim() != widget.token) {
      setState(() => error = "Invalid verification code.");
      return;
    }

    try {
      final response = await AuthService.verifyEmail(widget.token);

      if (response['success']) {
        setState(() {
          success = true;
          error = null;
        });
      } else {
        setState(() => error = "Verification failed: ${response['error']}");
      }
    } catch (e) {
      setState(() => error = "Network error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Verify Your Email", style: TextStyle(fontSize: 22)),
            const SizedBox(height: 12),
            Text("A verification email has been sent to ${widget.email}"),
            const SizedBox(height: 20),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Enter Verification Code',
              ),
            ),
            const SizedBox(height: 10),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            if (success)
              const Text(
                "Email verified successfully!",
                style: TextStyle(color: Colors.green),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: verifyCode,
              child: const Text("Verify Email"),
            ),
          ],
        ),
      ),
    );
  }
}
