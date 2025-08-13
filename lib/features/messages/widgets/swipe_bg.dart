import 'package:flutter/material.dart';

class SwipeBG extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool alignEnd;
  const SwipeBG({
    super.key,
    required this.icon,
    required this.text,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final align =
        alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start;
    return Container(
      decoration: BoxDecoration(
        color: alignEnd
            ? Theme.of(context).colorScheme.errorContainer
            : Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment:
          alignEnd ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: align,
        children: [
          if (alignEnd) const SizedBox(width: 8),
          Icon(icon),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          if (!alignEnd) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
