import 'dart:convert';
import 'package:easygo/friend_profile_screen.dart';
import 'package:flutter/material.dart';

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

  // 🔧 Kaynak veri burada tutuluyor (widget.friends kopyası)
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
    List<dynamic> list = List<dynamic>.from(_all); // ✅ _all üzerinden çalış

    // filter
    if (q.isNotEmpty) {
      list = list.where((f) {
        final name = (f['name'] ?? '').toString().toLowerCase();
        final email = (f['universityEmail'] ?? '').toString().toLowerCase();
        final location = (f['location'] ?? '').toString().toLowerCase();
        return name.contains(q) || email.contains(q) || location.contains(q);
      }).toList();
    }

    // sort
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
      // ✅ Yerel kaynaktan sil, filtreyi tazele
      setState(() {
        _all.removeWhere((f) => (f['_id'] ?? '').toString() == friendId);
      });
      _applyAll();

      // küçük bir geri bildirim
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Arkadaş listeden kaldırıldı.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0E9),
      appBar: AppBar(
        title: const Text("Arkadaş Listesi", style: TextStyle(color: Colors.white)),
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
              PopupMenuItem(value: _SortMode.az, child: Text("A → Z")),
              PopupMenuItem(value: _SortMode.za, child: Text("Z → A")),
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
                // Search field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        const Icon(Icons.search, color: Colors.black54),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            decoration: const InputDecoration(
                              hintText: "İsim, e-posta veya konum ara",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (_searchCtrl.text.isNotEmpty)
                          IconButton(
                            tooltip: "Temizle",
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchCtrl.clear();
                              FocusScope.of(context).unfocus();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _CountChip(count: _filtered.length),
              ],
            ),
          ),

          // Liste / Boş durum
          Expanded(
            child: _filtered.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final friend = _filtered[index];
                      final id = (friend['_id'] ?? index.toString()).toString();
                      final name = friend['name'] ?? 'Kullanıcı';
                      final email = friend['universityEmail'] ?? '';
                      final location = friend['location'] ?? '';
                      final photo = friend['profilePhoto'];

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _openFriend(friend), // ✅ sonucu bekleyen fonksiyon
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              Hero(
                                tag: "friend_$id",
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundImage: (photo != null && photo.toString().isNotEmpty)
                                      ? MemoryImage(base64Decode(photo))
                                      : const AssetImage('assets/profile.jpg') as ImageProvider,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                    ),
                                    const SizedBox(height: 2),
                                    if (email.toString().isNotEmpty)
                                      Text(
                                        email,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.black54, fontSize: 13),
                                      ),
                                    if (location.toString().isNotEmpty)
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              location,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(color: Colors.black54, fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black45),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/* ================== küçük widgetlar ================== */

class _CountChip extends StatelessWidget {
  final int count;
  const _CountChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Text(
        "$count kişi",
        style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.people_outline, size: 64, color: Colors.black38),
            SizedBox(height: 12),
            Text("Hiç arkadaş yok.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text(
              "Arama bölümünden kullanıcıları bulup arkadaş ekleyebilirsin.",
              style: TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
