import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../styles/index.dart';

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
  bool showPassword = false;

  void handleSignup() async {
    setState(() {
      isSubmitted = true;
      errorMessage = null;
      successMessage = null;
    });

    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    List<String> errors = [];

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

    debugPrint("Email: $email, Username: $username, Password: $password");
    final response = await AuthService.signup(username, email, password);

    if (!response['success']) {
      setState(() {
        errorMessage = response['error'];
      });
      return;
    }

    setState(() {
      successMessage =
          "Signup successful! Please check your email to verify your account.";
      errorMessage = null;
    });

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    Navigator.pushNamed(context, '/email-verification');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Journal Organizer",
                    style: AppTextStyle.h1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),

                  // Error message
                  if (errorMessage != null)
                    AppUI.messageCard(
                      context: context,
                      message: errorMessage,
                      isError: true,
                    ),

                  // Success message
                  if (successMessage != null)
                    AppUI.messageCard(
                      context: context,
                      message: successMessage,
                      isError: false,
                    ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText:
                          isSubmitted &&
                                  !RegExp(
                                    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                  ).hasMatch(emailController.text.trim())
                              ? 'Please enter a valid email address'
                              : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.person),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText:
                          isSubmitted && usernameController.text.isEmpty
                              ? 'Username cannot be empty'
                              : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: passwordController,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                      errorText:
                          isSubmitted && passwordController.text.isEmpty
                              ? 'Password cannot be empty'
                              : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText:
                          isSubmitted &&
                                  confirmPasswordController.text !=
                                      passwordController.text
                              ? 'Passwords do not match'
                              : null,
                    ),
                  ),
                  const SizedBox(height: 32),

                  FilledButton(
                    onPressed: handleSignup,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Register"),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: AppTextStyle.bodySmall,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Login"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
