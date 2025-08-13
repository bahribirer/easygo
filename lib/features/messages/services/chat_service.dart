import 'dart:async';
import '../models/conversation.dart';
import '../data/fake_conversations.dart';

/// Basit servis katmanı: şu anda fake data kullanıyor.
/// Backend’e geçtiğinde HTTP/Firestore çağrılarına çevir.
class ChatService {
  static final List<Conversation> _db =
      fakeConversations.map((c) => c.copyWith()).toList();

  static Future<List<Conversation>> getConversations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Derin kopya gibi; UI tarafında değişiklik servis datasını hemen bozmasın.
    return _db.map((c) => c.copyWith()).toList();
  }

  static Future<void> togglePin(String id) async {
    final i = _db.indexWhere((c) => c.id == id);
    if (i == -1) return;
    _db[i].pinned = !_db[i].pinned;
    await Future.delayed(const Duration(milliseconds: 150));
  }

  static Future<void> toggleMute(String id) async {
    final i = _db.indexWhere((c) => c.id == id);
    if (i == -1) return;
    _db[i].muted = !_db[i].muted;
    await Future.delayed(const Duration(milliseconds: 150));
  }

  static Future<void> archive(String id) async {
    final i = _db.indexWhere((c) => c.id == id);
    if (i == -1) return;
    _db[i].archived = true;
    await Future.delayed(const Duration(milliseconds: 150));
  }

  static Future<void> unarchive(String id) async {
    final i = _db.indexWhere((c) => c.id == id);
    if (i == -1) return;
    _db[i].archived = false;
    await Future.delayed(const Duration(milliseconds: 150));
  }

  static Future<void> delete(String id) async {
    _db.removeWhere((c) => c.id == id);
    await Future.delayed(const Duration(milliseconds: 150));
  }
}
