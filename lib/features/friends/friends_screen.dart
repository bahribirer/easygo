import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:easygo/features/friends/friend_profile_screen.dart';
import 'package:easygo/core/service/friendService.dart'; // <- yolunu projene göre ayarla
import 'package:easygo/features/friends/widgets/section_card.dart';
import 'package:easygo/features/friends/widgets/stat_card.dart';
import 'package:easygo/features/friends/widgets/status_chip.dart';
import 'package:easygo/features/friends/widgets/search_users_sheet.dart';

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

  // Eylem butonları için busy state
  final Set<String> _acceptBusy = {};
  final Set<String> _rejectBusy = {};

  // Aynı oturumda tekrar arama sheet’inde gönderilen istekleri işaretlemek için
  final Set<String> _locallySent = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    if (userId == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final data = await FriendService.getFriendData(userId!);
      if (!mounted) return;
      setState(() {
        friendRequests = data['friendRequests'] ?? [];
        friends = data['friends'] ?? [];
        isLoading = false;
      });
    } catch (_) {
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
    } catch (_) {
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
    } catch (_) {
      _showResultDialog("Hata", "İstek reddedilemedi.");
    } finally {
      if (mounted) setState(() => _rejectBusy.remove(fromUserId));
    }
  }

  Future<void> _showResultDialog(String title, String message) async {
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

  Future<void> _openSearchSheet() async {
    if (userId == null) return;
    final sent = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SearchUsersSheet(
        currentUserId: userId!,
        currentFriends: friends,
        incomingRequests: friendRequests,
      ),
    );

    if (sent != null && sent.isNotEmpty) {
      _locallySent.addAll(sent);
      await fetchData();
    }
  }

  // ---- Özet kartları ----
  Widget _summaryCards() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: "Arkadaş",
            value: friends.length.toString(),
            icon: Icons.people_alt_rounded,
            gradient: const [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
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
  Widget _buildRequestSection() {
    if (friendRequests.isEmpty) {
      return SectionCard(
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

    return SectionCard(
      title: "Arkadaşlık İstekleri",
      trailing: StatusChip("${friendRequests.length} beklemede", bg: Colors.orange.shade100),
      child: SizedBox(
        height: 170,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: friendRequests.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final req = friendRequests[index];
            final id = req['_id'] as String;
            final name = (req['name'] ?? '') as String;
            final location = (req['location'] ?? '') as String;

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
                          Text(name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: busyAccept
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
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
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: busyReject
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
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
  Widget _buildFriendGrid() {
    if (friends.isEmpty) {
      return SectionCard(
        title: "Arkadaşlar",
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Column(
            children: [
              const Icon(Icons.people_outline, size: 44, color: Colors.black38),
              const SizedBox(height: 8),
              const Text("Henüz arkadaşın yok gibi görünüyor.",
                  style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _openSearchSheet,
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

    return SectionCard(
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
                MaterialPageRoute(builder: (_) => FriendProfileScreen(user: friend)),
              );
              if (result == true) await fetchData();
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
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 4)),
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
                      _buildRequestSection(),
                      const SizedBox(height: 20),
                      _buildFriendGrid(),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openSearchSheet,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text("Arkadaş Ekle"),
      ),
    );
  }
}
