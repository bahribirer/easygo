import 'dart:convert';

import 'package:easygo/FriendListScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easygo/service/user_profile_service.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;
  List<dynamic> friends = [];


  @override
  void initState() {
    super.initState();
    loadProfile();
  }

Future<void> loadProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');

  if (userId != null) {
    final profileRes = await UserProfileService.getProfile(userId);
    final friendsRes = await UserProfileService.getFriends(userId);

    setState(() {
      isLoading = false;

      if (profileRes['success']) {
        profileData = profileRes['profile'];
      }

      if (friendsRes['success']) {
        friends = friendsRes['friends'];
      }
    });
  } else {
    setState(() => isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
backgroundColor: const Color(0xFFFFF0E9),
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
).then((_) {
  loadProfile(); // 🔄 Geri dönünce veriyi tazele
});

            },
          )
        ],
      ),
      body: isLoading
    ? const Center(child: CircularProgressIndicator())
    : profileData == null
        ? const Center(child: Text("Profil verisi bulunamadı."))
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: profileData!['profilePhoto'] != null &&
                            profileData!['profilePhoto'] != ''
                        ? MemoryImage(base64Decode(profileData!['profilePhoto']))
                        : const AssetImage('assets/profile.jpg') as ImageProvider,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "${profileData!['name'] ?? 'Kullanıcı'}, ${calculateAge(profileData!['birthDate'])}",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      "${profileData!['location'] ?? 'Bilinmiyor'}, TÜRKİYE",
                      style: const TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Arkadaşlar kartı
                // Arkadaşlar kartı
InkWell(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FriendsListScreen(friends: friends),
      ),
    );
  },
  child: Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    elevation: 3,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Arkadaşlar',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            "${friends.length} Arkadaş",
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    ),
  ),
),


                const SizedBox(height: 20),
                // İlgi alanları kartı
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'İlgi Alanları',
                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (profileData!['interests'] as List?)?.map((interest) => Chip(
  label: Text(interest),
  backgroundColor: Colors.red.shade50,
  labelStyle: const TextStyle(color: Colors.red),
)).toList() ?? [const Text("İlgi alanı belirtilmemiş")],

                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

    );
  }

  int calculateAge(String? birthDateStr) {
    if (birthDateStr == null) return 0;
    final birthDate = DateTime.parse(birthDateStr);
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
