import 'dart:convert';
import 'package:http/http.dart' as http;

class UserSettingsService {
  static const String baseUrl = 'http://localhost:5050/api/settings';

  static Future<Map<String, dynamic>> getSettings(String userId) async {
  final url = Uri.parse('$baseUrl/get/$userId');

  try {
    final response = await http.get(url);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {
        'success': true,
        'settings': data['settings'] ?? data
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Ayarlar alınamadı'
      };
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

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, ...updates}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'settings': data['settings']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Güncelleme başarısız'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Sunucuya ulaşılamadı: $e'};
    }
  }
}
