import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EventService {
  static const String baseUrl = "http://localhost:5050/api/events"; // 🔹 kendi backend URL

  static Future<Map<String, dynamic>> createEvent({
    required String type,
    required String city,
    required DateTime dateTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {"success": false, "message": "Token bulunamadı"};
    }

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "type": type,
        "city": city,
"dateTime": dateTime.toUtc().toIso8601String(),      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getMyPendingEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {"success": false, "message": "Token bulunamadı"};
    }

    final response = await http.get(
      Uri.parse("$baseUrl/my-pending"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getMyTodayCount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {"success": false, "message": "Token bulunamadı"};
    }

    final response = await http.get(
      Uri.parse("$baseUrl/my-today-count"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> cancelEvent(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {"success": false, "message": "Token bulunamadı"};
    }

    final response = await http.patch(
      Uri.parse("$baseUrl/$eventId/cancel"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }
}
