import 'dart:async';
import 'package:flutter/material.dart';

/// =========================
///  MessagesScreen (Pro)
/// =========================
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

      // TODO: Burayı backend’e bağla (ör. ChatService.getConversations(userId))
      await Future.delayed(const Duration(milliseconds: 800));
      _all
        ..clear()
        ..addAll(fakeConversations);

      _applyFilters();
    } catch (e) {
      setState(() => _error = 'Konuşmalar yüklenirken sorun oluştu.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    await _bootstrap();
  }

  void _applyFilters() {
    final q = _searchCtrl.text.trim().toLowerCase();
    List<Conversation> list = List.of(_all);

    // filter tab
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

    // search
    if (q.isNotEmpty) {
      list = list
          .where((c) =>
              c.title.toLowerCase().contains(q) ||
              c.lastMessage.toLowerCase().contains(q))
          .toList();
    }

    // sort: pinned first, then lastMessageAt desc
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
    // TODO: backend -> update pin
  }

  Future<void> _toggleMute(Conversation c) async {
    setState(() => c.muted = !c.muted);
    // TODO: backend -> update mute
  }

  Future<void> _archive(Conversation c) async {
    setState(() => c.archived = true);
    // TODO: backend -> archive
    _applyFilters();
  }

  Future<void> _unarchive(Conversation c) async {
    setState(() => c.archived = false);
    // TODO: backend -> unarchive
    _applyFilters();
  }

  Future<void> _delete(Conversation c) async {
    // TODO: backend -> delete conversation
    setState(() => _all.removeWhere((x) => x.id == c.id));
    _applyFilters();
  }

  void _openChat(Conversation c) {
    // TODO: Navigator.push to ChatScreen(conversationId: c.id)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sohbet açılıyor: ${c.title}')),
    );
  }

  void _startNewChat() {
    // TODO: kullanıcı/friend seçimi sayfasına yönlendir
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yeni mesaj başlat')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Theme.of(context).colorScheme.surface : const Color(0xFFFDF3E5);
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
          // Section title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(
              children: [
                Text(
                  'Arkadaşlar',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                _SmallPill(text: '$_totalUnread okunmamış'),
              ],
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: _SearchBar(controller: _searchCtrl),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Row(
              children: [
                _FilterChipX(
                  label: 'Tümü',
                  selected: _filter == _Filter.all,
                  onTap: () => _onChangeFilter(_Filter.all),
                ),
                _FilterChipX(
                  label: 'Okunmamış',
                  selected: _filter == _Filter.unread,
                  onTap: () => _onChangeFilter(_Filter.unread),
                ),
                _FilterChipX(
                  label: 'Arşiv',
                  selected: _filter == _Filter.archived,
                  onTap: () => _onChangeFilter(_Filter.archived),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              width: double.infinity,
              child: _buildBody(context),
            ),
          ),
        ],
      ),
    );
  }

  int get _totalUnread => _all.where((c) => c.unreadCount > 0 && !c.archived).fold(0, (p, c) => p + c.unreadCount);

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => const _ShimmerTile(),
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
              Text(
                _error!,
                style: const TextStyle(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
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
      return _EmptyState(
        title: _filter == _Filter.archived
            ? 'Arşivde konuşma yok'
            : 'Henüz mesaj yok',
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
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        itemCount: _view.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final c = _view[index];

          return Dismissible(
            key: ValueKey('conv-${c.id}'),
            background: _SwipeBG(icon: Icons.archive_outlined, text: 'Arşivle'),
            secondaryBackground: _SwipeBG(
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
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Vazgeç')),
                          FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Sil')),
                        ],
                      ),
                    ) ??
                    false;
                if (ok) await _delete(c);
                return ok;
              }
            },
            child: _ConversationTile(
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
            _BottomAction(
              icon: c.pinned ? Icons.push_pin : Icons.push_pin_outlined,
              label: c.pinned ? 'Sabitlemeyi kaldır' : 'Sabitle',
              onTapValue: 'pin',
            ),
            _BottomAction(
              icon: c.muted ? Icons.notifications_off : Icons.notifications,
              label: c.muted ? 'Sessizden çıkar' : 'Sessize al',
              onTapValue: 'mute',
            ),
            if (!c.archived)
              _BottomAction(
                icon: Icons.archive_outlined,
                label: 'Arşivle',
                onTapValue: 'archive',
              )
            else
              _BottomAction(
                icon: Icons.unarchive_outlined,
                label: 'Arşivden çıkar',
                onTapValue: 'unarchive',
              ),
            _BottomAction(
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

/// =========================
///  UI Components
/// =========================

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: Theme.of(context).dividerColor),
    );
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Ara (kişi, mesaj)',
        prefixIcon: const Icon(Icons.search),
        isDense: true,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}

