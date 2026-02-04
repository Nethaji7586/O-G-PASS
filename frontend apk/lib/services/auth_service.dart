import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthService {
  /// login → returns {role, name}
  static Future<bool> addPhone({
    required String token,
    required String phone,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/auth/add-phone");

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "phone": phone,
      }),
    );

    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>?> getProfile({
    required String token,
  }) async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/student/me"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return null;
  }


  static Future<Map<String, dynamic>?> login(
      String email, String password) async {

    final url = Uri.parse("${ApiConfig.baseUrl}/auth/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
      // { token, role, name }
    }
    return null;
  }

  static Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/auth/register");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "role": role,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}
