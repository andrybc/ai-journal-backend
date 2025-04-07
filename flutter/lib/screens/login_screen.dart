import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'signup_screen.dart';
import '../services/auth_service.dart'; // Updated import to use AuthService specifically
import 'note_screen.dart'; // Import your home screen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool showPassword = false;
  String? error;
  bool isLoading = false;
  bool isSubmitted = false;

  // Check for existing auth token and redirect if found
  Future<void> checkExistingLogin() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null && token.isNotEmpty) {
        print('Found existing auth token, redirecting to home');

        // Small delay for better UX
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NoteScreen()),
        );
      }
    } catch (e) {
      print('Error checking existing login: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Check if user is already logged in
    checkExistingLogin();
  }

  void handleLogin() async {
    setState(() {
      isSubmitted = true;
      error = null;
      isLoading = true;
    });

    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        error = 'Please fill in all fields';
        isLoading = false;
      });
      return;
    }

    final response = await AuthService.login(username, password);

    setState(() => isLoading = false);

    if (!response['success']) {
      setState(() {
        error = response['error'] ?? 'Login failed.';
      });
      return;
    }

    // Save authentication data to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = response['data'];

      // Get the token - this is present in the response
      final token = userData['token'];

      if (token != null) {
        // Save the auth token
        await prefs.setString('auth_token', token);

        // Extract user ID from the JWT token
        String userId = _extractUserIdFromToken(token);

        // Save the extracted user ID
        await prefs.setString('user_id', userId);

        print('Auth data saved successfully: Token and extracted userId');
      } else {
        print('Warning: Missing token in login response');
        print('Response data structure: ${userData.keys.toList()}');
      }
    } catch (e) {
      print('Error saving auth data: $e');
      // Continue anyway since we have the data in memory for this session
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const NoteScreen()),
    );
  }

  // Helper method to extract user ID from JWT token
  String _extractUserIdFromToken(String token) {
    try {
      // JWT format: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) {
        print('Invalid JWT token format');
        return 'unknown_user';
      }

      // Decode the payload (middle part)
      String payload = parts[1];
      // Add padding if needed
      while (payload.length % 4 != 0) {
        payload += '=';
      }

      // Base64 decode and convert to JSON
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> decodedData = json.decode(decoded);

      // Extract user ID - JWT tokens typically have user ID as 'id', 'sub', or 'user_id'
      final userId =
          decodedData['id'] ??
          decodedData['sub'] ??
          decodedData['userId'] ??
          'unknown_user';
      print('Extracted user ID from token: $userId');
      return userId.toString();
    } catch (e) {
      print('Error extracting user ID from token: $e');
      return 'unknown_user';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Journal Organizer",
                  style: TextStyle(fontSize: 28, color: Colors.white),
                ),
                const SizedBox(height: 30),
                if (error != null)
                  Text(error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
                TextField(
                  controller: usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Username or Email',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.grey[850],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    errorText:
                        isSubmitted && usernameController.text.trim().isEmpty
                            ? 'Please enter your username or email'
                            : null,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: !showPassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.grey[850],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                    ),
                    errorText:
                        isSubmitted && passwordController.text.isEmpty
                            ? 'Please enter your password'
                            : null,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Forgot password functionality will be implemented soon',
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isSubmitted = true;
                        });
                        handleLogin();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                      ),
                      child: const Text("Login"),
                    ),
                TextButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      ),
                  child: const Text(
                    "Don't have an account? Sign up",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