class _FilterChipX extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChipX({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? Theme.of(context).colorScheme.primary.withOpacity(.12)
        : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(.4);
    final fg = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  final String text;
  const _SmallPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SwipeBG extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool alignEnd;
  const _SwipeBG({required this.icon, required this.text, this.alignEnd = false});

  @override
  Widget build(BuildContext context) {
    final align = alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start;
    return Container(
      decoration: BoxDecoration(
        color: alignEnd
            ? Theme.of(context).colorScheme.errorContainer
            : Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: align,
        children: [
          if (alignEnd) const SizedBox(width: 8),
          Icon(icon),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          if (!alignEnd) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation c;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onMoreTap;
  const _ConversationTile({
    required this.c,
    required this.onTap,
    required this.onLongPress,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final time = _formatTime(c.lastMessageAt);
    final muted = c.muted;
    final pinned = c.pinned;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(.5)),
          ),
          child: Row(
            children: [
              _AvatarWithStatus(imageUrl: c.avatarUrl, online: c.online),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  c.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (pinned) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.push_pin, size: 16),
                              ],
                              if (muted) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.notifications_off, size: 16),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (c.unreadCount > 0)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${c.unreadCount}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  IconButton(
                    onPressed: onMoreTap,
                    icon: const Icon(Icons.more_vert),
                    splashRadius: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);
    if (d == today) {
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }
    // kısa tarih
    return '${dt.day}.${dt.month}.${dt.year}';
    // istersen haftalık kısaltma vb. ekleyebiliriz
  }
}

class _AvatarWithStatus extends StatelessWidget {
  final String? imageUrl;
  final bool online;
  const _AvatarWithStatus({this.imageUrl, required this.online});

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: 26,
      backgroundImage:
          imageUrl != null && imageUrl!.isNotEmpty ? NetworkImage(imageUrl!) : null,
      child: (imageUrl == null || imageUrl!.isEmpty)
          ? const Icon(Icons.person_outline)
          : null,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          bottom: -1,
          right: -1,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: online ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String onTapValue;
  final bool destructive;
  const _BottomAction({
    required this.icon,
    required this.label,
    required this.onTapValue,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      onTap: () => Navigator.pop(context, onTapValue),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback onAction;
  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 56),
            const SizedBox(height: 12),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: 14),
            FilledButton.tonal(onPressed: onAction, child: Text(actionText)),
          ],
        ),
      ),
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile();

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(.6);
    return Container(
      height: 78,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(.5)),
        color: base,
      ),
    );
  }
}

/// =========================
///  Data Model & Fake Data
/// =========================

class Conversation {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime lastMessageAt;
  final String? avatarUrl;
  int unreadCount;
  bool online;
  bool archived;
  bool muted;
  bool pinned;

  Conversation({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.lastMessageAt,
    this.avatarUrl,
    this.unreadCount = 0,
    this.online = false,
    this.archived = false,
    this.muted = false,
    this.pinned = false,
  });
}

// Demo veriler — backend’e bağlayana kadar
final List<Conversation> fakeConversations = [
  Conversation(
    id: '1',
    title: 'Alper',
    lastMessage: 'Akşama buluşuyor muyuz?',
    lastMessageAt: DateTime.now().subtract(const Duration(minutes: 5)),
    unreadCount: 2,
    online: true,
    avatarUrl: '',
    pinned: true,
  ),
  Conversation(
    id: '2',
    title: 'Proje Grubu',
    lastMessage: 'Mock dataseti drive’a ekledim.',
    lastMessageAt: DateTime.now().subtract(const Duration(minutes: 42)),
    unreadCount: 0,
    online: false,
    avatarUrl: '',
  ),
  Conversation(
    id: '3',
    title: 'Mentörüm',
    lastMessage: 'Pitch deck’e KPI bölümü ekle.',
    lastMessageAt: DateTime.now().subtract(const Duration(hours: 3)),
    unreadCount: 1,
    online: false,
    avatarUrl: '',
    muted: true,
  ),
  Conversation(
    id: '4',
    title: 'Ailem',
    lastMessage: 'Fotoğrafları gönderdim.',
    lastMessageAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    unreadCount: 0,
    online: true,
    avatarUrl: '',
  ),
  Conversation(
    id: '5',
    title: 'Deneme (Arşiv)',
    lastMessage: 'Bunu arşivde tutalım.',
    lastMessageAt: DateTime.now().subtract(const Duration(days: 3)),
    unreadCount: 0,
    online: false,
    archived: true,
  ),
];
