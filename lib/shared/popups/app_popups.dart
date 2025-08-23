import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easygo/l10n/app_localizations.dart';

enum AppPopupType { success, warning, error, info }

Future<bool> showAppPopup(
  BuildContext context, {
  required AppPopupType type,
  required String title,
  String? message,
  String? primaryText,
  String? secondaryText,
}) async {
  final loc = AppLocalizations.of(context)!;

  IconData icon;
  Color color;
  switch (type) {
    case AppPopupType.success:
      icon = Icons.check_circle_rounded;
      color = const Color(0xFF2E7D32);
      break;
    case AppPopupType.warning:
      icon = Icons.warning_amber_rounded;
      color = const Color(0xFFF9A825);
      break;
    case AppPopupType.error:
      icon = Icons.error_rounded;
      color = const Color(0xFFC62828);
      break;
    case AppPopupType.info:
      icon = Icons.info_rounded;
      color = const Color(0xFF1565C0);
      break;
  }

  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'popup',
    barrierColor: Colors.black.withOpacity(0.35),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      return Transform.scale(
        scale: 0.95 + (0.05 * anim.value),
        child: Opacity(
          opacity: anim.value,
          child: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(),
              ),
              Center(
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: color.withOpacity(.10),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, size: 34, color: color),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (message != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              message!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              if (secondaryText != null)
                                Expanded(
                                  child: TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text(
                                      secondaryText!,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              if (secondaryText != null)
                                const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: color,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  child: Text(
                                    primaryText ?? loc.ok, // 🔹 çeviri
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}

/// 🔹 Kısayollar
Future<void> showSuccess(BuildContext c, String t, [String? m]) =>
    showAppPopup(c,
        type: AppPopupType.success,
        title: t,
        message: m,
        primaryText: AppLocalizations.of(c)!.ok).then((_) {});

Future<void> showError(BuildContext c, String t, [String? m]) =>
    showAppPopup(c,
        type: AppPopupType.error,
        title: t,
        message: m,
        primaryText: AppLocalizations.of(c)!.ok).then((_) {});

Future<void> showWarning(BuildContext c, String t, [String? m]) =>
    showAppPopup(c,
        type: AppPopupType.warning,
        title: t,
        message: m,
        primaryText: AppLocalizations.of(c)!.ok).then((_) {});

Future<bool> showConfirm(
  BuildContext c, {
  required String title,
  String? message,
  String? ok,
  String? cancel,
}) =>
    showAppPopup(
      c,
      type: AppPopupType.info,
      title: title,
      message: message,
      primaryText: ok ?? AppLocalizations.of(c)!.confirm,
      secondaryText: cancel ?? AppLocalizations.of(c)!.cancel,
    );
