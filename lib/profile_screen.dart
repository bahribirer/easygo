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

        if (profileRes['success'] == true) {
          profileData = profileRes['profile'];
        }

        if (friendsRes['success'] == true) {
          friends = friendsRes['friends'] ?? [];
        }
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
    if (value == null || value == '') {
      return const AssetImage('assets/profile.jpg');
    }
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
              ? _EmptyState(onOpenSettings: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                })
              : RefreshIndicator(
                  onRefresh: loadProfile,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      _ProfileAppBar(
                        name: profileData!['name'] ?? 'Kullanıcı',
                        location: profileData!['location'] ?? 'Bilinmiyor',
                        photo: _profilePhoto(profileData!['profilePhoto']),
                        onTapSettings: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                          if (!mounted) return;
                          loadProfile();
                        },
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: _StatsRow(
                            friendsCount: friends.length,
                            age: _ageFromBirthDate(profileData!['birthDate']),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _GlassCard(
                            title: 'Hakkında',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _AboutRow(
                                  icon: Icons.mail_outline,
                                  label: profileData!['universityEmail'] ?? '—',
                                ),
                                const SizedBox(height: 10),
                                _AboutRow(
                                  icon: Icons.location_on_outlined,
                                  label: '${profileData!['location'] ?? 'Bilinmiyor'}, Türkiye',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: const SizedBox(height: 12)),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      ),
                      SliverToBoxAdapter(child: const SizedBox(height: 12)),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _InterestsCard(
                            interests: (profileData!['interests'] as List?) ?? [],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(height: 24 + MediaQuery.of(context).padding.bottom),
                      ),
                    ],
                  ),
                ),
    );
  }
}

/// ===== AppBar: Stack tabanlı, overflow-safe =====
class _ProfileAppBar extends StatelessWidget {
  final String name;
  final String location;
  final ImageProvider photo;
  final VoidCallback onTapSettings;

  const _ProfileAppBar({
    required this.name,
    required this.location,
    required this.photo,
    required this.onTapSettings,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final topPad = mq.padding.top;
    final screenH = mq.size.height;

    // Yükseklikleri ekrana göre hesapla
    final expandedH = (screenH * 0.28).clamp(220.0, 300.0);
    final minAvatar = 36.0;
    final maxAvatar = 64.0;

    return SliverAppBar(
      pinned: true,
      expandedHeight: expandedH,
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: LayoutBuilder(
        builder: (ctx, c) {
          final currentH = c.constrainHeight();
          // 0 = tamamen kapalı, 1 = tamamen açık
          final t = ((currentH - kToolbarHeight) / (expandedH - kToolbarHeight)).clamp(0.0, 1.0);

          final avatarSize = minAvatar + (maxAvatar - minAvatar) * t;
          final bottomPadding = 16.0 * t;
          final titleSize = 18.0 + 6.0 * t;

          return Stack(
            fit: StackFit.expand,
            children: [
              // Kapak gradient
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFEB692), Color(0xFFEA5455)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              // Hafif beyaz örtü
              Opacity(opacity: 0.08, child: Container(color: Colors.white)),

              // Üst buton (ayarlar)
              Positioned(
                top: topPad + 6,
                right: 6,
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white),
                  onPressed: onTapSettings,
                  tooltip: 'Ayarlar',
                ),
              ),

              // Alt kısım: Avatar + İsim/Şehir
              Positioned(
                left: 16,
                right: 16,
                bottom: bottomPadding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Avatar
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(.9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.15),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: CircleAvatar(radius: avatarSize / 2, backgroundImage: photo),
                    ),
                    const SizedBox(width: 12),
                    // Metinler
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: titleSize,
                              shadows: const [Shadow(color: Colors.black26, blurRadius: 8)],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '$location, Türkiye',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(.95),
                                    fontWeight: FontWeight.w500,
                                  ),
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
            ],
          );
        },
      ),
    );
  }
}

/// ===== Stats Row =====
class _StatsRow extends StatelessWidget {
  final int friendsCount;
  final int age;
  const _StatsRow({required this.friendsCount, required this.age});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Arkadaş',
            value: friendsCount.toString(),
            icon: Icons.people_alt_rounded,
            gradient: const [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Yaş',
            value: age == 0 ? '—' : age.toString(),
            icon: Icons.cake_rounded,
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
            backgroundColor: Colors.white.withOpacity(0.9),
            child: Icon(icon, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ===== Friends (genişliğe göre preview sayısı) =====
class _FriendsCard extends StatelessWidget {
  final List<dynamic> friends;
  final VoidCallback onTapAll;
  const _FriendsCard({required this.friends, required this.onTapAll});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    // 24 radius + 4 stroke aralığı ~ 28px kaydırma; sol boşluk ile sığan max hesapla
    final maxPreview = ((w - 32) / 28).floor().clamp(0, 8);
    final preview = friends.take(maxPreview).toList();

    return _GlassCard(
      title: 'Arkadaşlar',
      trailing: friends.isNotEmpty ? _chip('${friends.length} kişi', bg: Colors.orange.shade100) : null,
      child: friends.isEmpty
          ? Column(
              children: [
                const SizedBox(height: 6),
                const Icon(Icons.people_outline, size: 44, color: Colors.black38),
                const SizedBox(height: 8),
                const Text('Henüz arkadaşın yok gibi görünüyor.', style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: onTapAll,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Arkadaş Bul'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA5455),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 56,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (int i = 0; i < preview.length; i++)
                        Positioned(
                          left: i * 28,
                          child: CircleAvatar(
                            radius: 24,
                            backgroundImage: _friendPhoto(preview[i]['profilePhoto']),
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
                    label: const Text('Tüm arkadaşları gör'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEA5455),
                      side: const BorderSide(color: Color(0xFFFF7A7A)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  ImageProvider _friendPhoto(dynamic val) {
    if (val == null || val == '') return const AssetImage('assets/profile.jpg');
    try {
      return MemoryImage(base64Decode(val));
    } catch (_) {
      return const AssetImage('assets/profile.jpg');
    }
  }
}

/// ===== Interests =====
class _InterestsCard extends StatelessWidget {
  final List<dynamic> interests;
  const _InterestsCard({required this.interests});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      title: 'İlgi Alanları',
      child: interests.isEmpty
          ? const Text('İlgi alanı belirtilmemiş', style: TextStyle(color: Colors.black54))
          : Wrap(
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
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(),
            ),
    );
  }
}

/// ===== Reusable Glass Card =====
class _GlassCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _GlassCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor.withOpacity(.9);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200.withOpacity(.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
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

/// ===== Shared helpers =====
Widget _chip(String label, {Color? bg}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg ?? Colors.grey.shade200, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
    );

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _AboutRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFEA5455)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

/// ===== Empty State =====
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
