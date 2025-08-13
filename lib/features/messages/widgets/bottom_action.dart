import 'package:flutter/material.dart';

class BottomAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String onTapValue;
  final bool destructive;
  const BottomAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTapValue,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      onTap: () => Navigator.pop(context, onTapValue),
    );
  }
}
