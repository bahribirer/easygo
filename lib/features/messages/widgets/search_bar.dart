import 'package:flutter/material.dart';

class MessagesSearchBar extends StatelessWidget {
  final TextEditingController controller;
  const MessagesSearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: Theme.of(context).dividerColor),
    );
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Ara (kişi, mesaj)',
        prefixIcon: const Icon(Icons.search),
        isDense: true,
        filled: true,
        fillColor: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.4),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}
