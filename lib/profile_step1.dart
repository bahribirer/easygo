import 'package:flutter/material.dart';
import 'profile_step2.dart';

class ProfileStep1Screen extends StatefulWidget {
  const ProfileStep1Screen({super.key});

  @override
  State<ProfileStep1Screen> createState() => _ProfileStep1ScreenState();
}

class _ProfileStep1ScreenState extends State<ProfileStep1Screen> {
  String? selectedLanguage;
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(progress: 25),
              const SizedBox(height: 30),
              const Text("Dil", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              const Text("Uygulamayı hangi dilde kullanmak istersin?"),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                hint: const Text("Dil Seçiniz"),
                items: const [
                  DropdownMenuItem(value: 'tr', child: Text("Türkçe")),
                  DropdownMenuItem(value: 'en', child: Text("İngilizce")),
                ],
                onChanged: (val) {
                  setState(() {
                    selectedLanguage = val;
                  });
                },
              ),
              const SizedBox(height: 30),
              const Text("Cinsiyet", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              const Text("Kendini nasıl tanımlıyorsun?"),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                hint: const Text("Cinsiyet Seçiniz"),
                items: const [
                  DropdownMenuItem(value: 'Kadın', child: Text("Kadın")),
                  DropdownMenuItem(value: 'Erkek', child: Text("Erkek")),
                  DropdownMenuItem(value: 'Diğer', child: Text("Diğer")),
                ],
                onChanged: (val) {
                  setState(() {
                    selectedGender = val;
                  });
                },
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  if (selectedLanguage != null && selectedGender != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileStep2Screen(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Lütfen tüm alanları doldurunuz")),
                    );
                  }
                },
                child: const Text("Devam Et"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({required int progress}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Profili Tamamla",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                value: progress / 100,
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade700),
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            Text("%$progress", style: const TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }
}