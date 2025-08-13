import 'package:flutter/material.dart';

class ShimmerTile extends StatelessWidget {
  const ShimmerTile({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context)
        .colorScheme
        .surfaceContainerHighest
        .withOpacity(.6);
    return Container(
      height: 78,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(.5),
        ),
        color: base,
      ),
    );
  }
}
