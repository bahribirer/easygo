import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:5050/api/auth';

  static Future<Map<String, dynamic>> register({
    required String name,
    required String universityEmail,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'universityEmail': universityEmail,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return {'success': true, 'token': data['token'], 'user': data['user']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Hata oluştu'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String universityEmail,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'universityEmail': universityEmail,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('userId', data['user']['_id']);
      await prefs.setString('userName', data['user']['name']);
      return {'success': true, 'token': data['token'], 'user': data['user']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Hata oluştu'};
    }
  }

  /// Hesabı kalıcı olarak siler: DELETE /api/auth/:userId
  static Future<Map<String, dynamic>> deleteAccount(String userId) async {
    final url = Uri.parse('$baseUrl/$userId');
    try {
      final res = await http.delete(url);
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && (data['success'] == true || data['message'] != null)) {
        return {'success': true, 'message': data['message'] ?? 'Hesap silindi'};
      }
      return {'success': false, 'message': data['message'] ?? 'Silme başarısız'};
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  /// Kullanışlı helper: sil + local verileri temizle
  static Future<bool> deleteAndSignOut() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return false;

    final res = await deleteAccount(userId);
    if (res['success'] == true) {
      await prefs.clear(); // token, userId, userName, cached settings hepsi gider
      return true;
    }
    return false;
  }
}
