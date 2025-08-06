import 'dart:convert';
import 'package:http/http.dart' as http;

class UserProfileService {
  static const String baseUrl = 'http://localhost:5050/api/profile';

  static Future<Map<String, dynamic>> updateOrCreateProfile({
    required String userId,
    String? gender,
    String? birthDate, // YYYY-MM-DD formatında
    String? location,
    List<String>? interests,
    String? profilePhoto, // URL veya base64
    String? language,
  }) async {
    final url = Uri.parse('$baseUrl/update');

    final body = {
      'userId': userId,
      if (gender != null) 'gender': gender,
      if (birthDate != null) 'birthDate': birthDate,
      if (location != null) 'location': location,
      if (interests != null) 'interests': interests,
      if (profilePhoto != null) 'profilePhoto': profilePhoto,
      if (language != null) 'language': language,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'profile': data['profile']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Hata oluştu'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }
  static Future<Map<String, dynamic>> getProfile(String userId) async {
  final url = Uri.parse('$baseUrl/get/$userId');

  try {
    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'profile': data};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Hata oluştu'};
    }
  } catch (e) {
    return {'success': false, 'message': 'Bağlantı hatası: $e'};
  }
}
static Future<Map<String, dynamic>> getFriends(String userId) async {
  final response = await http.get(Uri.parse('http://localhost:5050/api/friends/$userId')); // ✔️ DÜZGÜN ROTA

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return {
      'success': true,
      'friends': data['friends'],
    };
  } else {
    return {'success': false};
  }
}



}


