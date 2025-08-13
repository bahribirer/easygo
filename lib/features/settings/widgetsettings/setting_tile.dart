import 'package:flutter/material.dart';

class SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool dark;

  const SettingTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(fontWeight: FontWeight.w700, color: dark ? Colors.white : Colors.black87);
    final subtitleStyle = TextStyle(fontSize: 12, color: dark ? Colors.white70 : Colors.grey.shade700);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: dark ? const Color(0xFF222222) : const Color(0xFFFFE3D6),
        child: Icon(icon, color: dark ? Colors.white : Colors.deepOrange),
      ),
      title: Text(title, style: titleStyle),
      subtitle: Text(subtitle, style: subtitleStyle),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: dark ? Colors.white : null,
      ),
    );
  }
}
