import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0E9),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.04),
            Image.asset(
  'assets/easygo_logo.png',
  width: screenWidth * 0.50,  // Eskiden 0.18 idi
  height: screenWidth * 0.50,
  fit: BoxFit.contain,
),

            SizedBox(height: screenHeight * 0.01),
            // 👇 Expanded yok! Direkt Expanded yerine Flexible + shrinkWrap içerik
            Expanded(
              child: Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "easyGO",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFCE1B1B),
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      const Text(
                        "Seni bekleyen harika insanlar var!",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Lottie.asset(
                        'assets/people_loading.json',
                        width: screenWidth * 0.45,
                        height: screenWidth * 0.45,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
