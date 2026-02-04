import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Base URL depending on environment
  static String get baseUrl {
    // If .env has BASE_URL, use it; otherwise default to Render production URL
    return dotenv.env['BASE_URL'] ?? "https://o-g-pass.onrender.com/api";
  }
}
