import 'package:flutter/material.dart';
import 'welcome_screen.dart'; // welcome_screen dosyasını ekledik

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // debug bannerı kaldır
      title: 'easyGO',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const WelcomeScreen(), // artık direkt WelcomeScreen'e gidiyoruz
    );
  }
}
