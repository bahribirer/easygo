import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Servis yollarını projendeki klasör adına göre ayarla:
// 1) Eğer "core/service" kullanıyorsan alttakileri olduğu gibi bırak.
// 2) Eğer "core/services" ise "service" -> "services" yap.
import 'package:easygo/core/service/user_profile_service.dart';
import 'package:easygo/core/service/friendService.dart';

import 'package:easygo/features/friends/widgets/section_card.dart';

class FriendProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const FriendProfileScreen({super.key, required this.user});

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchFriendProfile();
  }

  Future<void> _fetchFriendProfile() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      currentUserId = prefs.getString('userId');

      final result = await UserProfileService.getProfile(widget.user['_id']);
      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          profileData = result['profile'] as Map<String, dynamic>?;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _toast('Profil verisi alınamadı.');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _toast('Bir hata oluştu. Lütfen tekrar deneyin.');
    }
  }

  int _calculateAge(String? birthDateStr) {
    if (birthDateStr == null || birthDateStr.isEmpty) return 0;
    DateTime birthDate;
    try {
      birthDate = DateTime.parse(birthDateStr);
    } catch (_) {
      return 0;
    }
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _confirmUnfriend() async {
    if (currentUserId == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Arkadaşlıktan çıkar?'),
        content: Text(
          '"${profileData?['name'] ?? 'Kullanıcı'}" kişi listesinden kaldırılacak.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Evet, çıkar'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await FriendService.unfriend(currentUserId!, widget.user['_id']);
      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Arkadaşlık Silindi 💔',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Bu kişiyi arkadaş listesinden kaldırdın.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tamam', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      Navigator.pop(context, true); // listeye dön ve refresh tetikle
    } catch (_) {
      _toast('İşlem başarısız. Lütfen tekrar deneyin.');
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFFFF0E9);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (profileData == null)
              ? const Center(child: Text('Profil verisi alınamadı'))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // --- Header / Avatar & Kimlik ---
                            Hero(
                              tag: "friend_${widget.user['_id']}",
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage: (profileData!['profilePhoto'] != null &&
                                        profileData!['profilePhoto'].toString().isNotEmpty)
                                    ? MemoryImage(
                                        base64Decode(profileData!['profilePhoto']))
                                    : const AssetImage('assets/profile.jpg')
                                        as ImageProvider,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "${profileData!['name'] ?? 'Kullanıcı'}, ${_calculateAge(profileData!['birthDate'])}",
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profileData!['universityEmail'] ?? '',
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on,
                                    size: 16, color: Colors.red),
                                const SizedBox(width: 4),
                                Text(
                                  "${profileData!['location'] ?? 'Bilinmiyor'}, TÜRKİYE",
                                  style: const TextStyle(
                                      color: Colors.black54, fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // --- Arkadaş sayısı ---
                            SectionCard(
                              title: 'Arkadaşlar',
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  "${(profileData!['friends'] as List?)?.length ?? 0} arkadaş",
                                  style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // --- İlgi alanları ---
                            SectionCard(
                              title: 'İlgi Alanları',
                              child: (profileData!['interests'] != null &&
                                      (profileData!['interests'] as List).isNotEmpty)
                                  ? Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: (profileData!['interests'] as List)
                                          .map((it) => Chip(
                                                label: Text('$it'),
                                                backgroundColor:
                                                    Colors.red.shade50,
                                                labelStyle: const TextStyle(
                                                    color: Colors.red),
                                              ))
                                          .toList()
                                          .cast<Widget>(),
                                    )
                                  : const Text('İlgi alanı belirtilmemiş',
                                      style: TextStyle(color: Colors.black54)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- Alt aksiyon bar ---
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.delete_forever),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _confirmUnfriend,
                              label: const Text('Arkadaşlıktan Çıkar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.message),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                // TODO: Mesajlaşma akışı bağlanacak
                              },
                              label: const Text(
                                'Mesaj Gönder',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
