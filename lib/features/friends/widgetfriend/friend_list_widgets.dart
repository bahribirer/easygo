import 'package:flutter/material.dart';
import 'package:easygo/l10n/app_localizations.dart';

class FriendCountChip extends StatelessWidget {
  final int count;
  const FriendCountChip({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.orange.shade900 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? Colors.orange.shade700 : Colors.orange.shade200,
        ),
      ),
      child: Text(
        loc.friendCountLabel(count), // örn: "5 kişi" / "5 friends"
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class EmptyFriendsView extends StatelessWidget {
  const EmptyFriendsView({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
            const SizedBox(height: 12),
            Text(
              loc.noFriendsTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              loc.noFriendsSubtitle,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class FriendSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  const FriendSearchBar({
    super.key,
    required this.controller,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.6) : Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Icon(
            Icons.search,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: hint ?? loc.searchHint,
                hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                border: InputBorder.none,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              tooltip: loc.clear,
              icon: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.black54),
              onPressed: () {
                controller.clear();
                FocusScope.of(context).unfocus();
              },
            ),
        ],
      ),
    );
  }
}
