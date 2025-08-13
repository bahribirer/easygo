import 'package:flutter/material.dart';
import 'package:easygo/widgets/ui/glass_card.dart';

class InterestsCard extends StatelessWidget {
  final List<dynamic> interests;
  const InterestsCard({super.key, required this.interests});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('İlgi Alanları',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          interests.isEmpty
              ? const Text('İlgi alanı belirtilmemiş',
                  style: TextStyle(color: Colors.black54))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: interests.map<Widget>((interest) {
                    final text = interest.toString();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
  color: Colors.red.shade50,
  borderRadius: BorderRadius.circular(999),
  border: Border.all(color: const Color(0xFFFFC1C1)),
),

                      child: Text(
                        text,
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w600),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
