import 'dart:convert';
import 'dart:ui';
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
                      // üst header
                      SliverAppBar(
                        pinned: true,
                        expandedHeight: 220,
                        backgroundColor: Colors.transparent,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                              BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(color: Colors.black.withOpacity(0.1)),
                              ),
                              SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 32,
                                            backgroundImage: _profilePhoto(
                                              profileData!['profilePhoto'],
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                profileData!['name'] ?? 'Kullanıcı',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                profileData!['location'] ?? 'Bilinmiyor',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const SettingsScreen(),
                                            ),
                                          );
                                          if (mounted) _loadProfile();
                                        },
                                        icon: const Icon(Icons.settings,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // istatistikler
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  title: 'Arkadaş',
                                  value: friends.length.toString(),
                                  icon: Icons.people_alt_rounded,
                                  gradient: const [Color(0xFF56CCF2), Color(0xFF2F80ED)],
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
                                  gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // hakkında
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hakkında',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
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
                      // arkadaş önizleme
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
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
                      // ilgi alanları
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.white).withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white30, width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_outline,
                      size: 72, color: Colors.white70),
                  const SizedBox(height: 16),
                  const Text(
                    'Profil verisi bulunamadı',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: onOpenSettings,
                    icon: const Icon(Icons.settings),
                    label: const Text('Ayarları Aç'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA5455),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
