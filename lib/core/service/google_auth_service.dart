import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_service.dart';

class GoogleAuthService {
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Google giriş nesnesi
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Kullanıcı Google hesabını seçiyor
      final GoogleSignInAccount? gUser = await googleSignIn.signIn();
      if (gUser == null) {
        return {"success": false, "message": "Kullanıcı iptal etti"};
      }

      // Token bilgilerini al
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Firebase credential oluştur
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Firebase giriş yap
      final userCred = await FirebaseAuth.instance.signInWithCredential(credential);

      // Firebase ID Token al
      final idToken = await userCred.user?.getIdToken();
      if (idToken == null) {
        return {"success": false, "message": "Firebase ID Token alınamadı"};
      }

      // Backend login
      return AuthService.loginWithFirebaseIdToken(idToken);
    } catch (e) {
      return {"success": false, "message": "Google Sign-In hatası: $e"};
    }
  }
}
