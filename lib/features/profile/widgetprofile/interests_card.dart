import 'package:flutter/material.dart';
import 'package:easygo/widgets/ui/glass_card.dart';
import 'package:easygo/l10n/app_localizations.dart'; // 🔹 eklendi

class InterestsCard extends StatelessWidget {
  final List<dynamic> interests;
  const InterestsCard({super.key, required this.interests});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // 🔹 eklendi

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.interestsTitle, // 🔹 çevrildi
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          interests.isEmpty
              ? Text(
                  loc.interestsEmpty, // 🔹 çevrildi
                  style: const TextStyle(color: Colors.black54),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: interests.map<Widget>((interest) {
                    final text = interest.toString();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFFFC1C1)),
                      ),
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
