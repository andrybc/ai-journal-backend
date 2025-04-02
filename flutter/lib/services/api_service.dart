import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  Future<Map<String, dynamic>> searchProfiles(
    String query,
    String userId,
  ) async {
    try {
      final String apiUrl = dotenv.env["VITE_API_URL"] ?? "";
      if (apiUrl.isEmpty) {
        throw Exception("API URL is not set in the environment variables");
      }

      final response = await http.get(
        Uri.parse(
          "$apiUrl/profile/search?userId=$userId&query=${Uri.encodeComponent(query)}",
        ),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) ?? [];

        if (!responseData.containsKey("profiles")) {
          throw Exception("Missing 'profiles' key in API response.");
        }

        final data = responseData["profiles"];
        return {"success": true, "profiles": data};
      } else {
        final errorMessage = jsonDecode(
          response.body.isNotEmpty ? response.body : "{}",
        );
        throw Exception(
          errorMessage["error"] ??
              "Unexpected error while searching for profiles",
        );
      }
    } catch (error) {
      print(error.toString());
      return {"success": false, "errorMessage": error.toString()};
    }
  }

  Future<Map<String, dynamic>> getProfile(int profileId, String userId) async {
    try {
      final String apiUrl = dotenv.env["VITE_API_URL"] ?? "";
      if (apiUrl.isEmpty) {
        throw Exception("API URL is not set in the environment variables");
      }

      final response = await http.get(
        Uri.parse("$apiUrl/profile/$userId/$profileId"),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) ?? [];

        if (!responseData.containsKey("profiles")) {
          throw Exception("Missing 'profiles' key in API response.");
        }

        print(responseData["message"]);
        final data = responseData["profile"];
        return {"success": true, "profile": data};
      } else {
        final errorMessage = jsonDecode(
          response.body.isNotEmpty ? response.body : "{}",
        );
        throw Exception(
          errorMessage["error"] ?? "Unexpected error while retrieving profile",
        );
      }
    } catch (error) {
      print(error);
      return {"success": false, "profile": error.toString()};
    }
  }
}
