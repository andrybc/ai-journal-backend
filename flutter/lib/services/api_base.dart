import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Base class for API services with shared functionality
class ApiBase {
  /// Base URL for API calls
  static final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://journal-organizer.com:3000';

  /// Helper method to add authorization header
  static Map<String, String> getHeaders(String? token) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Helper method to handle API responses
  static Map<String, dynamic> handleResponse(
    http.Response response, {
    String errorMessage = 'Request failed',
  }) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      return {'success': true, 'data': body};
    } else {
      try {
        final error = jsonDecode(response.body)['error'] ?? errorMessage;
        return {'success': false, 'error': error};
      } catch (e) {
        return {'success': false, 'error': errorMessage};
      }
    }
  }
}
