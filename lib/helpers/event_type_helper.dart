import 'package:flutter/material.dart';
import 'package:easygo/l10n/app_localizations.dart';

class EventTypeHelper {
  // 🔹 Backend’e giden sabit keyler
  static const List<String> keys = [
    'coffee',
    'meal',
    'chat',
    'study',
    'sport',
    'cinema',
  ];

  // 🔹 Key -> Label çevirisi (AppLocalizations kullanıyor)
  static String label(BuildContext context, String key) {
    final loc = AppLocalizations.of(context)!;
    switch (key) {
      case 'coffee':
        return loc.eventTypeCoffee; // "Kahve"
      case 'meal':
        return loc.eventTypeMeal;   // "Yemek"
      case 'chat':
        return loc.eventTypeChat;   // "Sohbet"
      case 'study':
        return loc.eventTypeStudy;  // "Ders Çalışma"
      case 'sport':
        return loc.eventTypeSport;  // "Spor"
      case 'cinema':
        return loc.eventTypeCinema; // "Sinema"
      default:
        return key; // fallback
    }
  }
}
