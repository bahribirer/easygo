import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easygo/friend_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/friendService.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<dynamic> friendRequests = [];
  List<dynamic> friends = [];
  String? userId;
  bool isLoading = true;

  // --- Arama pop-up için ek state ---
  Timer? _debounce;
  final Set<String> _locallySent = {}; // aynı oturumda yinelenen istekleri engelle

  // --- Eylem butonları için busy state ---
  final Set<String> _acceptBusy = {};
  final Set<String> _rejectBusy = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    if (userId == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final data = await FriendService.getFriendData(userId!);

      // Debug için:
      // print("📦 Gelen Arkadaş Verisi:");
      // print(jsonEncode(data));

      if (!mounted) return;
      setState(() {
        friendRequests = data['friendRequests'] ?? [];
        friends = data['friends'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showResultDialog("Hata", "Veriler alınırken bir sorun oluştu. Lütfen tekrar deneyin.");
    }
  }

  Future<void> handleAccept(String fromUserId) async {
    if (userId == null) return;
    setState(() => _acceptBusy.add(fromUserId));
    try {
      await FriendService.acceptRequest(userId!, fromUserId);
      await fetchData();
      if (!mounted) return;
      _showResultDialog("Arkadaş Oldunuz", "İstek kabul edildi.");
    } catch (e) {
      _showResultDialog("Hata", "İstek kabul edilemedi.");
    } finally {
      if (mounted) setState(() => _acceptBusy.remove(fromUserId));
    }
  }

  Future<void> handleReject(String fromUserId) async {
    if (userId == null) return;
    setState(() => _rejectBusy.add(fromUserId));
    try {
      await FriendService.rejectRequest(userId!, fromUserId);
      await fetchData();
      if (!mounted) return;
      _showResultDialog("Reddedildi", "İstek reddedildi.");
    } catch (e) {
      _showResultDialog("Hata", "İstek reddedilemedi.");
    } finally {
      if (mounted) setState(() => _rejectBusy.remove(fromUserId));
    }
  }

  // ---- Yardımcı UI parçaları ----
  Widget _statusChip(String label, {Color? bg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
    );
  }

  Future<void> _showResultDialog(String title, String message) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tamam"),
          ),
        ],
      ),
    );
  }

  // ---- PROFESYONEL ARAMA POP-UP ----
  void showSearchDialog() {
    String query = '';
    List<dynamic> results = [];
    bool searching = false;
    String? error;
    bool isSelf(Map u) => userId != null && u['_id'] == userId;


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                Future<void> runSearch(String q) async {
                  if (q.trim().isEmpty) {
                    setModalState(() {
                      results = [];
                      error = null;
                      searching = false;
                    });
                    return;
                  }
                  setModalState(() {
                    searching = true;
                    error = null;
                  });
                  try {
                    final res = await FriendService.searchUsers(q.trim());
                    setModalState(() {
                      results = (res ?? []) as List<dynamic>;
                      searching = false;
                    });
                  } catch (e) {
                    setModalState(() {
                      searching = false;
                      error = "Arama sırasında bir hata oluştu.";
                    });
                  }
                }

                void onQueryChanged(String val) {
                  query = val;
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 400), () {
                    runSearch(query);
                  });
                  setModalState(() {});
                }

                bool isAlreadyFriend(Map u) =>
                    friends.any((f) => f['_id'] == u['_id']);

                bool isAlreadyRequested(Map u) {
                  final incoming = friendRequests.any((f) => f['_id'] == u['_id']);
                  final local = _locallySent.contains(u['_id']);
                  return incoming || local;
                }

                Future<void> sendReq(Map user) async {
  if (userId == null) return;

  // ⛔ kendine istek gönderme
  if (isSelf(user)) {
    await _showResultDialog("Olmaz ki 🙂", "Kendine arkadaşlık isteği gönderemezsin.");
    return;
  }

  try {
    await FriendService.sendRequest(userId!, user['_id']);
    _locallySent.add(user['_id']);
    setModalState(() {});
    await _showResultDialog(
      "İstek Gönderildi",
      "${user['name']} adlı kullanıcıya arkadaşlık isteği gönderildi.",
    );
  } catch (e) {
    await _showResultDialog(
      "Gönderilemedi",
      "İstek gönderilirken bir sorun oluştu. Lütfen tekrar deneyin.",
    );
  }
}


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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: const [
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
                                    onChanged: onQueryChanged,
                                    onSubmitted: (v) => runSearch(v),
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
                                      setModalState(() {});
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
                              onPressed: () => runSearch(query),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Sonuçlar / durumlar
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: searching
                                ? const Center(child: CircularProgressIndicator())
                                : (error != null)
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 24),
                                          child: Text(
                                            error!,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      )
                                    : (results.isEmpty
                                        ? Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                Icon(Icons.search_off, size: 48, color: Colors.black38),
                                                SizedBox(height: 8),
                                                Text(
                                                  "Sonuç bulunamadı",
                                                  style: TextStyle(fontSize: 16, color: Colors.black54),
                                                ),
                                              ],
                                            ),
                                          )
                                        : ListView.separated(
                                            controller: scrollController,
                                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                                            itemCount: results.length,
                                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                                            itemBuilder: (context, i) {
                                              final user = results[i] as Map<String, dynamic>;
                                              final alreadyFriend = isAlreadyFriend(user);
                                              final alreadyReq = isAlreadyRequested(user);
                                              final canSend = !alreadyFriend && !alreadyReq && !isSelf(user); // ⬅️ kendin değilse
                                              

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
                                                  
                                                  trailing: isSelf(user)
    ? _statusChip("Bu sensin", bg: Colors.grey.shade300)
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
            onPressed: () async => await sendReq(user),
          )
        : (alreadyFriend ? _statusChip("Zaten arkadaş") : _statusChip("Beklemede")),

                                                ),
                                              );
                                            },
                                          )),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    ).whenComplete(() {
      _debounce?.cancel();
    });
  }

  // ---- Özet kartları ----
  Widget _summaryCards() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: "Arkadaş",
            value: friends.length.toString(),
            icon: Icons.people_alt_rounded,
            gradient: const [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: "İstek",
            value: friendRequests.length.toString(),
            icon: Icons.person_add_alt_1,
            gradient: const [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
          ),
        ),
      ],
    );
  }

  // ---- İstek listesi bölümü ----
  Widget buildRequestSection() {
    if (friendRequests.isEmpty) {
      return _SectionCard(
        title: "Arkadaşlık İstekleri",
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: const [
              Icon(Icons.mark_email_unread_outlined, size: 40, color: Colors.black38),
              SizedBox(height: 8),
              Text("Şu an bekleyen isteğin yok.", style: TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      );
    }

    return _SectionCard(
      title: "Arkadaşlık İstekleri",
      trailing: _statusChip("${friendRequests.length} beklemede", bg: Colors.orange.shade100),
      child: SizedBox(
        height: 170,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: friendRequests.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final req = friendRequests[index];
            final location = (req['location'] ?? '') as String;
            final name = (req['name'] ?? '') as String;
            final id = req['_id'] as String;

            final busyAccept = _acceptBusy.contains(id);
            final busyReject = _rejectBusy.contains(id);

            return Container(
              width: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFFfdfbfb), Color(0xFFebedee)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: (req['profilePhoto'] != null && req['profilePhoto'] != '')
                        ? MemoryImage(base64Decode(req['profilePhoto']))
                        : const AssetImage('assets/profile.jpg') as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          if (location.isNotEmpty)
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: busyAccept ? null : () => handleAccept(id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: busyAccept
                                      ? const SizedBox(
                                          width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : const Text("Kabul"),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: busyReject ? null : () => handleReject(id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: busyReject
                                      ? const SizedBox(
                                          width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : const Text("Reddet"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ---- Arkadaş grid’i ----
  Widget buildFriendGrid() {
    if (friends.isEmpty) {
      return _SectionCard(
        title: "Arkadaşlar",
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Column(
            children: [
              const Icon(Icons.people_outline, size: 44, color: Colors.black38),
              const SizedBox(height: 8),
              const Text("Henüz arkadaşın yok gibi görünüyor.", style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: showSearchDialog,
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text("Arkadaş Bul"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _SectionCard(
      title: "Arkadaşlar",
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          final photo = friend['profilePhoto'];
          final name = friend['name'] ?? '';
          final location = friend['location'] ?? '';

          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FriendProfileScreen(user: friend),
                ),
              );
              if (result == true) {
                await fetchData();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFBE6E0), Color(0xFFFFD6CB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Hero(
                    tag: "friend_${friend['_id']}",
                    child: CircleAvatar(
                      radius: 38,
                      backgroundImage: (photo != null && photo != '')
                          ? MemoryImage(base64Decode(photo))
                          : const AssetImage('assets/profile.jpg') as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          location,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---- Scaffold ----
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0E9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Arkadaşlar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            SizedBox(height: 2),
            Text('Bağlantılarını yönet', style: TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
        
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: fetchData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _summaryCards(),
                      const SizedBox(height: 20),
                      buildRequestSection(),
                      const SizedBox(height: 20),
                      buildFriendGrid(),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showSearchDialog,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text("Arkadaş Ekle"),
      ),
    );
  }
}

/* ----------------- Küçük, yeniden kullanılabilir kart bileşenleri ----------------- */

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.85),
            child: Icon(icon, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
