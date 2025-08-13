import 'package:flutter/material.dart';

import 'package:easygo/features/friends/friend_profile_screen.dart';
import 'package:easygo/features/friends/widgetfriend/friend_tile.dart';
import 'package:easygo/features/friends/widgetfriend/friend_list_widgets.dart';

class FriendsListScreen extends StatefulWidget {
  final List<dynamic> friends;
  const FriendsListScreen({super.key, required this.friends});

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

enum _SortMode { az, za }

class _FriendsListScreenState extends State<FriendsListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  _SortMode _sort = _SortMode.az;

  late List<dynamic> _all;
  List<dynamic> _filtered = [];

  @override
  void initState() {
    super.initState();
    _all = List<dynamic>.from(widget.friends);
    _applyAll();
    _searchCtrl.addListener(_applyAll);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_applyAll);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyAll() {
    final q = _searchCtrl.text.trim().toLowerCase();
    List<dynamic> list = List<dynamic>.from(_all);

    if (q.isNotEmpty) {
      list = list.where((f) {
        final name = (f['name'] ?? '').toString().toLowerCase();
        final email = (f['universityEmail'] ?? '').toString().toLowerCase();
        final location = (f['location'] ?? '').toString().toLowerCase();
        return name.contains(q) || email.contains(q) || location.contains(q);
      }).toList();
    }

    list.sort((a, b) {
      final an = (a['name'] ?? '').toString().toLowerCase();
      final bn = (b['name'] ?? '').toString().toLowerCase();
      final cmp = an.compareTo(bn);
      return _sort == _SortMode.az ? cmp : -cmp;
    });

    setState(() => _filtered = list);
  }

  Future<void> _openFriend(dynamic friend) async {
    final friendId = (friend['_id'] ?? '').toString();

    final removed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => FriendProfileScreen(user: friend)),
    );

    if (removed == true) {
      setState(() {
        _all.removeWhere((f) => (f['_id'] ?? '').toString() == friendId);
      });
      _applyAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arkadaş listeden kaldırıldı.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0E9),
      appBar: AppBar(
        title: const Text('Arkadaş Listesi', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<_SortMode>(
            onSelected: (v) {
              _sort = v;
              _applyAll();
            },
            icon: const Icon(Icons.sort, color: Colors.white),
            itemBuilder: (context) => const [
              PopupMenuItem(value: _SortMode.az, child: Text('A → Z')),
              PopupMenuItem(value: _SortMode.za, child: Text('Z → A')),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // Üst bar: arama + sayaç
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: const BoxDecoration(color: Colors.transparent),
            child: Row(
              children: [
                Expanded(
                  child: FriendSearchBar(
                    controller: _searchCtrl,
                    hint: 'İsim, e-posta veya konum ara',
                  ),
                ),
                const SizedBox(width: 10),
                FriendCountChip(count: _filtered.length),
              ],
            ),
          ),

          // Liste / boş durum
          Expanded(
            child: _filtered.isEmpty
                ? const EmptyFriendsView()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final f = _filtered[index] as Map<String, dynamic>;
                      final id = (f['_id'] ?? index.toString()).toString();
                      return FriendTile(
                        idTag: id,
                        name: f['name'] ?? 'Kullanıcı',
                        email: f['universityEmail'] ?? '',
                        location: f['location'] ?? '',
                        base64Photo: f['profilePhoto'],
                        onTap: () => _openFriend(f),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
