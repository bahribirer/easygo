import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final bool dark;
  final Widget child;
  final EdgeInsets padding;
  final double opacity;
  final double blur;

  const GlassCard({
    super.key,
    this.dark = false,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.opacity = 0.85,
    this.blur = 14,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = dark ? const Color(0xFF121212) : Colors.white;
    final border = dark ? Colors.white.withOpacity(0.15) : Colors.black12;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
            gradient: LinearGradient(
              colors: dark
                  ? [
                      baseColor.withOpacity(opacity * 0.7),
                      baseColor.withOpacity(opacity * 0.4),
                    ]
                  : [
                      baseColor.withOpacity(opacity),
                      baseColor.withOpacity(opacity * 0.6),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
