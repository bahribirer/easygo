import 'package:cloud_firestore/cloud_firestore.dart';

/// Cloud Firestore tabanlı sohbet servisi.
/// - chats/{conversationId}
///    - participants: [uidA, uidB]
///    - lastMessage: { text, senderId, createdAt }
///    - unread: { <uidA>: number, <uidB>: number }
///    - updatedAt: Timestamp
///    - messages (subcollection)
///       - { senderId, receiverId, text, attachments, createdAt, readAt }
///    - presence (subcollection)
///       - { userId doc: typing, updatedAt }
class ChatService {
  ChatService._();
  static final _db = FirebaseFirestore.instance;

  /// İki kullanıcıdan deterministik conversation id üretir.
  static String makeConvId(String a, String b) {
    final x = a.compareTo(b) <= 0 ? a : b;
    final y = a.compareTo(b) <= 0 ? b : a;
    return 'chat:$x-$y';
  }

  /// ---- MESAJ AKIŞI (REALTIME) ----
  static Stream<List<Map<String, dynamic>>> messagesStream({
    required String myId,
    required String otherId,
    int limit = 50,
  }) {
    final convId = makeConvId(myId, otherId);
    return _db
        .collection('chats')
        .doc(convId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => {'id': d.id, ...d.data()})
            .toList()
            .reversed
            .toList());
  }

  /// ---- MESAJ GÖNDERME ----
  static Future<void> sendMessage({
    required String myId,
    required String otherId,
    required String text,
    List<Map<String, dynamic>> attachments = const [],
  }) async {
    assert(text.trim().isNotEmpty || attachments.isNotEmpty,
        'Boş mesaj veya eklentisiz mesaj gönderilemez');

    final convId = makeConvId(myId, otherId);
    final chatRef = _db.collection('chats').doc(convId);
    final msgRef = chatRef.collection('messages').doc();

    await _db.runTransaction((tx) async {
      tx.set(msgRef, {
        'senderId': myId,
        'receiverId': otherId,
        'text': text.trim(),
        'attachments': attachments, // [{url,type}]
        'createdAt': FieldValue.serverTimestamp(),
        'readAt': null,
      });

      tx.set(
        chatRef,
        {
          'participants': [myId, otherId],
          'lastMessage': {
            'text': text.trim(),
            'senderId': myId,
            'createdAt': FieldValue.serverTimestamp(),
          },
          'unread': {otherId: FieldValue.increment(1)},
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  /// ---- MESAJLARI OKUNDU İŞARETLEME ----
  static Future<void> markRead({
    required String myId,
    required String otherId,
    int batchLimit = 300,
  }) async {
    final convId = makeConvId(myId, otherId);
    final chatRef = _db.collection('chats').doc(convId);

    final q = await chatRef
        .collection('messages')
        .where('receiverId', isEqualTo: myId)
        .where('readAt', isNull: true)
        .orderBy('createdAt', descending: true)
        .limit(batchLimit)
        .get();

    final batch = _db.batch();
    for (final d in q.docs) {
      batch.update(d.reference, {'readAt': FieldValue.serverTimestamp()});
    }
    // unread sayacımı sıfırla
    batch.set(chatRef, {
      'unread': {myId: 0},
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  /// ---- TYPING / PRESENCE ----
  static Future<void> setTyping({
    required String myId,
    required String otherId,
    required bool typing,
  }) async {
    final convId = makeConvId(myId, otherId);
    final pRef =
        _db.collection('chats').doc(convId).collection('presence').doc(myId);

    await pRef.set({
      'typing': typing,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Stream<bool> otherTypingStream({
    required String myId,
    required String otherId,
  }) {
    final convId = makeConvId(myId, otherId);
    final otherRef = _db
        .collection('chats')
        .doc(convId)
        .collection('presence')
        .doc(otherId);

    return otherRef.snapshots().map((d) {
      final data = d.data();
      if (data == null) return false;
      return (data['typing'] as bool?) ?? false;
    });
  }

  /// ---- KONVERSASYON LİSTESİ (INBOX) ----
  static Stream<List<Map<String, dynamic>>> myConversationsStream(
      String myId) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: myId)
        .orderBy('lastMessage.createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  /// Toplam unread (inbox rozeti) — tüm sohbetlerdeki unread[myId] toplamı.
  static Stream<int> myTotalUnreadStream(String myId) {
    return myConversationsStream(myId).map((convs) {
      int sum = 0;
      for (final c in convs) {
        final unread = (c['unread'] as Map?) ?? {};
        final val = unread[myId];
        if (val is int) sum += val;
      }
      return sum;
    });
  }

  /// ---- SAYFALAMA (CURSOR) İLE GEÇMİŞ ÇEKME (opsiyonel REST benzeri) ----
  static Future<Map<String, dynamic>> historyPage({
    required String myId,
    required String otherId,
    DocumentSnapshot? cursor,
    int limit = 30,
  }) async {
    final convId = makeConvId(myId, otherId);
    Query q = _db
        .collection('chats')
        .doc(convId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (cursor != null) q = (q.startAfterDocument(cursor));

    final snap = await q.get();
    final items = snap.docs
        .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
        .toList();

    return {
      'messages':
          items.reversed.toList(), // kronolojik (eski → yeni) istersen ters çevirme
      'nextCursor': snap.docs.isNotEmpty ? snap.docs.last : null,
    };
  }

  /// ---- MESAJ SİLME (opsiyonel) ----
  static Future<void> deleteMessage({
    required String myId,
    required String otherId,
    required String messageId,
  }) async {
    final convId = makeConvId(myId, otherId);
    final msgRef = _db
        .collection('chats')
        .doc(convId)
        .collection('messages')
        .doc(messageId);

    await msgRef.delete();
    // lastMessage / unread güncellemesini basit bıraktık.
    // Üretimde: eğer son mesaj buyduysa, chats.lastMessage'ı yeniden hesaplamak isteyebilirsin.
  }

  /// ---- KONUŞMAYI SİLME (opsiyonel) ----
  static Future<void> deleteConversation({
    required String myId,
    required String otherId,
  }) async {
    final convId = makeConvId(myId, otherId);
    final chatRef = _db.collection('chats').doc(convId);

    // Mesajları parça parça sil (quota korumak için küçük batch'lerle)
    while (true) {
      final batch = _db.batch();
      final snap = await chatRef
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(300)
          .get();
      if (snap.docs.isEmpty) break;
      for (final d in snap.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }

    // Presence’ları sil
    final presenceSnap =
        await chatRef.collection('presence').limit(50).get();
    if (presenceSnap.docs.isNotEmpty) {
      final batch = _db.batch();
      for (final d in presenceSnap.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }

    // Chat doc’u sil
    await chatRef.delete();
  }
}
