import 'package:flutter/material.dart';
import 'package:easygo/l10n/app_localizations.dart';

class EventButton extends StatelessWidget {
  final VoidCallback onTap;
  const EventButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Material(
      color: const Color(0xFF1E88E5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          child: Row(
            children: [
              const Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                loc.eventButtonLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
