import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_base.dart';

/// Service responsible for journal/notebook-related API calls
class NotebookService {
  /// Create a new notebook
  static Future<Map<String, dynamic>> createNotebook(
    Map<String, dynamic> notebookData,
    String token,
  ) async {
    final url = Uri.parse('${ApiBase.baseUrl}/notebook/create-notebook');
    final response = await http.post(
      url,
      headers: ApiBase.getHeaders(token),
      body: jsonEncode(notebookData),
    );

    return ApiBase.handleResponse(
      response,
      errorMessage: 'Failed to create notebook',
    );
  }

  /// Update an existing notebook
  static Future<Map<String, dynamic>> updateNotebook(
    String notebookId,
    Map<String, dynamic> notebookData,
    String token,
  ) async {
    final url = Uri.parse(
      '${ApiBase.baseUrl}/notebook/update-notebook/$notebookId',
    );
    final response = await http.put(
      url,
      headers: ApiBase.getHeaders(token),
      body: jsonEncode(notebookData),
    );

    return ApiBase.handleResponse(
      response,
      errorMessage: 'Failed to update notebook',
    );
  }

  /// Delete a notebook
  static Future<Map<String, dynamic>> deleteNotebook(
    String notebookId,
    String token,
  ) async {
    final url = Uri.parse(
      '${ApiBase.baseUrl}/notebook/delete-notebook/$notebookId',
    );
    final response = await http.delete(url, headers: ApiBase.getHeaders(token));

    return ApiBase.handleResponse(
      response,
      errorMessage: 'Failed to delete notebook',
    );
  }

  /// Get a notebook by ID
  static Future<Map<String, dynamic>> readNotebook(
    String notebookId,
    String token,
  ) async {
    final url = Uri.parse(
      '${ApiBase.baseUrl}/notebook/read-notebook/$notebookId',
    );
    final response = await http.get(url, headers: ApiBase.getHeaders(token));

    return ApiBase.handleResponse(
      response,
      errorMessage: 'Failed to read notebook',
    );
  }

  /// Search notebooks
  static Future<Map<String, dynamic>> searchNotebooks(
    String query,
    String token,
  ) async {
    final url = Uri.parse(
      '${ApiBase.baseUrl}/notebook/search?q=${Uri.encodeComponent(query)}',
    );
    final response = await http.get(url, headers: ApiBase.getHeaders(token));

    return ApiBase.handleResponse(response, errorMessage: 'Search failed');
  }

  /// Get all notebooks for a user
  static Future<Map<String, dynamic>> getAllNotebooks(
    String userId,
    String token,
  ) async {
    final url = Uri.parse('${ApiBase.baseUrl}/notebook/all/$userId');
    final response = await http.get(url, headers: ApiBase.getHeaders(token));

    return ApiBase.handleResponse(
      response,
      errorMessage: 'Failed to get notebooks',
    );
  }

  /// Get a specific notebook by user ID and notebook ID
  static Future<Map<String, dynamic>> getNotebookById(
    String userId,
    String notebookId,
    String token,
  ) async {
    final url = Uri.parse('${ApiBase.baseUrl}/notebook/$userId/$notebookId');
    final response = await http.get(url, headers: ApiBase.getHeaders(token));

    return ApiBase.handleResponse(response, errorMessage: 'Notebook not found');
  }
}
