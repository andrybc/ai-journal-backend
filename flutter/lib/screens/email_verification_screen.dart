import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../styles/index.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Verify Email", style: AppTextStyle.appBarTitle),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Verify Your Email",
                  style: AppTextStyle.h2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                Text(
                  "A verification email has been sent to ${widget.email}",
                  style: AppTextStyle.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                TextField(
                  controller: codeController,
                  decoration: InputDecoration(
                    labelText: 'Enter Verification Code',
                    prefixIcon: const Icon(Icons.key),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                if (error != null || success)
                  AppUI.messageCard(
                    context: context,
                    message: success ? "Email verified successfully!" : error,
                    isError: !success,
                  ),

                const SizedBox(height: 32),

                FilledButton(
                  onPressed: verifyCode,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Verify Email"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
