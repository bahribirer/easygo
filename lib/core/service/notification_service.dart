import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const String baseUrl = 'http://localhost:5050/api/notifications';

  /// 📌 Bildirimleri getir
  static Future<List<dynamic>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');

    final res = await http.get(Uri.parse('$baseUrl/$userId'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        return List<dynamic>.from(data['notifications']);
      }
    }
    return [];
  }

  /// 📌 Okunmamış sayısını getir
  static Future<int> getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');

    final res =
        await http.get(Uri.parse('$baseUrl/$userId/unread-count'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['success'] == true) return (data['count'] ?? 0) as int;
    }
    return 0;
  }

  /// 📌 Hepsini okundu yap
  static Future<void> markAllRead() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');

    await http.post(Uri.parse('$baseUrl/$userId/mark-read'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    });
  }

  /// 📌 Tek bir bildirimi sil
  static Future<void> deleteNotification(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.delete(
      Uri.parse('$baseUrl/$notificationId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (res.statusCode >= 400) {
      throw Exception('Bildirim silme başarısız');
    }
  }

  /// 📌 Tüm bildirimleri sil
  static Future<void> deleteAll() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');

    final res = await http.delete(
      Uri.parse('$baseUrl/user/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (res.statusCode >= 400) {
      throw Exception('Toplu silme başarısız');
    }
  }

  /// 📌 Sadece okunmuş bildirimleri sil
  static Future<void> deleteRead() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');

    final res = await http.delete(
      Uri.parse('$baseUrl/user/$userId/read'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (res.statusCode >= 400) {
      throw Exception('Okunmuş bildirimleri silme başarısız');
    }
  }
}
