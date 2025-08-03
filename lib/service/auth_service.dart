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

    return {'success': true, 'token': data['token'], 'user': data['user']};
  } else {
    return {'success': false, 'message': data['message'] ?? 'Hata oluştu'};
  }
}

}

