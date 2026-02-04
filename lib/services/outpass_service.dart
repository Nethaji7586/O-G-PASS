import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class OutpassService {

  // Request new outpass
  static Future<bool> requestOutpass({
    required String token,
    required String reason,
    required DateTime outTime,
    required DateTime inTime,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/student/request");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "reason": reason,
        "outTime": outTime.toIso8601String(),
        "inTime": inTime.toIso8601String(),
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // Get all outpasses for student
  static Future<List<dynamic>> getMyOutpasses(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/student/my");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return [];
  }

  // Cancel outpass
  static Future<bool> cancelOutpass(String token, String id) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/student/cancel/$id");

    final response = await http.delete(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return response.statusCode == 200;
  }

  // Mark as reached
  static Future<bool> reachedOutpass(String token, String id) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/student/reached/$id");

    final response = await http.put(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return response.statusCode == 200;
  }
}
