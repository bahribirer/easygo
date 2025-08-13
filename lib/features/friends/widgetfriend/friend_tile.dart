import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class FriendTile extends StatelessWidget {
  final String idTag;
  final String name;
  final String email;
  final String location;
  final String? base64Photo;
  final VoidCallback? onTap;

  const FriendTile({
    super.key,
    required this.idTag,
    required this.name,
    required this.email,
    required this.location,
    required this.base64Photo,
    this.onTap,
  });

  ImageProvider _avatarProvider() {
    try {
      if (base64Photo != null && base64Photo!.isNotEmpty) {
        final Uint8List bytes = base64Decode(base64Photo!);
        return MemoryImage(bytes);
      }
    } catch (_) {}
    return const AssetImage('assets/profile.jpg');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Hero(
              tag: 'friend_$idTag',
              child: CircleAvatar(radius: 28, backgroundImage: _avatarProvider()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 2),
                  if (email.isNotEmpty)
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  if (location.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}
