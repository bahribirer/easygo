import 'dart:convert';
import 'package:http/http.dart' as http;

class FriendService {
  static const String baseUrl = 'http://localhost:5050/api/friends';

  static Future<Map<String, dynamic>> getFriendData(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/$userId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Veriler alınamadı');
    }
  }

  static Future<void> acceptRequest(String userId, String fromUserId) async {
    await http.post(Uri.parse('$baseUrl/accept'),
        body: json.encode({"userId": userId, "fromUserId": fromUserId}),
        headers: {'Content-Type': 'application/json'});
  }

  static Future<void> rejectRequest(String userId, String fromUserId) async {
    await http.post(Uri.parse('$baseUrl/reject'),
        body: json.encode({"userId": userId, "fromUserId": fromUserId}),
        headers: {'Content-Type': 'application/json'});
  }

  static Future<List<dynamic>> searchUsers(String query) async {
  final response = await http.get(Uri.parse('$baseUrl/search?query=$query'));
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Kullanıcılar alınamadı');
  }
}

static Future<void> sendRequest(String fromUserId, String toUserId) async {
  final response = await http.post(Uri.parse('$baseUrl/request'),
      body: json.encode({
        "fromUserId": fromUserId,
        "toUserId": toUserId,
      }),
      headers: {'Content-Type': 'application/json'});

  if (response.statusCode != 200) {
    throw Exception('İstek gönderilemedi');
  }
}

}
