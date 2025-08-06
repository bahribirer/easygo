import 'dart:convert';
import 'package:easygo/friend_profile_screen.dart';
import 'package:flutter/material.dart';

class FriendsListScreen extends StatelessWidget {
  final List<dynamic> friends;

  const FriendsListScreen({super.key, required this.friends});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0E9),
      appBar: AppBar(
        title: const Text(
          "Arkadaş Listesi",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: friends.isEmpty
          ? const Center(
              child: Text(
                "Hiç arkadaş yok.",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: friends.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final friend = friends[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: friend['profilePhoto'] != null &&
                            friend['profilePhoto'].toString().isNotEmpty
                        ? MemoryImage(base64Decode(friend['profilePhoto']))
                        : const AssetImage('assets/profile.jpg') as ImageProvider,
                  ),
                  title: Text(
                    friend['name'] ?? 'Kullanıcı',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(friend['universityEmail'] ?? ''),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black45),
                  onTap: () {
                    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => FriendProfileScreen(user: friend), // ✅ burada user parametresi verildi
  ),
);

                  },
                );
              },
            ),
    );
  }
}
