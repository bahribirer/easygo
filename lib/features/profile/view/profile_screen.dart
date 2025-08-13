import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:easygo/core/service/user_profile_service.dart';
import 'package:easygo/features/friends/list/friends_list_screen.dart';
import 'package:easygo/widgets/ui/glass_card.dart';

import 'package:easygo/features/profile/widgetprofile/profile_header.dart';
import 'package:easygo/features/profile/widgetprofile/stat_card.dart';
import 'package:easygo/features/profile/widgetprofile/about_row.dart';
import 'package:easygo/features/profile/widgetprofile/friends_preview_card.dart';
import 'package:easygo/features/profile/widgetprofile/interests_card.dart';

// Eğer SettingsScreen’i taşımadıysan şunu kullan: import 'package:easygo/settings_screen.dart';
import 'package:easygo/features/settings/view/settings_screen.dart';

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
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      final profileRes = await UserProfileService.getProfile(userId);
      final friendsRes = await UserProfileService.getFriends(userId);

      if (!mounted) return;
      setState(() {
        isLoading = false;
        if (profileRes['success'] == true) profileData = profileRes['profile'];
        if (friendsRes['success'] == true) friends = friendsRes['friends'] ?? [];
      });
    } else {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  int _ageFromBirthDate(String? birthDateStr) {
    if (birthDateStr == null || birthDateStr.isEmpty) return 0;
    DateTime? birth;
    try {
      birth = DateTime.parse(birthDateStr);
    } catch (_) {
      try {
        birth = DateTime.parse(birthDateStr.substring(0, 10));
      } catch (_) {}
    }
    if (birth == null) return 0;
    final now = DateTime.now();
    int age = now.year - birth.year;
    if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return age.clamp(0, 120);
  }

  ImageProvider _profilePhoto(dynamic value) {
    if (value == null || value == '') return const AssetImage('assets/profile.jpg');
    try {
      return MemoryImage(base64Decode(value));
    } catch (_) {
      return const AssetImage('assets/profile.jpg');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF0E0E10)
        : const Color(0xFFFDF7F3);

    return Scaffold(
      backgroundColor: bg,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (profileData == null)
              ? _EmptyState(onOpenSettings: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                  if (mounted) _loadProfile();
                })
              : RefreshIndicator(
                  onRefresh: _loadProfile,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      ProfileHeader(
                        name: profileData!['name'] ?? 'Kullanıcı',
                        location: profileData!['location'] ?? 'Bilinmiyor',
                        photo: _profilePhoto(profileData!['profilePhoto']),
                        onTapSettings: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                          if (mounted) _loadProfile();
                        },
                      ),
                      // --- İstatistikler ---
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  title: 'Arkadaş',
                                  value: friends.length.toString(),
                                  icon: Icons.people_alt_rounded,
                                  gradient: const [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCard(
                                  title: 'Yaş',
                                  value: _ageFromBirthDate(profileData!['birthDate']) == 0
                                      ? '—'
                                      : _ageFromBirthDate(profileData!['birthDate']).toString(),
                                  icon: Icons.cake_rounded,
                                  gradient: const [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // --- Hakkında ---
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Text('Hakkında',
                                        style: TextStyle(
                                            fontSize: 18, fontWeight: FontWeight.w800)),
                                    Spacer(),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                AboutRow(
                                  icon: Icons.mail_outline,
                                  label: profileData!['universityEmail'] ?? '—',
                                ),
                                const SizedBox(height: 10),
                                AboutRow(
                                  icon: Icons.location_on_outlined,
                                  label:
                                      '${profileData!['location'] ?? 'Bilinmiyor'}, Türkiye',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 12)),
                      // --- Arkadaş önizleme ---
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: FriendsPreviewCard(
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
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 12)),
                      // --- İlgi alanları ---
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: InterestsCard(
                            interests: (profileData!['interests'] as List?) ?? [],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 24 + MediaQuery.of(context).padding.bottom,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onOpenSettings;
  const _EmptyState({required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline, size: 64, color: Colors.black38),
            const SizedBox(height: 12),
            const Text('Profil verisi bulunamadı', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onOpenSettings,
              icon: const Icon(Icons.settings),
              label: const Text('Ayarları Aç'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA5455),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
