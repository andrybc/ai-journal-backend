import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_base.dart';

/// Service responsible for AI-related API calls
class AIService {
  /// Create an AI profile using OpenAI
  static Future<Map<String, dynamic>> createAIProfile(
    Map<String, dynamic> data,
    String token,
  ) async {
    final url = Uri.parse('${ApiBase.baseUrl}/profileRoutes/create-profile');
    final response = await http.post(
      url,
      headers: ApiBase.getHeaders(token),
      body: jsonEncode(data),
    );

    return ApiBase.handleResponse(
      response,
      errorMessage: 'Failed to create AI profile',
    );
  }

  /// Extract tags from content using OpenAI
  static Future<Map<String, dynamic>> extractTags(
    Map<String, dynamic> data,
    String token,
  ) async {
    final url = Uri.parse('${ApiBase.baseUrl}/profileRoutes/find-tags');
    final response = await http.post(
      url,
      headers: ApiBase.getHeaders(token),
      body: jsonEncode(data),
    );

    return ApiBase.handleResponse(
      response,
      errorMessage: 'Failed to extract tags',
    );
  }
}
