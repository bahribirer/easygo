import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserSettingsService {
  static const String baseUrl = 'http://localhost:5050/api/settings';

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> getSettings(String userId) async {
    final url = Uri.parse('$baseUrl/get/$userId');
    final headers = await _headers();
    try {
      final res = await http.get(url, headers: headers);
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return {'success': true, 'settings': data['settings'] ?? data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Ayarlar alınamadı'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateSettings({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    final url = Uri.parse('$baseUrl/update');
    final headers = await _headers();

    try {
      final res = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'userId': userId, ...updates}),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return {'success': true, 'settings': data['settings'] ?? data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Güncelleme başarısız'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Sunucuya ulaşılamadı: $e'};
    }
  }
}
