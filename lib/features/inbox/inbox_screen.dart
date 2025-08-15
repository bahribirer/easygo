import 'package:flutter/material.dart';
import 'package:easygo/core/service/notification_service.dart';
import 'package:easygo/core/service/socket_service.dart';
import 'package:easygo/core/inbox_badge.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  List<dynamic> _notifications = [];
  bool _loading = true;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _loadList();
    final socket = await SocketService.connect();

    socket.on('notification', (data) {
      if (!mounted) return;
      setState(() {
        _notifications.insert(0, {
          '_id': data['id'],
          'type': data['type'],
          'fromUserId': data['fromUserId'],
          'message': data['message'],
          'createdAt': data['createdAt'],
          'isRead': false,
        });
      });
      InboxBadge.notifier.value = InboxBadge.notifier.value + 1;

      _showInfoSheet('Yeni bildirim', data['message']?.toString() ?? '');
    });
  }

  Future<void> _loadList() async {
    final list = await NotificationService.getNotifications();
    if (!mounted) return;
    setState(() {
      _notifications = list;
      _loading = false;
    });
  }

  Future<void> _onRefresh() async {
    setState(() => _refreshing = true);
    await _loadList();
    setState(() => _refreshing = false);
  }

  Future<void> _markAllRead() async {
    await NotificationService.markAllRead();
    if (!mounted) return;
    setState(() {
      for (final n in _notifications) {
        n['isRead'] = true;
      }
    });
    InboxBadge.notifier.value = 0;
    _showSuccessSheet('Hepsi okundu olarak işaretlendi');
  }

    Future<void> _deleteOne(int index) async {
    final item = _notifications[index];
    final wasUnread = !(item['isRead'] == true);

    try {
      await NotificationService.deleteNotification(item['_id']); // ✅ Tekli silme
    } catch (_) {
      // Backend yoksa local silmeye devam
    }

    setState(() {
      _notifications.removeAt(index);
    });

    if (wasUnread && InboxBadge.notifier.value > 0) {
      InboxBadge.notifier.value = InboxBadge.notifier.value - 1;
    }

    _showSuccessSheet('Bildirim silindi');
  }

  Future<void> _deleteAll() async {
    try {
      await NotificationService.deleteAll(); // ✅ Backend toplu silme
    } catch (_) {
      // Backend yoksa local temizler
    }

    setState(() => _notifications.clear());
    InboxBadge.notifier.value = 0;
    _showSuccessSheet('Tüm bildirimler temizlendi');
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

  String _prettyTime(String raw) {
    try {
      final dt = DateTime.tryParse(raw);
      if (dt == null) return '';
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'şimdi';
      if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
      if (diff.inHours < 24) return '${diff.inHours} sa önce';
      return '${diff.inDays} gün önce';
    } catch (_) {
      return '';
    }
  }

  void _showNotificationPopup(Map<String, dynamic> n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _BottomSheetContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_iconFor(n['type']), size: 40, color: _chipColor(n['type'])),
              const SizedBox(height: 12),
              Text(
                n['message'] ?? '',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _prettyTime(n['createdAt'] ?? ''),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                      onPressed: () {
                        Navigator.pop(context);
                        final idx = _notifications.indexOf(n);
                        if (idx >= 0) _deleteOne(idx);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Sil'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check),
                      label: const Text('Tamam'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessSheet(String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.teal, size: 44),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tamam'),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoSheet(String title, String message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_active, color: Colors.deepOrange, size: 44),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Gördüm'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    NotificationService.markAllRead();
    InboxBadge.notifier.value = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        color: theme.colorScheme.surface,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _onRefresh,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Üst bar
                    SliverAppBar(
                      backgroundColor: Colors.deepOrange,
                      pinned: true,
                      expandedHeight: 96,
                      flexibleSpace: const FlexibleSpaceBar(
                        titlePadding: EdgeInsets.only(left: 16, bottom: 12),
                        title: Text('Gelen Kutusu'),
                      ),
                    ),

                    // Aksiyon butonları
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _markAllRead,
                                icon: const Icon(Icons.done_all),
                                label: const Text('Hepsini Okundu Yap'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(backgroundColor: Colors.teal),
                                onPressed: _onRefresh,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Yenile'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Hepsini temizle butonu (varsa)
                    if (_notifications.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () async {
                                final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Tümünü sil'),
                                        content: const Text('Tüm bildirimleri silmek istiyor musun?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
                                          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil')),
                                        ],
                                      ),
                                    ) ??
                                    false;
                                if (ok) _deleteAll();
                              },
                              icon: const Icon(Icons.delete_sweep_outlined),
                              label: const Text('Hepsini Temizle'),
                            ),
                          ),
                        ),
                      ),

                    // Liste veya boş durum
                    if (_notifications.isEmpty)
                      // Boş durum: alttan doldursun, güzel dursun
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyState(onRefresh: _onRefresh),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final n = _notifications[index];
                            final isUnread = !(n['isRead'] == true);
                            final type = n['type'] as String?;
                            final createdAt = (n['createdAt'] ?? '').toString();

                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Dismissible(
                                key: ValueKey(n['_id'] ?? '$index-${n['message']}'),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade400,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                confirmDismiss: (_) async {
                                  return await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('Silinsin mi?'),
                                          content: const Text('Bu bildirimi silmek istiyor musun?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Vazgeç'),
                                            ),
                                            FilledButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Sil'),
                                            ),
                                          ],
                                        ),
                                      ) ??
                                      false;
                                },
                                onDismissed: (_) => _deleteOne(index),
                                child: GestureDetector(
                                  onTap: () => _showNotificationPopup(n),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: isUnread ? 4 : 1,
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      leading: CircleAvatar(
                                        radius: 24,
                                        backgroundColor: _chipColor(type).withOpacity(0.15),
                                        child: Icon(_iconFor(type), color: _chipColor(type), size: 24),
                                      ),
                                      title: Text(
                                        (n['message'] ?? '') as String,
                                        style: TextStyle(
                                          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Text(
                                        _prettyTime(createdAt),
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                        onPressed: () => _deleteOne(index),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: _notifications.length,
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Ortak modern bottom sheet container
class _BottomSheetContainer extends StatelessWidget {
  final Widget child;
  const _BottomSheetContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.15),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(top: false, child: child),
    );
  }
}

/// Şık boş durum bileşeni
class _EmptyState extends StatelessWidget {
  final Future<void> Function() onRefresh;
  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: Colors.black38),
            const SizedBox(height: 12),
            const Text(
              'Henüz bildirimin yok',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Yeni bildirimler burada görünecek.\nYenilemek için aşağı kaydırabilirsin.',
              style: TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Yenile'),
            ),
          ],
        ),
      ),
    );
  }
}
