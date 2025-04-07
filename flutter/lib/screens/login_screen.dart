import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'signup_screen.dart';
import '../services/auth_service.dart';
import 'note_screen.dart';
import '../styles/index.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _showPassword = false;
  String? _error;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // Check for existing auth token and redirect if found
  Future<void> checkExistingLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null && token.isNotEmpty) {
        // Small delay for better UX
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NoteScreen()),
        );
      }
    } catch (e) {
      debugPrint('Error checking existing login: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
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

  Future<void> handleLogin() async {
    // Clear any previous errors
    setState(() {
      _error = null;
    });

    // Validate form
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    try {
      final response = await AuthService.login(username, password);

      if (!response['success']) {
        setState(() {
          _error =
              response['error'] ?? 'Login failed. Please check your credentials.';
          _isLoading = false;
        });
        return;
      }

      // Save authentication data to SharedPreferences
      await _saveAuthData(response);

      if (!mounted) return;

      // Show success feedback before navigating
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Login successful!'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NoteScreen()),
      );
    } catch (e) {
      setState(() {
        _error = 'Network error: Unable to connect to the server';
        _isLoading = false;
      });
      debugPrint('Error during login: $e');
    }
  }

  Future<void> _saveAuthData(Map<String, dynamic> response) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = response['data'];
      final token = userData['token'];

      if (token != null) {
        // Save the auth token
        await prefs.setString('auth_token', token);

        // Extract user ID from the JWT token
        String userId = _extractUserIdFromToken(token);

        // Save the extracted user ID
        await prefs.setString('user_id', userId);
      } else {
        debugPrint('Warning: Missing token in login response');
      }
    } catch (e) {
      debugPrint('Error saving auth data: $e');
      // Continue anyway since we have the data in memory for this session
    }
  }

  // Helper method to extract user ID from JWT token
  String _extractUserIdFromToken(String token) {
    try {
      // JWT format: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) {
        debugPrint('Invalid JWT token format');
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
          decodedData['id'] ?? decodedData['sub'] ?? decodedData['userId'] ?? 'unknown_user';

      return userId.toString();
    } catch (e) {
      debugPrint('Error extracting user ID from token: $e');
      return 'unknown_user';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: AutofillGroup(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // App title with modern typography
                        Text(
                          "Journal Organizer",
                          style: AppTextStyle.h1,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 36),

                        // Error message
                        if (_error != null)
                          AppUI.messageCard(
                            context: context,
                            message: _error,
                            isError: true,
                          ),

                        // Username field with improved styling and validation
                        TextFormField(
                          controller: _usernameController,
                          focusNode: _usernameFocusNode,
                          decoration: InputDecoration(
                            labelText: 'Username or Email',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                          ),
                          textInputAction: TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.username,
                            AutofillHints.email,
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your username or email';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_passwordFocusNode);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password field with improved styling and visibility toggle
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          obscureText: !_showPassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword ? Icons.visibility : Icons.visibility_off,
                                semanticLabel: _showPassword ? 'Hide password' : 'Show password',
                              ),
                              onPressed: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) {
                            handleLogin();
                          },
                        ),

                        // Forgot password button
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              AppUI.showSnackBar(
                                context,
                                'Forgot password functionality will be implemented soon',
                              );
                            },
                            child: const Text("Forgot Password?"),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Login button with loading state
                        FilledButton(
                          onPressed: _isLoading ? null : handleLogin,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? AppUI.loadingIndicator()
                              : const Text("Login"),
                        ),
                        const SizedBox(height: 20),

                        // Sign up button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: AppTextStyle.bodySmall,
                            ),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignupScreen(),
                                ),
                              ),
                              child: const Text("Sign up"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
