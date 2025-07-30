import 'package:flutter/material.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/profile.jpg'), // Örnek
            ),
            const SizedBox(height: 12),
            const Text(
              'OSMAN YAŞAR, 20',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              'ANKARA, TÜRKİYE',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Arkadaşlar', style: TextStyle(color: Colors.orange)),
            ),
            const Text("0 Arkadaş", style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('İlgi Alanları', style: TextStyle(color: Colors.orange)),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                Chip(label: Text("🌿 Doğa")),
                Chip(label: Text("🏖️ Tatil")),
                Chip(label: Text("✍️ Yazarlık")),
                Chip(label: Text("😊 Sohbet")),
                Chip(label: Text("💪 Gym & Fitness")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
