import 'package:flutter/material.dart';
import 'package:easygo/l10n/app_localizations.dart';

class InterestsHelper {
  // 🔹 Key listesi – backend’e kaydedilecek sabit anahtarlar
  static const List<String> keys = [
    'yoga',
    'running',
    'swimming',
    'basketball',
    'football',
    'tennis',
    'cycling',
    'climbing',
    'hiking',
    'gym',
    'martialArts',
    'golf',
    'volleyball',
    'skiing',
    'surfing',
  ];

  // 🔹 Key -> label çevirisi (AppLocalizations kullanıyor)
  static String label(BuildContext context, String key) {
    final loc = AppLocalizations.of(context)!;
    switch (key) {
      case 'yoga': return loc.interestYoga;
      case 'running': return loc.interestRunning;
      case 'swimming': return loc.interestSwimming;
      case 'basketball': return loc.interestBasketball;
      case 'football': return loc.interestFootball;
      case 'tennis': return loc.interestTennis;
      case 'cycling': return loc.interestCycling;
      case 'climbing': return loc.interestClimbing;
      case 'hiking': return loc.interestHiking;
      case 'gym': return loc.interestGym;
      case 'martialArts': return loc.interestMartialArts;
      case 'golf': return loc.interestGolf;
      case 'volleyball': return loc.interestVolleyball;
      case 'skiing': return loc.interestSkiing;
      case 'surfing': return loc.interestSurfing;
      default: return key; // fallback
    }
  }
}
