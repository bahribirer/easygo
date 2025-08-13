import 'package:flutter/material.dart';

class BlurredCircle extends StatelessWidget {
  final double size;
  final List<Color> colors;
  const BlurredCircle({super.key, required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(.35),
            blurRadius: 40,
            spreadRadius: 6,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(.55),
            width: 0.6,
          ),
        ),
      ),
    );
  }
}
