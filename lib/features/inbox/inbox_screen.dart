import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easygo/core/inbox_badge.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  /// Belirli bildirimi sil
  Future<void> _deleteOne(DocumentReference ref, bool wasUnread) async {
    await ref.delete();
    if (wasUnread && InboxBadge.notifier.value > 0) {
      InboxBadge.notifier.value = InboxBadge.notifier.value - 1;
    }
  }

  /// Tüm bildirimleri sil
  Future<void> _deleteAll() async {
    if (_userId == null) return;
    final col = FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('notifications');
    final docs = await col.get();
    for (var d in docs.docs) {
      await d.reference.delete();
    }
    InboxBadge.notifier.value = 0;
  }

  /// Hepsini okundu yap
  Future<void> _markAllRead() async {
    if (_userId == null) return;
    final col = FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('notifications');
    final docs = await col.get();
    for (var d in docs.docs) {
      await d.reference.update({'read': true});
    }
    InboxBadge.notifier.value = 0;
  }

  Color _chipColor(String? type) {
    switch (type) {
      case 'friend_request':
        return Colors.orange;
      case 'friend_accept':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _iconFor(String? type) {
    switch (type) {
      case 'friend_request':
        return Icons.person_add_alt;
      case 'friend_accept':
        return Icons.person;
      default:
        return Icons.notifications;
    }
  }

  String _prettyTime(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'şimdi';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} sa önce';
    return '${diff.inDays} gün önce';
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final notifRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gelen Kutusu"),
        actions: [
          IconButton(
            onPressed: _markAllRead,
            icon: const Icon(Icons.done_all),
            tooltip: "Hepsini okundu yap",
          ),
          IconButton(
            onPressed: _deleteAll,
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: "Tümünü sil",
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notifRef.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text("Henüz bildirim yok 💌"));
          }

          final docs = snap.data!.docs;

          // 🔔 unread sayısını InboxBadge’e yaz
          final unread = docs.where((d) => (d['read'] ?? false) == false).length;
          InboxBadge.notifier.value = unread;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final title = data['title'] ?? "easyGO";
              final body = data['body'] ?? "";
              final read = data['read'] ?? false;
              final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

              return Dismissible(
                key: ValueKey(docs[i].id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  color: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) =>
                    _deleteOne(docs[i].reference, !(data['read'] == true)),
                child: ListTile(
                  leading: Icon(
                    _iconFor(data['type']),
                    color: _chipColor(data['type']),
                  ),
                  title: Text(
                    title,
                    style: TextStyle(
                        fontWeight:
                            read ? FontWeight.normal : FontWeight.bold),
                  ),
                  subtitle: Text("$body\n${_prettyTime(createdAt)}"),
                  isThreeLine: true,
                  onTap: () {
                    docs[i].reference.update({'read': true});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
