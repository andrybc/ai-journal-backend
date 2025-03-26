import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? errorMessage;
  String? successMessage;

  bool isSubmitted = false;

  void handleSignup() async {
    setState(() {
      isSubmitted = true;
      errorMessage = null;
      successMessage = null;
    });

    List<String> errors = [];

    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      errors.add("Please fill in all fields");
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      errors.add("Please enter a valid email address");
    }

    if (password != confirmPassword) {
      errors.add("Passwords do not match");
    }

    if (errors.isNotEmpty) {
      setState(() => errorMessage = errors.join("\n"));
      return;
    }

    final response = await ApiService.signup(username, email, password);

    if (response['success']) {
      final token = response['token'];
      print("Verification token: $token");
      setState(() {
        successMessage = "Signup successful! Please verify your email.";
        errorMessage = null;
      });
    } else {
      setState(() {
        errorMessage = response['error'];
        successMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            const Text("Journal Organizer",
                style: TextStyle(fontSize: 28), textAlign: TextAlign.center),
            const SizedBox(height: 30),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: isSubmitted && emailController.text.isEmpty
                    ? 'Email required'
                    : null,
              ),
            ),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                errorText: isSubmitted && usernameController.text.isEmpty
                    ? 'Username required'
                    : null,
              ),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: isSubmitted && passwordController.text.isEmpty
                    ? 'Password required'
                    : null,
              ),
            ),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                errorText: isSubmitted && confirmPasswordController.text.isEmpty
                    ? 'Confirmation required'
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            if (successMessage != null)
              Text(successMessage!,
                  style: const TextStyle(color: Colors.green)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleSignup,
              child: const Text("Register"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Navigate back to login screen
              },
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
