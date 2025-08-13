import 'package:flutter/material.dart';
import 'models/conversation.dart';
import 'services/chat_service.dart';
import 'widgets/widgets.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

enum _Filter { all, unread, archived }

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final List<Conversation> _all = [];
  List<Conversation> _view = [];
  bool _loading = true;
  String? _error;
  _Filter _filter = _Filter.all;

  @override
  void initState() {
    super.initState();
    _bootstrap();
    _searchCtrl.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final data = await ChatService.getConversations();
      _all
        ..clear()
        ..addAll(data);

      _applyFilters();
    } catch (_) {
      setState(() => _error = 'Konuşmalar yüklenirken sorun oluştu.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async => _bootstrap();

  void _applyFilters() {
    final q = _searchCtrl.text.trim().toLowerCase();
    List<Conversation> list = List.of(_all);

    switch (_filter) {
      case _Filter.unread:
        list = list.where((c) => c.unreadCount > 0 && !c.archived).toList();
        break;
      case _Filter.archived:
        list = list.where((c) => c.archived).toList();
        break;
      case _Filter.all:
        list = list.where((c) => !c.archived).toList();
        break;
    }

    if (q.isNotEmpty) {
      list = list
          .where((c) =>
              c.title.toLowerCase().contains(q) ||
              c.lastMessage.toLowerCase().contains(q))
          .toList();
    }

    list.sort((a, b) {
      if (a.pinned != b.pinned) return b.pinned ? 1 : -1;
      return b.lastMessageAt.compareTo(a.lastMessageAt);
    });

    setState(() => _view = list);
  }

  void _onChangeFilter(_Filter f) {
    setState(() => _filter = f);
    _applyFilters();
  }

  Future<void> _togglePin(Conversation c) async {
    setState(() => c.pinned = !c.pinned);
    await ChatService.togglePin(c.id);
    _applyFilters();
  }

  Future<void> _toggleMute(Conversation c) async {
    setState(() => c.muted = !c.muted);
    await ChatService.toggleMute(c.id);
  }

  Future<void> _archive(Conversation c) async {
    setState(() => c.archived = true);
    await ChatService.archive(c.id);
    _applyFilters();
  }

  Future<void> _unarchive(Conversation c) async {
    setState(() => c.archived = false);
    await ChatService.unarchive(c.id);
    _applyFilters();
  }

  Future<void> _delete(Conversation c) async {
    setState(() => _all.removeWhere((x) => x.id == c.id));
    await ChatService.delete(c.id);
    _applyFilters();
  }

  void _openChat(Conversation c) {
    // TODO: Navigator.push to ChatScreen(conversationId: c.id)
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Sohbet açılıyor: ${c.title}')));
  }

  void _startNewChat() {
    // TODO: kullanıcı/friend seçimi sayfasına yönlendir
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Yeni mesaj başlat')));
  }

  int get _totalUnread => _all
      .where((c) => c.unreadCount > 0 && !c.archived)
      .fold(0, (p, c) => p + c.unreadCount);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? Theme.of(context).colorScheme.surface
        : const Color(0xFFFDF3E5);
    final accent = Colors.red.shade600;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: accent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mesajlar',
          style: TextStyle(color: accent, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Yeni Mesaj',
            onPressed: _startNewChat,
            icon: Icon(Icons.edit_square, color: accent),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startNewChat,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Mesaj'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(
              children: [
                Text('Arkadaşlar',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w800,
                    )),
                const Spacer(),
                SmallPill(text: '$_totalUnread okunmamış'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: MessagesSearchBar(controller: _searchCtrl),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Row(
              children: [
                FilterChipX(
                  label: 'Tümü',
                  selected: _filter == _Filter.all,
                  onTap: () => _onChangeFilter(_Filter.all),
                ),
                FilterChipX(
                  label: 'Okunmamış',
                  selected: _filter == _Filter.unread,
                  onTap: () => _onChangeFilter(_Filter.unread),
                ),
                FilterChipX(
                  label: 'Arşiv',
                  selected: _filter == _Filter.archived,
                  onTap: () => _onChangeFilter(_Filter.archived),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              width: double.infinity,
              child: _buildBody(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => const ShimmerTile(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 40, color: Colors.grey),
              const SizedBox(height: 10),
              Text(_error!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: _bootstrap,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    if (_view.isEmpty) {
      return MessagesEmptyState(
        title:
            _filter == _Filter.archived ? 'Arşivde konuşma yok' : 'Henüz mesaj yok',
        subtitle: _filter == _Filter.archived
            ? 'Arşivlediğin konuşmalar burada görünecek.'
            : 'Arkadaşlarınla sohbet etmeye başla.',
        actionText: 'Yeni Mesaj',
        onAction: _startNewChat,
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        itemCount: _view.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final c = _view[index];
          return Dismissible(
            key: ValueKey('conv-${c.id}'),
            background:
                const SwipeBG(icon: Icons.archive_outlined, text: 'Arşivle'),
            secondaryBackground: const SwipeBG(
              icon: Icons.delete_outline,
              text: 'Sil',
              alignEnd: true,
            ),
            confirmDismiss: (dir) async {
              if (dir == DismissDirection.startToEnd) {
                await _archive(c);
                return true;
              } else {
                final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Sohbeti sil?'),
                        content: Text(
                            '"${c.title}" sohbetini kalıcı olarak silmek istediğine emin misin?'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: const Text('Vazgeç'),
                          ),
                          FilledButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: const Text('Sil'),
                          ),
                        ],
                      ),
                    ) ??
                    false;
                if (ok) await _delete(c);
                return ok;
              }
            },
            child: ConversationTile(
              c: c,
              onTap: () => _openChat(c),
              onLongPress: () => _openTileMenu(context, c),
              onMoreTap: () => _openTileMenu(context, c),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openTileMenu(BuildContext context, Conversation c) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BottomAction(
              icon: c.pinned ? Icons.push_pin : Icons.push_pin_outlined,
              label: c.pinned ? 'Sabitlemeyi kaldır' : 'Sabitle',
              onTapValue: 'pin',
            ),
            BottomAction(
              icon: c.muted ? Icons.notifications_off : Icons.notifications,
              label: c.muted ? 'Sessizden çıkar' : 'Sessize al',
              onTapValue: 'mute',
            ),
            if (!c.archived)
              const BottomAction(
                icon: Icons.archive_outlined,
                label: 'Arşivle',
                onTapValue: 'archive',
              )
            else
              const BottomAction(
                icon: Icons.unarchive_outlined,
                label: 'Arşivden çıkar',
                onTapValue: 'unarchive',
              ),
            const BottomAction(
              icon: Icons.delete_outline,
              label: 'Sil',
              destructive: true,
              onTapValue: 'delete',
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    switch (result) {
      case 'pin':
        _togglePin(c);
        break;
      case 'mute':
        _toggleMute(c);
        break;
      case 'archive':
        _archive(c);
        break;
      case 'unarchive':
        _unarchive(c);
        break;
      case 'delete':
        _delete(c);
        break;
    }
  }
}
