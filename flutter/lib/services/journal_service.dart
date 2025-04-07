import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_base.dart';

/// Service responsible for journal/notebook-related API calls
class JournalService {
  /// Create a new notebook
  static Future<Map<String, dynamic>> createNotebook(
    Map<String, dynamic> notebookData,
    String token,
  ) async {
    final url = Uri.parse('${ApiBase.baseUrl}/journal/create-notebook');
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
      '${ApiBase.baseUrl}/journal/update-notebook/$notebookId',
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
      '${ApiBase.baseUrl}/journal/delete-notebook/$notebookId',
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
      '${ApiBase.baseUrl}/journal/read-notebook/$notebookId',
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
    String userId,
  ) async {
    // Build URL with both query and userId parameters
    final queryParams = {'query': query, 'userId': userId};

    final uri = Uri.parse(
      '${ApiBase.baseUrl}/journal/search',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: ApiBase.getHeaders(token));

    return ApiBase.handleResponse(response, errorMessage: 'Search failed');
  }

  /// Get all notebooks for a user
  static Future<Map<String, dynamic>> getAllNotebooks(
    String userId,
    String token,
  ) async {
    final url = Uri.parse('${ApiBase.baseUrl}/journal/all/$userId');
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
    final url = Uri.parse('${ApiBase.baseUrl}/journal/$userId/$notebookId');
    final response = await http.get(url, headers: ApiBase.getHeaders(token));

    return ApiBase.handleResponse(response, errorMessage: 'Notebook not found');
  }
}
