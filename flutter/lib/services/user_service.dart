import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_base.dart';

/// Service responsible for user-related API calls
class UserService {
  /// Create a new user
  static Future<Map<String, dynamic>> createUser(
    Map<String, dynamic> userData,
    String token,
  ) async {
    final url = Uri.parse('${ApiBase.baseUrl}/users');
    final response = await http.post(
      url,
      headers: ApiBase.getHeaders(token),
      body: jsonEncode(userData),
    );

    return ApiBase.handleResponse(
      response,
      errorMessage: 'Failed to create user',
    );
  }

  /// Get all users
  static Future<Map<String, dynamic>> getAllUsers(String token) async {
    final url = Uri.parse('${ApiBase.baseUrl}/users');
    final response = await http.get(url, headers: ApiBase.getHeaders(token));

    return ApiBase.handleResponse(
      response,
      errorMessage: 'Failed to get users',
    );
  }

  /// Get a user by ID
  static Future<Map<String, dynamic>> getUserById(
    String userId,
    String token,
  ) async {
    final url = Uri.parse('${ApiBase.baseUrl}/users/$userId');
    final response = await http.get(url, headers: ApiBase.getHeaders(token));

    return ApiBase.handleResponse(response, errorMessage: 'User not found');
  }

  /// Get a user ID by username
  static Future<Map<String, dynamic>> getUserIdByUsername(
    String username,
    String token,
  ) async {
    final url = Uri.parse('${ApiBase.baseUrl}/users/id/$username');
    final response = await http.get(url, headers: ApiBase.getHeaders(token));

    return ApiBase.handleResponse(response, errorMessage: 'User not found');
  }

  /// Update a user by ID
  static Future<Map<String, dynamic>> updateUser(
    String userId,
    Map<String, dynamic> userData,
    String token,
  ) async {
    final url = Uri.parse('${ApiBase.baseUrl}/users/$userId');
    final response = await http.put(
      url,
      headers: ApiBase.getHeaders(token),
      body: jsonEncode(userData),
    );

    return ApiBase.handleResponse(
      response,
      errorMessage: 'Failed to update user',
    );
  }

  /// Delete a user by ID
  static Future<Map<String, dynamic>> deleteUser(
    String userId,
    String token,
  ) async {
    final url = Uri.parse('${ApiBase.baseUrl}/users/$userId');
    final response = await http.delete(url, headers: ApiBase.getHeaders(token));

    return ApiBase.handleResponse(
      response,
      errorMessage: 'Failed to delete user',
    );
  }
}
