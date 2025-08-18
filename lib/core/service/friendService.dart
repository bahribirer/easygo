import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FriendService {
  static const String baseUrl = 'http://localhost:5050/api/friends';

  /// ✅ Token getter
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // girişte kaydettiğimiz JWT
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> getFriendData(String userId) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/$userId'), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Veriler alınamadı');
    }
  }

  static Future<void> acceptRequest(String userId, String fromUserId) async {
    final headers = await _getHeaders();
    await http.post(Uri.parse('$baseUrl/accept'),
        body: json.encode({"userId": userId, "fromUserId": fromUserId}),
        headers: headers);
  }

  static Future<void> rejectRequest(String userId, String fromUserId) async {
    final headers = await _getHeaders();
    await http.post(Uri.parse('$baseUrl/reject'),
        body: json.encode({"userId": userId, "fromUserId": fromUserId}),
        headers: headers);
  }

  static Future<List<dynamic>> searchUsers(String query) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/search?query=$query'), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Kullanıcılar alınamadı');
    }
  }

  /// ✅ Arkadaşlık isteği gönderme
  static Future<void> sendRequest(String fromUserId, String toUserId) async {
    final headers = await _getHeaders();

    // cihazın güncel FCM tokenini al
    final fcmToken = await FirebaseMessaging.instance.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/request'),
      body: json.encode({
        "fromUserId": fromUserId,
        "toUserId": toUserId,
        "fcmToken": fcmToken, // backend firestore’a kaydetsin diye gönderiyoruz
      }),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('İstek gönderilemedi: ${response.body}');
    }
  }

  static Future<void> unfriend(String userId, String friendId) async {
    final headers = await _getHeaders();
    final response = await http.post(Uri.parse('$baseUrl/unfriend'),
        body: json.encode({
          "userId": userId,
          "friendId": friendId,
        }),
        headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Arkadaş silinemedi');
    }
  }
}
