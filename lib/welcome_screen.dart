import 'login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easygo/register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // EasyGO logo
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'easyGO',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            // Circle with profile pictures
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Daire çerçeve
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.amber.shade50,
                      ),
                    ),
                    // Merkez kullanıcı
                    CircleAvatar(
                      radius: 40,
                      //backgroundImage: AssetImage("assets/user_center.jpg"),
                    ),
                    // Diğer kullanıcılar (örnek)
                    Positioned(
                      top: 20,
                      child: CircleAvatar(
                        radius: 20,
                        //backgroundImage: AssetImage("assets/user1.jpg"),
                      ),
                    ),
                    Positioned(
                      right: 30,
                      top: 80,
                      child: CircleAvatar(
                        radius: 20,
                        //backgroundImage: AssetImage("assets/user2.jpg"),
                      ),
                    ),
                    // Daha fazla kullanıcı konumlandırması yapılabilir...
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
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 30),
            // Giriş Yap butonu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );
},

                child: const Text(
                  "Giriş Yap",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Google ile Devam Et butonu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFFCEFE7),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                //icon: Image.asset('assets/google_logo.png', height: 24),
                label: const Text(
                  "Google ile Devam Et",
                  style: TextStyle(color: Colors.deepPurple),
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
