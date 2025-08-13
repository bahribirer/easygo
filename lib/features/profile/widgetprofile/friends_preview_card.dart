import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easygo/widgets/ui/glass_card.dart';

class FriendsPreviewCard extends StatelessWidget {
  final List<dynamic> friends;
  final VoidCallback onTapAll;

  const FriendsPreviewCard({
    super.key,
    required this.friends,
    required this.onTapAll,
  });

  ImageProvider _friendPhoto(dynamic val) {
    if (val == null || val == '') return const AssetImage('assets/profile.jpg');
    try {
      return MemoryImage(base64Decode(val));
    } catch (_) {
      return const AssetImage('assets/profile.jpg');
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final maxPreview = ((w - 32) / 28).floor().clamp(0, 8);
    final preview = friends.take(maxPreview).toList();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Arkadaşlar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const Spacer(),
              if (friends.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('${friends.length} kişi',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black87)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (friends.isEmpty)
            Column(
              children: [
                const SizedBox(height: 6),
                const Icon(Icons.people_outline,
                    size: 44, color: Colors.black38),
                const SizedBox(height: 8),
                const Text('Henüz arkadaşın yok gibi görünüyor.',
                    style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: onTapAll,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Arkadaş Bul'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA5455),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 56,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (int i = 0; i < preview.length; i++)
                        Positioned(
                          left: i * 28,
                          child: CircleAvatar(
                            radius: 24,
                            backgroundImage:
                                _friendPhoto(preview[i]['profilePhoto']),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onTapAll,
                    icon: const Icon(Icons.list_alt),
                    label: const Text('Tüm arkadaşları gör'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEA5455),
                      side: const BorderSide(color: Color(0xFFFF7A7A)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
