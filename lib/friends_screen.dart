import 'package:flutter/material.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Arkadaşlık İstekleri',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.group_add_outlined, color: Colors.red, size: 64),
            const SizedBox(height: 12),
            const Text(
              'Henüz arkadaşlık isteğiniz yok',
              style: TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
            const Divider(height: 60, thickness: 1, color: Colors.redAccent),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Arkadaşlar",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Icon(Icons.people_outline, color: Colors.grey, size: 64),
            const SizedBox(height: 12),
            const Text(
              'Henüz arkadaşınız yok',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
