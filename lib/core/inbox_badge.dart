import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InboxBadge {
  static final ValueNotifier<int> notifier = ValueNotifier<int>(0);
  static StreamSubscription? _subscription;

  /// Firestore stream başlat
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    // Eski subscription varsa iptal et
    await _subscription?.cancel();

    final colRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications');

    _subscription = colRef.snapshots().listen((snap) {
      final unread = snap.docs.where((d) => (d['read'] ?? false) == false).length;
      notifier.value = unread;
    });
  }

  /// Temizlik (çıkış yapılırken vs)
  static Future<void> dispose() async {
    await _subscription?.cancel();
    notifier.value = 0;
  }
}
