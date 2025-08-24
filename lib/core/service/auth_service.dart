import 'dart:convert';
import 'dart:io' show HttpException;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// 🔹 Convenience metodu kullanacaksan bunu aç:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class GoogleAuthService {
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Google hesabını seç
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      if (gUser == null) return null; // kullanıcı iptal etti

      // 2. Auth detaylarını al
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // 3. Firebase credential oluştur
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // 4. Firebase'e giriş yap
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print("Google Sign-In error: $e");
      return null;
    }
  }
}

class AuthService {
  /// ⚠️ Android Emulator için: http://10.0.2.2:5050
  static const String baseUrl = 'http://localhost:5050/api/auth';

  // ---------- Helpers ----------
  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> updateEmail(String newEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token'); // login/register sonrası kaydedilen JWT

    if (userId == null || token == null) {
      return {"success": false, "message": "Kullanıcı oturum bilgisi bulunamadı"};
    }

    final url = Uri.parse('$baseUrl/update-email');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "userId": userId,
        "newEmail": newEmail,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      // ✅ Başarılıysa cache’deki e-posta adresini de güncelle
      prefs.setString('universityEmail', newEmail);
      return {"success": true, "user": data['user']};
    } else {
      return {
        "success": false,
        "message": data['message'] ?? "E-posta güncellenemedi"
      };
    }
  }

  static Future<void> _saveUserToPrefs(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final user = data['user'] as Map<String, dynamic>? ?? {};
    await prefs.setString('token', data['token'] ?? '');
    await prefs.setString('userId', user['_id'] ?? '');
    await prefs.setString('userName', user['name'] ?? '');
    await prefs.setString('universityEmail', user['universityEmail'] ?? '');
    if (user['firebaseUid'] != null) {
      await prefs.setString('firebaseUid', user['firebaseUid']);
    }
  }

  static Map<String, dynamic> _safeDecode(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return {'message': 'Beklenmeyen yanıt: $body'};
    }
  }

  static Uri _uri(String path) => Uri.parse('$baseUrl$path');

  // ---------- API Methods ----------
  static Future<Map<String, dynamic>> register({
    required String name,
    required String universityEmail,
    required String password,
  }) async {
    final url = _uri('/register');
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name.trim(),
              'universityEmail': universityEmail.trim().toLowerCase(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 20));

      final data = _safeDecode(response.body);
      if (response.statusCode == 201) {
        await _saveUserToPrefs(data);
        return {'success': true, 'token': data['token'], 'user': data['user']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Kayıt başarısız'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı/işlem hatası: $e'};
    }
  }

  // ❌ Artık kullanılmıyor (bcrypt tabanlı eski login)
  @Deprecated('Firebase-first akışında kullanma. loginWithFirebaseIdToken() kullan.')
  static Future<Map<String, dynamic>> login({
    required String universityEmail,
    required String password,
  }) async {
    return {
      'success': false,
      'message': 'Bu yöntem devre dışı. Firebase ile giriş yapın.',
    };
  }

  /// ✅ YENİ: Firebase ID Token ile backend login
  /// Flutter tarafında FirebaseAuth ile signIn olduktan sonra:
  /// final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
  /// AuthService.loginWithFirebaseIdToken(idToken);
  static Future<Map<String, dynamic>> loginWithFirebaseIdToken(String idToken) async {
    final url = _uri('/login-with-firebase');
    try {
      final res = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'idToken': idToken}),
          )
          .timeout(const Duration(seconds: 20));

      final data = _safeDecode(res.body);
      if (res.statusCode == 200) {
        await _saveUserToPrefs(data);
        return {'success': true, 'token': data['token'], 'user': data['user']};
      }
      return {'success': false, 'message': data['message'] ?? 'Giriş başarısız'};
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı/işlem hatası: $e'};
    }
  }

  /// 🔹 İsteğe bağlı kolaylık: mevcut Firebase oturumundan idToken alıp backend’e gönderir.
  static Future<Map<String, dynamic>> loginUsingCurrentFirebaseUser() async {
    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser == null) {
      return {'success': false, 'message': 'Firebase oturumu bulunamadı.'};
    }
    final idToken = await fbUser.getIdToken();
    return loginWithFirebaseIdToken(idToken!);
  }

  /// DELETE /api/auth/:userId
  static Future<Map<String, dynamic>> deleteAccount([String? userId]) async {
    final prefs = await SharedPreferences.getInstance();
    final id = userId ?? prefs.getString('userId');

    if (id == null || id.isEmpty) {
      return {'success': false, 'message': 'Kullanıcı ID bulunamadı (oturum kapalı olabilir).'};
    }

    final url = _uri('/$id');
    try {
      final headers = await _authHeaders();
      if (!headers.containsKey('Authorization')) {
        return {'success': false, 'message': 'Oturum bulunamadı. Lütfen tekrar giriş yapın.'};
      }

      final res = await http.delete(url, headers: headers).timeout(const Duration(seconds: 20));

      if (res.statusCode == 204) {
        return {'success': true, 'message': 'Hesap silindi'};
      }

      final data = _safeDecode(res.body);

      if (res.statusCode == 200 && (data['success'] == true || data['message'] != null)) {
        return {'success': true, 'message': data['message'] ?? 'Hesap silindi'};
      }
      if (res.statusCode == 401) {
        return {'success': false, 'message': 'Oturum süreniz doldu. Lütfen tekrar giriş yapın.'};
      }
      if (res.statusCode == 404) {
        return {'success': false, 'message': 'Kullanıcı bulunamadı veya zaten silinmiş olabilir.'};
      }

      return {'success': false, 'message': data['message'] ?? 'Silme başarısız'};
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  

  /// Sil + local verileri temizle
  static Future<bool> deleteAndSignOut() async {
    final res = await deleteAccount();
    final prefs = await SharedPreferences.getInstance();
    if (res['success'] == true) {
      await prefs.clear();
      return true;
    }
    return false;
  }

  /// Basit signOut
  // auth_service.dart
static Future<void> signOut() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}


  // ---------- Convenience getters ----------
  static Future<String?> get token async =>
      (await SharedPreferences.getInstance()).getString('token');

  static Future<String?> get userId async =>
      (await SharedPreferences.getInstance()).getString('userId');

  static Future<String?> get firebaseUid async =>
      (await SharedPreferences.getInstance()).getString('firebaseUid');

  static Future<String?> get userName async =>
      (await SharedPreferences.getInstance()).getString('userName');

  static Future<String?> get universityEmail async =>
      (await SharedPreferences.getInstance()).getString('universityEmail');
}
