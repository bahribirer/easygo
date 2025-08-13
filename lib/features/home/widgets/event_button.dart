import 'package:flutter/material.dart';

class EventButton extends StatelessWidget {
  final VoidCallback onTap;
  const EventButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1E88E5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          child: Row(
            children: [
              Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Etkinlik',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}
