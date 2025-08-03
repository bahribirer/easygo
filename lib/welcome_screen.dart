import 'login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easygo/register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // EasyGO Logo
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Image.asset(
                'assets/easygo_logo.png',
                height: 60,
              ),
            ),

            // Daire & Avatarlar
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade100, Colors.orange.shade200],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepOrange.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.red.shade300,
                      child: const Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    Positioned(
                      top: 20,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue.shade200,
                        child: const Icon(Icons.person, size: 20, color: Colors.white),
                      ),
                    ),
                    Positioned(
                      right: 30,
                      top: 80,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.green.shade200,
                        child: const Icon(Icons.person, size: 20, color: Colors.white),
                      ),
                    ),
                    Positioned(
                      left: 30,
                      bottom: 70,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.purple.shade200,
                        child: const Icon(Icons.person, size: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Hoşgeldiniz yazısı
            RichText(
              text: TextSpan(
                text: 'Hoş',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: 'geldiniz...',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Text(
              '"Bağlantılar kur,\nsohbet et, eğlen"',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 30),

            // Giriş Yap butonu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  elevation: 4,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  shadowColor: Colors.redAccent,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text(
                  "Giriş Yap",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Google ile Devam Et butonu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.g_mobiledata, color: Colors.deepPurple, size: 28),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.orange.shade50,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  side: const BorderSide(color: Colors.deepPurple),
                ),
                label: const Text(
                  "Google ile Devam Et",
                  style: TextStyle(color: Colors.deepPurple, fontSize: 16),
                ),
                onPressed: () {},
              ),
            ),

            const SizedBox(height: 10),

            // Kayıt Ol linki
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Hesabın yok mu?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text("Kayıt Ol"),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
