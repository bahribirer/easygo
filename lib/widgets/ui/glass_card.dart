import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final bool dark;
  final Widget child;
const GlassCard({super.key, this.dark = false, required this.child});

  @override
  Widget build(BuildContext context) {
    final cardColor = dark ? const Color(0xFF121212) : Colors.white;
    final border = dark ? Colors.white10 : Colors.black12;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(dark ? .9 : .85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
