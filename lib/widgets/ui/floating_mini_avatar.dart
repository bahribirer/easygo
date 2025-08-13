import 'dart:math' as math;
import 'package:flutter/material.dart';

class FloatingMiniAvatar extends StatelessWidget {
  final double angle; // radyan
  final double radius;
  final double size;
  final Color color;
  final Animation<double> float;

  const FloatingMiniAvatar({
    super.key,
    required this.angle,
    required this.radius,
    required this.size,
    required this.color,
    required this.float,
  });

  @override
  Widget build(BuildContext context) {
    final dx = radius * math.cos(angle);
    final dy = radius * math.sin(angle);

    return AnimatedBuilder(
      animation: float,
      builder: (_, __) {
        final bob = math.sin(float.value * math.pi) * 6; // hafif yukarı-aşağı
        return Transform.translate(
          offset: Offset(dx, dy + bob),
          child: CircleAvatar(
            radius: size,
            backgroundColor: color,
            child: const Icon(Icons.person, size: 18, color: Colors.white),
          ),
        );
      },
    );
  }
}
