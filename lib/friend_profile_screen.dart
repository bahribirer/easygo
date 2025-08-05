import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easygo/service/user_profile_service.dart';

class FriendProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const FriendProfileScreen({super.key, required this.user});

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFriendProfile();
  }

  Future<void> fetchFriendProfile() async {
    final result = await UserProfileService.getProfile(widget.user['_id']);
    if (result['success']) {
      setState(() {
        profileData = result['profile'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      // Hata varsa snackbar vs. basabilirsin
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
              : SingleChildScrollView(
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
    );
  }
}
