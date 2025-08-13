import 'package:flutter/material.dart';

class PrimaryActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool dark;

  const PrimaryActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = dark ? const Color(0xFF111111) : Theme.of(context).cardColor;
    final border = dark ? const Color(0xFF222222) : Colors.grey.shade200;
    final textColor = dark ? Colors.white : Colors.black87;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: dark ? const Color(0xFF222222) : const Color(0xFFFFE3D6),
              child: Icon(icon, color: dark ? Colors.white : Colors.deepOrange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: textColor),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: dark ? Colors.white60 : Colors.black45),
          ],
        ),
      ),
    );
  }
}
