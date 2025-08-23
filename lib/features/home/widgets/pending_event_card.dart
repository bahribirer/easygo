import 'package:flutter/material.dart';
import 'package:easygo/features/home/models/pending_event.dart';
import 'package:easygo/l10n/app_localizations.dart';

class PendingEventCard extends StatelessWidget {
  final PendingEvent pending;
  final VoidCallback onCancel;
  const PendingEventCard({super.key, required this.pending, required this.onCancel});

  String _pad(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final dt = pending.dateTime;
    final loc = AppLocalizations.of(context)!;
    final dateStr =
        '${_pad(dt.day)}.${_pad(dt.month)}.${dt.year}  •  ${_pad(dt.hour)}:${_pad(dt.minute)}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFE3F2FD),
            child: Icon(Icons.hourglass_top_rounded, color: Color(0xFF1E88E5)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.pendingStatus,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  '${pending.type} • ${pending.city}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.close_rounded, size: 18),
            label: Text(loc.cancel),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          )
        ],
      ),
    );
  }
}
