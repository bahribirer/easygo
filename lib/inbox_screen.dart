import 'package:flutter/material.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gelen Kutusu"),
        backgroundColor: Colors.deepOrange,
      ),
      body: const Center(
        child: Text(
          "Bildirimlerin burada görünecek",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
