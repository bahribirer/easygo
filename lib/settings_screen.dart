import 'package:easygo/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'profile_edit_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Toggle durumlarını tutan değişkenler
  bool messageFromEveryone = false;
  bool showInSuggestions = false;
  bool followRequestsFromAll = false;
  bool isPrivate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hesap Ayarları',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profili Düzenle Butonu
            ElevatedButton.icon(
              icon: const Icon(Icons.edit, color: Colors.black),
              label: const Text("Profili Düzenle", style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),

            // Togglelar
            buildToggle(
              "Herkesten Mesaj Al",
              "Kapalı olduğunda yalnızca takip ettiklerinden mesaj alırsın",
              messageFromEveryone,
              (value) => setState(() => messageFromEveryone = value),
            ),
            buildToggle(
              "Hesap Önerileri",
              "Profilin önerilerde görünür. İstemiyorsan kapat.",
              showInSuggestions,
              (value) => setState(() => showInSuggestions = value),
            ),
            buildToggle(
              "Takip İstekleri (Herkesten)",
              "Kapalıysa yalnızca takip ettiklerin sana istek atabilir.",
              followRequestsFromAll,
              (value) => setState(() => followRequestsFromAll = value),
            ),
            buildToggle(
              "Hesabı Gizliye Al",
              "Hesabını gizlemek için aç.",
              isPrivate,
              (value) => setState(() => isPrivate = value),
            ),

            const Spacer(),

            // ÇIKIŞ YAP Butonu
            ElevatedButton(
              onPressed: () {
                // Giriş ekranına yönlendir, önceki sayfaları temizle
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()), // veya LoginScreen
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("ÇIKIŞ YAP"),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildToggle(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.toggle_off_outlined),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}
