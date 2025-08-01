import 'dart:async';
import 'package:flutter/material.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // 3 saniye sonra WelcomeScreen'e yönlendirme
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F2), // Splash'taki soft arka plan rengi
      body: Center(
        child: Image.asset(
          'assets/easygo_logo.png', // PNG'ni buraya ekle
          width: 180,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
