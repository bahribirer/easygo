import 'package:easygo/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:easygo/profile_step1.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;
  String passwordError = '';
  double passwordStrength = 0;

  void showPopup(String title, String message) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: Colors.red.shade700,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Tamam",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


  bool isValidUniversityEmail(String email) {
    final regex = RegExp(r'^[\w\.-]+@metu\.edu\.tr$');
    return regex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    final hasMinLength = password.length >= 8;

    // Güç hesapla
    double strength = 0;
    if (password.length >= 6) strength += 0.25;
    if (hasUppercase) strength += 0.25;
    if (hasSpecialChar) strength += 0.25;
    if (password.length >= 10) strength += 0.25;
    passwordStrength = strength;

    if (!hasMinLength) {
      passwordError = 'En az 8 karakter olmalı';
      return false;
    } else if (!hasUppercase) {
      passwordError = 'En az bir büyük harf içermeli';
      return false;
    } else if (!hasSpecialChar) {
      passwordError = 'En az bir özel karakter (@,#,!) içermeli';
      return false;
    }

    passwordError = '';
    return true;
  }

  void handleRegister() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      showPopup("Eksik Bilgi", "Lütfen tüm alanları doldurunuz.");
    } else if (!isValidUniversityEmail(email)) {
      showPopup("Geçersiz Mail", "Lütfen geçerli bir @metu.edu.tr mail adresi giriniz.");
    } else if (!isValidPassword(password)) {
      setState(() {});
    } else {
      final result = await AuthService.register(
        name: name,
        universityEmail: email,
        password: password,
      );

      if (result['success']) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', result['user']['_id']);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileStep1Screen()),
        );
      } else {
        showPopup("Kayıt Başarısız", result['message']);
      }
    }
  }

  Color getPasswordStrengthColor() {
    if (passwordStrength <= 0.25) return Colors.red;
    if (passwordStrength <= 0.5) return Colors.orange;
    if (passwordStrength <= 0.75) return Colors.blue;
    return Colors.green;
  }

  String getPasswordStrengthText() {
    if (passwordStrength <= 0.25) return "Zayıf";
    if (passwordStrength <= 0.5) return "Orta";
    if (passwordStrength <= 0.75) return "İyi";
    return "Güçlü";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Image.asset('assets/easygo_logo.png', height: 60),
                const SizedBox(height: 30),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Hesap Oluştur\n",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: "Hemen Kayıt ol,\nSohbete Başla",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "İsim Soyisim",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "Üniversite E-Mail Adresi",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  onChanged: (value) {
                    isValidPassword(value);
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: "Şifre",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                if (passwordError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        passwordError,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ),
                if (passwordController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: getPasswordStrengthColor(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          getPasswordStrengthText(),
                          style: TextStyle(
                            color: getPasswordStrengthColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: handleRegister,
                  child: const Text("Kayıt Ol"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
