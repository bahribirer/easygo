import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:easygo/core/service/friendService.dart';
import 'package:easygo/features/friends/widgets/status_chip.dart';

class SearchUsersSheet extends StatefulWidget {
  final String currentUserId;
  final List<dynamic> currentFriends;
  final List<dynamic> incomingRequests;

  const SearchUsersSheet({
    super.key,
    required this.currentUserId,
    required this.currentFriends,
    required this.incomingRequests,
  });

  @override
  State<SearchUsersSheet> createState() => _SearchUsersSheetState();
}

class _SearchUsersSheetState extends State<SearchUsersSheet> {
  String query = '';
  List<dynamic> results = [];
  bool searching = false;
  String? error;
  Timer? _debounce;

  // Aynı sheet’te gönderilmişleri işaretle
  final Set<String> _locallySent = {};

  bool _isSelf(Map u) => u['_id'] == widget.currentUserId;
  bool _isAlreadyFriend(Map u) => widget.currentFriends.any((f) => f['_id'] == u['_id']);
  bool _isAlreadyRequested(Map u) {
    final incoming = widget.incomingRequests.any((f) => f['_id'] == u['_id']);
    final local = _locallySent.contains(u['_id']);
    return incoming || local;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _runSearch(String q) async {
    if (q.trim().isEmpty) {
      setState(() {
        results = [];
        error = null;
        searching = false;
      });
      return;
    }
    setState(() {
      searching = true;
      error = null;
    });
    try {
      final res = await FriendService.searchUsers(q.trim());
      setState(() {
        results = (res ?? []) as List<dynamic>;
        searching = false;
      });
    } catch (_) {
      setState(() {
        searching = false;
        error = "Arama sırasında bir hata oluştu.";
      });
    }
  }

  void _onQueryChanged(String val) {
    query = val;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _runSearch(query));
    setState(() {});
  }

  Future<void> _sendReq(Map user) async {
    // kendine istek gönderme
    if (_isSelf(user)) {
      await _infoDialog("Olmaz ki 🙂", "Kendine arkadaşlık isteği gönderemezsin.");
      return;
    }
    try {
      await FriendService.sendRequest(widget.currentUserId, user['_id']);
      _locallySent.add(user['_id']);
      if (mounted) setState(() {});
      await _infoDialog("İstek Gönderildi",
          "${user['name'] ?? 'Kullanıcı'} adlı kullanıcıya arkadaşlık isteği gönderildi.");
    } catch (_) {
      await _infoDialog("Gönderilemedi",
          "İstek gönderilirken bir sorun oluştu. Lütfen tekrar deneyin.");
    }
  }

  Future<void> _infoDialog(String title, String message) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tamam")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 12),

                // Başlık
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.person_search, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        "Kullanıcı Ara",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Arama alanı
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        const Icon(Icons.search, color: Colors.black54),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            onChanged: _onQueryChanged,
                            onSubmitted: (v) => _runSearch(v),
                            decoration: const InputDecoration(
                              hintText: "İsim veya e-posta ile ara",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (query.isNotEmpty)
                          IconButton(
                            tooltip: "Temizle",
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              query = '';
                              results = [];
                              error = null;
                              searching = false;
                              _debounce?.cancel();
                              setState(() {});
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Ara butonu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.search),
                      label: const Text("Ara"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _runSearch(query),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Sonuçlar
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: searching
                        ? const Center(child: CircularProgressIndicator())
                        : (error != null)
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Text(error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                                ),
                              )
                            : (results.isEmpty
                                ? const _EmptyState()
                                : ListView.separated(
                                    controller: scrollController,
                                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                                    itemCount: results.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                                    itemBuilder: (context, i) {
                                      final user = results[i] as Map<String, dynamic>;
                                      final alreadyFriend = _isAlreadyFriend(user);
                                      final alreadyReq = _isAlreadyRequested(user);
                                      final canSend = !alreadyFriend && !alreadyReq && !_isSelf(user);

                                      final photo = user['profilePhoto'];
                                      final name = user['name'] ?? '';
                                      final email = user['universityEmail'] ?? '';
                                      final location = user['location'] ?? '';

                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.grey.shade200),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.03),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          leading: CircleAvatar(
                                            radius: 26,
                                            backgroundImage: (photo != null && photo != '')
                                                ? MemoryImage(base64Decode(photo))
                                                : const AssetImage('assets/profile.jpg') as ImageProvider,
                                          ),
                                          title: Text(
                                            name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(email, maxLines: 1, overflow: TextOverflow.ellipsis),
                                              if ((location as String).isNotEmpty)
                                                Row(
                                                  children: [
                                                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                                    const SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text(
                                                        location,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                          trailing: _isSelf(user)
                                              ? StatusChip("Bu sensin", bg: Colors.grey.shade300)
                                              : canSend
                                                  ? ElevatedButton.icon(
                                                      icon: const Icon(Icons.person_add_alt_1, size: 18),
                                                      label: const Text("Ekle"),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.green,
                                                        foregroundColor: Colors.white,
                                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                      ),
                                                      onPressed: () async => await _sendReq(user),
                                                    )
                                                  : (alreadyFriend
                                                      ? const StatusChip("Zaten arkadaş")
                                                      : const StatusChip("Beklemede")),
                                        ),
                                      );
                                    },
                                  )),
                  ),
                ),

                // Sheet kapatıldığında hangi id’lere istek gönderdik bilgisini geri ver
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context, _locallySent),
                      icon: const Icon(Icons.check),
                      label: const Text("Kapat"),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.black38),
          SizedBox(height: 8),
          Text("Sonuç bulunamadı", style: TextStyle(fontSize: 16, color: Colors.black54)),
        ],
      ),
    );
  }
}
