import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easygo/l10n/app_localizations.dart'; // ✅ eklendi

class DeleteAccountSheet extends StatefulWidget {
  final bool dark;
  const DeleteAccountSheet({super.key, required this.dark});

  @override
  State<DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<DeleteAccountSheet> {
  late final List<String> reasons;
  final selected = <String>{};
  final noteCtrl = TextEditingController();
  bool confirm = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = AppLocalizations.of(context)!;
    reasons = [
      loc.reasonNotUsing,
      loc.reasonPrivacy,
      loc.reasonNotifications,
      loc.reasonTechnical,
      loc.reasonOtherApp,
      loc.reasonOther,
    ];
  }

  @override
  void dispose() {
    noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final mq = MediaQuery.of(context);
    final bool dark = widget.dark;

    final bg = dark ? const Color(0xFF111111) : Colors.white;
    final text = dark ? Colors.white : Colors.black87;
    final chipBg = dark ? const Color(0xFF222222) : Colors.grey.shade100;
    final chipSel = dark ? const Color(0x33FF5252) : Colors.red.shade50;
    final border = dark ? const Color(0xFF222222) : Colors.black12;

    return FractionallySizedBox(
      heightFactor: 0.92,
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bottomSafe = mq.padding.bottom;
            final keyboard = mq.viewInsets.bottom;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16, 16, 16,
                16 + bottomSafe + keyboard,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: DefaultTextStyle(
                  style: TextStyle(color: text),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // tutamaç
                      Container(
                        width: 40, height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: dark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      Text(loc.deleteSheetTitle,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: text)),
                      const SizedBox(height: 8),
                      _dangerBullet(loc.deleteWarning1, text),
                      _dangerBullet(loc.deleteWarning2, text),
                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          loc.deleteReasonOptional,
                          style: TextStyle(fontWeight: FontWeight.w700, color: text),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: reasons.map((r) {
                          final isSel = selected.contains(r);
                          return ChoiceChip(
                            label: Text(r, style: TextStyle(color: isSel ? Colors.red.shade300 : text)),
                            selected: isSel,
                            selectedColor: chipSel,
                            backgroundColor: chipBg,
                            side: BorderSide(color: border),
                            onSelected: (v) => setState(() {
                              if (v) { selected.add(r); } else { selected.remove(r); }
                            }),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 12),
                      TextField(
                        controller: noteCtrl,
                        maxLines: 3,
                        style: TextStyle(color: text),
                        decoration: InputDecoration(
                          labelText: loc.deleteNoteLabel,
                          hintText: loc.deleteNoteHint,
                          labelStyle: TextStyle(color: text.withOpacity(.8)),
                          hintStyle: TextStyle(color: text.withOpacity(.6)),
                          border: OutlineInputBorder(borderSide: BorderSide(color: border)),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: border)),
                          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                          filled: true,
                          fillColor: bg,
                        ),
                      ),
                      const SizedBox(height: 12),

                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: confirm,
                        onChanged: (v) => setState(() => confirm = v ?? false),
                        title: Text(
                          loc.deleteConfirmText,
                          style: TextStyle(fontWeight: FontWeight.w600, color: text),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: dark ? Colors.white : null,
                      ),

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context, false),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                side: BorderSide(color: dark ? Colors.white24 : const Color(0xFFFF9E80)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                foregroundColor: dark ? Colors.white70 : const Color(0xFFFB8C00),
                              ),
                              child: Text(loc.cancel),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: confirm
                                  ? () => Navigator.pop(context, {
                                        'confirm': true,
                                        'reasons': selected.toList(),
                                        'note': noteCtrl.text.trim(),
                                      })
                                  : null,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.delete_forever),
                              label: Text(loc.deleteAccount),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static Widget _dangerBullet(String text, Color color) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.error_outline, size: 18, color: Colors.red),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: color))),
        ],
      );
}
