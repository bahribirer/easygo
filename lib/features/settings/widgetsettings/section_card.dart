import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool dark;

  const SectionCard({
    super.key,
    required this.title,
    required this.children,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = dark ? const Color(0xFF111111) : Theme.of(context).cardColor;
    final border = dark ? const Color(0xFF222222) : Colors.grey.shade200;
    final titleColor = dark ? Colors.white : Colors.black87;
    final dividerColor = dark ? const Color(0xFF222222) : Colors.grey.shade200;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: titleColor),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: dividerColor),
            ..._withDividers(children, dividerColor),
          ],
        ),
      ),
    );
  }

  List<Widget> _withDividers(List<Widget> tiles, Color divider) {
    final out = <Widget>[];
    for (var i = 0; i < tiles.length; i++) {
      out.add(tiles[i]);
      if (i != tiles.length - 1) out.add(Divider(height: 1, color: divider));
    }
    return out;
  }
}
