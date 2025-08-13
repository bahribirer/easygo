import 'package:flutter/material.dart';
import 'package:easygo/features/welcome/welcome_screen.dart';

class BackToMainButton extends StatelessWidget {
  const BackToMainButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: IconButton(
        tooltip: 'Geri',
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            );
          }
        },
      ),
    );
  }
}
