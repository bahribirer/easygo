import 'package:flutter/material.dart';

class ActiveChatsScreen extends StatelessWidget {
  const ActiveChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aktif Sohbetler"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.red,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: const Center(
        child: Text(
          "Şu an aktif sohbetiniz bulunmamaktadır.",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }
}
