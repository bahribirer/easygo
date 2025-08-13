import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackService {
  static const String baseUrl = 'http://localhost:5050/api/feedback';

  static Future<bool> sendDeleteAccountFeedback({
    required List<String> reasons,
    String? note,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final token = prefs.getString('token');

      if (userId == null || token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/account-delete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'reasons': reasons,
          'note': note ?? '',
          'meta': {
            'appVersion': '1.0.0',
            'platform': 'Flutter',
            'device': 'Unknown',
          }
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print("sendDeleteAccountFeedback error: $e");
      return false;
    }
  }
}
