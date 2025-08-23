import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileViewService {
  static final _db = FirebaseFirestore.instance;

  /// Bir kullanıcı başka birinin profilini açtığında çağır.
  /// viewedUserId: profili açılan kişi
  static Future<void> recordProfileView({
    required String viewedUserId,
    required String viewerUid,
    required String viewerName,
    String? viewerPhotoUrl,
  }) async {
    if (viewedUserId == viewerUid) return; // kendini sayma

    final docRef = _db
        .collection('users')
        .doc(viewedUserId)
        .collection('profileViews')
        .doc(viewerUid);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (snap.exists) {
        tx.update(docRef, {
          'lastViewedAt': FieldValue.serverTimestamp(),
          'totalViews': FieldValue.increment(1),
          'viewer': {
            'uid': viewerUid,
            'name': viewerName,
            'photoUrl': viewerPhotoUrl,
          }
        });
      } else {
        tx.set(docRef, {
          'lastViewedAt': FieldValue.serverTimestamp(),
          'totalViews': 1,
          'viewer': {
            'uid': viewerUid,
            'name': viewerName,
            'photoUrl': viewerPhotoUrl,
          }
        });
      }

      // (Opsiyonel) toplam sayacı artır
      final aggRef = _db
          .collection('users')
          .doc(viewedUserId)
          .collection('aggregates')
          .doc('profileViews');
      final aggSnap = await tx.get(aggRef);
      if (aggSnap.exists) {
        tx.update(aggRef, {'count': FieldValue.increment(1)});
      } else {
        tx.set(aggRef, {'count': 1});
      }
    });
  }

  /// Listeleme (sayfalamalı)
  static Query<Map<String, dynamic>> queryProfileViews(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('profileViews')
        .orderBy('lastViewedAt', descending: true);
  }
}
