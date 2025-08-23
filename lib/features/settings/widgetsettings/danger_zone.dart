import 'package:flutter/material.dart';
import 'package:easygo/l10n/app_localizations.dart'; // ✅ eklendi

class DangerZone extends StatelessWidget {
  final bool isDeleting;
  final VoidCallback onDelete;
  final bool dark;

  const DangerZone({
    super.key,
    required this.dark,
    required this.isDeleting,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // ✅ lokalizasyon erişimi
    final cardColor = dark ? const Color(0xFF111111) : Theme.of(context).cardColor;
    final border = dark ? const Color(0x33FF0000) : Colors.red.withOpacity(.18);
    final textColor = dark ? Colors.white : Colors.black87;

    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              loc.dangerZoneTitle, // 🔹 "Tehlikeli Bölge"
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: dark ? Colors.red.shade300 : Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          loc.dangerZoneDescription, // 🔹 açıklama metni
          style: TextStyle(fontSize: 13, color: textColor),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: isDeleting ? null : onDelete,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          icon: const Icon(Icons.delete_forever),
          label: Text(isDeleting ? loc.deleting : loc.deleteAccount), // 🔹 buton metinleri
        ),
      ]),
    );
  }
}
