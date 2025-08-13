import 'package:flutter/material.dart';

class ArchivedChatsScreen extends StatelessWidget {
  const ArchivedChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Arşivlenmiş Sohbetler"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.red,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: const Center(
        child: Text(
          "Henüz arşivlenmiş sohbetiniz bulunmamaktadır.",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }
}
