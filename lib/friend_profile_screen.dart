import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easygo/service/user_profile_service.dart';
import 'package:easygo/service/friendService.dart';

class FriendProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const FriendProfileScreen({super.key, required this.user});

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    fetchFriendProfile();
  }

  Future<void> fetchFriendProfile() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString('userId');

    final result = await UserProfileService.getProfile(widget.user['_id']);
    if (result['success']) {
      setState(() {
        profileData = result['profile'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  int calculateAge(String? birthDateStr) {
    if (birthDateStr == null) return 0;
    final birthDate = DateTime.parse(birthDateStr);
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : profileData == null
              ? const Center(child: Text("Profil verisi alınamadı"))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage: profileData!['profilePhoto'] != null &&
                                        profileData!['profilePhoto'].toString().isNotEmpty
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
                            Text(
                              profileData!['universityEmail'] ?? '',
                              style: const TextStyle(color: Colors.black54, fontSize: 14),
                            ),
                            const SizedBox(height: 24),
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
                                    profileData!['interests'] != null &&
                                            (profileData!['interests'] as List).isNotEmpty
                                        ? Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: (profileData!['interests'] as List)
                                                .map((interest) => Chip(
                                                      label: Text(interest),
                                                      backgroundColor: Colors.red.shade50,
                                                      labelStyle: const TextStyle(color: Colors.red),
                                                    ))
                                                .toList()
                                                .cast<Widget>(),
                                          )
                                        : const Text("İlgi alanı belirtilmemiş"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.delete_forever),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                if (currentUserId != null) {
                                  await FriendService.unfriend(
  currentUserId!,
  widget.user['_id'],
);

if (mounted) {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Arkadaşlık Silindi 💔", style: TextStyle(fontWeight: FontWeight.bold)),
      content: const Text("Bu kişiyi arkadaş listesinden kaldırdın."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Tamam", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
  Navigator.pop(context, true); // Ana sayfaya geri dön
}


                                }
                              },
                              label: const Text("Arkadaşlıktan Çıkar"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.message),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                // Mesaj gönderme henüz aktif değil
                              },
                              label: const Text(
                                "Mesaj Gönder",
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
    );
  }
}
