import 'package:flutter/material.dart';
import 'package:easygo/l10n/app_localizations.dart'; // ✅ eklendi

class FancyHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onLogout;
  final bool dark;

  const FancyHeader({
    super.key,
    required this.title,
    required this.onBack,
    required this.onLogout,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // ✅ lokalizasyon erişimi
    final coverH = (MediaQuery.of(context).size.height * 0.22).clamp(160.0, 220.0);

    return SliverAppBar(
      automaticallyImplyLeading: false,
      pinned: true,
      expandedHeight: coverH,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: dark
                  ? const LinearGradient(colors: [Colors.black, Colors.black])
                  : const LinearGradient(
                      colors: [Color(0xFFFF6F61), Color(0xFFFF9472)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
          ),
          if (!dark) Opacity(opacity: 0.06, child: Container(color: Colors.white)),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                12,
                MediaQuery.of(context).padding.top + 6,
                12,
                14,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: onBack,
                        tooltip: loc.back, // 🔹 lokalize edildi
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: onLogout,
                        tooltip: loc.logout, // 🔹 lokalize edildi
                      ),
                    ],
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
