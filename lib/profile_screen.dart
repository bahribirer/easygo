import 'dart:convert';

import 'package:easygo/FriendListScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easygo/service/user_profile_service.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;
  List<dynamic> friends = [];

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      final profileRes = await UserProfileService.getProfile(userId);
      final friendsRes = await UserProfileService.getFriends(userId);

      if (!mounted) return;
      setState(() {
        isLoading = false;

        if (profileRes['success']) {
          profileData = profileRes['profile'];
        }

        if (friendsRes['success']) {
          friends = friendsRes['friends'];
        }
      });
    } else {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeBg = const Color(0xFFFFF0E9);

    return Scaffold(
      backgroundColor: themeBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: const Text(
          "Profil",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ).then((_) {
                loadProfile(); // geri dönünce veriyi tazele
              });
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (profileData == null)
              ? const Center(child: Text("Profil verisi bulunamadı."))
              : RefreshIndicator(
                  onRefresh: loadProfile,
                  child: SingleChildScrollView(
  physics: const AlwaysScrollableScrollPhysics(),
  padding: EdgeInsets.only(
    bottom: 24 + MediaQuery.of(context).padding.bottom,
  ),
                    child: Column(
                      children: [
                        _Header(profileData: profileData!),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _StatsRow(friendsCount: friends.length),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _FriendsCard(
                            friends: friends,
                            onTapAll: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FriendsListScreen(friends: friends),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _InterestsCard(interests: (profileData!['interests'] as List?) ?? []),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  int calculateAge(String? birthDateStr) {
    if (birthDateStr == null) return 0;
    final birthDate = DateTime.parse(birthDateStr);
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // ----------------- Header -----------------
  // ----------------- Header (overflow FIX) -----------------
Widget _Header({required Map<String, dynamic> profileData}) {
  final mq = MediaQuery.of(context);
  final w = mq.size.width;

  // Responsive ölçüler
  final coverH = (w * 0.34).clamp(132.0, 188.0);
  final outerAvatar = (w * 0.15).clamp(48.0, 64.0);   // beyaz çerçeve yarıçapı
  final innerAvatar = (outerAvatar - 4).clamp(44.0, 60.0);
  final gap = (w * 0.03).clamp(8.0, 14.0);

  final photo = profileData['profilePhoto'];
  final name = (profileData['name'] ?? 'Kullanıcı') as String;
  final age = calculateAge(profileData['birthDate']);
  final location = (profileData['location'] ?? 'Bilinmiyor') as String;

  return Column(
    children: [
      // 1) Kapak: normal akışta yer tutuyor
      Container(
        height: coverH,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFFFEB692), Color(0xFFEA5455)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
      ),

      // 2) Avatar + Bilgi kartını yukarı doğru bindir
      Transform.translate(
        offset: Offset(0, -outerAvatar), // kapağın içine doğru çek
        child: Column(
          children: [
            CircleAvatar(
              radius: outerAvatar,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: innerAvatar,
                backgroundImage: (photo != null && photo != '')
                    ? MemoryImage(base64Decode(photo))
                    : const AssetImage('assets/profile.jpg') as ImageProvider,
              ),
            ),
            SizedBox(height: gap),

            // Bilgi kartı
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "$name, $age",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: (w * 0.055).clamp(18.0, 22.0),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          "$location, TÜRKİYE",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // 3) Bindirme sonrası aşağıya küçük nefes
      SizedBox(height: outerAvatar - gap),
    ],
  );
}


}

// ----------------- Stats Row -----------------
class _StatsRow extends StatelessWidget {
  final int friendsCount;
  const _StatsRow({required this.friendsCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: "Arkadaş",
            value: friendsCount.toString(),
            icon: Icons.people_alt_rounded,
            gradient: const [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: "Durum",
            value: "Aktif",
            icon: Icons.verified_rounded,
            gradient: const [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
          ),
        ),
      ],
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
      height: 86,
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
            backgroundColor: Colors.white.withOpacity(0.9),
            child: Icon(icon, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------- Friends Card -----------------
class _FriendsCard extends StatelessWidget {
  final List<dynamic> friends;
  final VoidCallback onTapAll;
  const _FriendsCard({required this.friends, required this.onTapAll});

  @override
  Widget build(BuildContext context) {
    final preview = friends.take(5).toList();

    return Container(
      decoration: _sectionDeco(context),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("Arkadaşlar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              if (friends.isNotEmpty)
                _chip("${friends.length} kişi", bg: Colors.orange.shade100),
            ],
          ),
          const SizedBox(height: 12),
          if (friends.isEmpty)
            Column(
              children: [
                const SizedBox(height: 6),
                const Icon(Icons.people_outline, size: 44, color: Colors.black38),
                const SizedBox(height: 8),
                const Text("Henüz arkadaşın yok gibi görünüyor.", style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: onTapAll,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text("Arkadaş Bul"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // küçük avatar önizlemesi
                SizedBox(
                  height: 54,
                  child: Stack(
                    children: [
                      for (int i = 0; i < preview.length; i++)
                        Positioned(
                          left: i * 28,
                          child: CircleAvatar(
                            radius: 24,
                            backgroundImage: (preview[i]['profilePhoto'] != null && preview[i]['profilePhoto'] != '')
                                ? MemoryImage(base64Decode(preview[i]['profilePhoto']))
                                : const AssetImage('assets/profile.jpg') as ImageProvider,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onTapAll,
                    icon: const Icon(Icons.list_alt),
                    label: const Text("Tüm arkadaşları gör"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Color(0xFFFF7A7A)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ----------------- Interests Card -----------------
class _InterestsCard extends StatelessWidget {
  final List<dynamic> interests;
  const _InterestsCard({required this.interests});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _sectionDeco(context),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("İlgi Alanları", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (interests.isEmpty)
            const Text("İlgi alanı belirtilmemiş", style: TextStyle(color: Colors.black54))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: interests.map<Widget>((interest) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFFFC1C1)),
                  ),
                  child: Text(
                    interest.toString(),
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

// ----------------- Shared UI helpers -----------------
BoxDecoration _sectionDeco(BuildContext context) => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );

Widget _chip(String label, {Color? bg}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg ?? Colors.grey.shade200, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
    );
