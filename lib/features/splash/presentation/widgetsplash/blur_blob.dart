import 'dart:ui';
import 'package:flutter/material.dart';

class BlurBlob extends StatelessWidget {
  final double size;
  final Color color;
  const BlurBlob({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
