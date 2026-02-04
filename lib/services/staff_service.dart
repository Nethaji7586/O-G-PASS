import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class StaffService {

  // 🔹 Get pending outpass count
  static Future<int> getPendingCount(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/outpass/staff/count");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['pendingCount'] ?? 0;
    }
    return 0;
  }

  // 🔹 Get all pending outpasses
  static Future<List<dynamic>> getPendingOutpasses(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/outpass/pending");

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

  // 🔹 Approve single outpass
  static Future<bool> approveOutpass(String token, String id) async {
    final url =
    Uri.parse("${ApiConfig.baseUrl}/outpass/approve/$id");

    final response = await http.put(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return response.statusCode == 200;
  }

  // 🔹 Reject single outpass (with reason)
  static Future<bool> rejectOutpass({
    required String token,
    required String id,
    required String reason,
  }) async {
    final url =
    Uri.parse("${ApiConfig.baseUrl}/outpass/reject/$id");

    final response = await http.put(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "reason": reason,
      }),
    );

    return response.statusCode == 200;
  }

  // 🔹 Approve ALL pending outpasses
  static Future<bool> approveAllOutpasses(String token) async {
    final url =
    Uri.parse("${ApiConfig.baseUrl}/outpass/approve-all");

    final response = await http.put(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return response.statusCode == 200;
  }

  // 🔹 Reject ALL pending outpasses
  static Future<bool> rejectAllOutpasses(String token) async {
    final url =
    Uri.parse("${ApiConfig.baseUrl}/outpass/reject-all");

    final response = await http.put(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return response.statusCode == 200;
  }


  // 🔹 Get delayed students list
  static Future<List<dynamic>> getDelayedStudents(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/outpass/delay");

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



  // 🔹 Get all students (unique)
  static Future<List<dynamic>> getAllStudents(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/outpass/students");

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
}
