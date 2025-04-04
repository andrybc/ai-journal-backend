import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'api_base.dart';

/// Service responsible for authentication related API calls
class AuthService {
  /// Log in a user with email/username and password
  static Future<Map<String, dynamic>> login(
    String emailOrUsername,
    String password,
  ) async {
    final url = Uri.parse('${ApiBase.baseUrl}/auth/login');
    final response = await http.post(
      url,
      headers: ApiBase.getHeaders(null),
      body: jsonEncode({
        "email": emailOrUsername, // Can be email or username
        "username": emailOrUsername,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return {"success": true, "data": jsonDecode(response.body)};
    } else {
      return {
        "success": false,
        "error": jsonDecode(response.body)['error'] ?? "Login failed",
      };
    }
  }

  /// Register a new user
  static Future<Map<String, dynamic>> signup(
    String username,
    String email,
    String password,
  ) async {
    final url = Uri.parse('${ApiBase.baseUrl}/auth/register');
    debugPrint('URL: $url');

    final response = await http.post(
      url,
      headers: ApiBase.getHeaders(null),
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'token': data['verificationToken'],
        'message': data['message'],
      };
    } else {
      return {
        'success': false,
        'error': jsonDecode(response.body)['error'] ?? 'Unknown error',
      };
    }
  }

  /// Verify user email with token
  static Future<Map<String, dynamic>> verifyEmail(String token) async {
    final response = await http.get(
      Uri.parse('${ApiBase.baseUrl}/auth/verify-email?token=$token'),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'message': jsonDecode(response.body)['message']};
    } else {
      return {
        'success': false,
        'error': jsonDecode(response.body)['error'] ?? 'Verification failed',
      };
    }
  }

  /// Initiate password reset process
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = Uri.parse('${ApiBase.baseUrl}/auth/forgot-password');
    final response = await http.post(
      url,
      headers: ApiBase.getHeaders(null),
      body: jsonEncode({'email': email}),
    );

    return ApiBase.handleResponse(
      response,
      errorMessage: 'Failed to process password reset request',
    );
  }

  /// Reset password using token
  static Future<Map<String, dynamic>> resetPassword(
    String token,
    String newPassword,
  ) async {
    final url = Uri.parse('${ApiBase.baseUrl}/auth/reset-password');
    final response = await http.post(
      url,
      headers: ApiBase.getHeaders(null),
      body: jsonEncode({'token': token, 'password': newPassword}),
    );

    return ApiBase.handleResponse(
      response,
      errorMessage: 'Password reset failed',
    );
  }
}
