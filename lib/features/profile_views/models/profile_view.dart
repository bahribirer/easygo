import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileView {
  final String viewerUid;
  final String viewerName;
  final String? viewerPhotoUrl;
  final DateTime? lastViewedAt;
  final int totalViews;

  ProfileView({
    required this.viewerUid,
    required this.viewerName,
    required this.viewerPhotoUrl,
    required this.lastViewedAt,
    required this.totalViews,
  });

  factory ProfileView.fromMap(String id, Map<String, dynamic> m) {
    final v = (m['viewer'] as Map?) ?? {};
    return ProfileView(
      viewerUid: v['uid'] ?? id,
      viewerName: v['name'] ?? "unknown", // 🔹 sabit fallback
      viewerPhotoUrl: v['photoUrl'] as String?,
      lastViewedAt: (m['lastViewedAt'] as Timestamp?)?.toDate(),
      totalViews: (m['totalViews'] ?? 1) as int,
    );
  }
}
