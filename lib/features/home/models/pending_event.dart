import 'package:flutter/material.dart';
import 'package:easygo/helpers/event_type_helper.dart';

class PendingEvent {
  final String id;
  final String type; // backend’den gelen sabit key ("chat", "meal", "coffee" vs.)
  final String city;
  final DateTime dateTime;
  final DateTime createdAt;

  PendingEvent({
    required this.id,
    required this.type,
    required this.city,
    required this.dateTime,
    required this.createdAt,
  });

  factory PendingEvent.fromJson(Map<String, dynamic> j) => PendingEvent(
        id: j['_id'] as String,
        type: j['type'] as String,
        city: j['city'] as String,
        dateTime: DateTime.parse(j['dateTime'] as String),
        createdAt: DateTime.parse(j['createdAt'] as String),
      );

  /// ✅ Ekranda gösterilecek doğru etiket
  String label(BuildContext context) {
    return EventTypeHelper.label(context, type);
  }
}
