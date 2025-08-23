import 'package:flutter/material.dart';
import 'package:easygo/l10n/app_localizations.dart';

class ActiveChatsScreen extends StatelessWidget {
  const ActiveChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.activeChatsTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.red,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          loc.noActiveChatsMessage,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }
}
