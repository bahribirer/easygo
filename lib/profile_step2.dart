import 'dart:ui';
import 'package:easygo/helpers/interests_helper.dart';
import 'package:easygo/service/user_profile_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_step3.dart';

class ProfileStep2Screen extends StatefulWidget {
  const ProfileStep2Screen({super.key});

  @override
  State<ProfileStep2Screen> createState() => _ProfileStep2ScreenState();
}

class _ProfileStep2ScreenState extends State<ProfileStep2Screen>
    with TickerProviderStateMixin {
  final List<String> selectedInterests = [];
  String _query = '';

  bool _isSaving = false;

  late final AnimationController _ctaCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 260))
        ..forward();
  late final Animation<double> _ctaScale =
      CurvedAnimation(parent: _ctaCtrl, curve: Curves.easeOutBack);

  List<String> get _filtered {
    if (_query.trim().isEmpty) return allInterests;
    final q = _query.toLowerCase();
    return allInterests.where((e) => e.toLowerCase().contains(q)).toList();
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (selectedInterests.contains(interest)) {
        selectedInterests.remove(interest);
      } else {
        selectedInterests.add(interest);
      }
    });
  }

  Future<void> _saveAndNext() async {
    if (selectedInterests.length < 5 || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kullanıcı ID bulunamadı')),
        );
        return;
      }

      final res = await UserProfileService.updateOrCreateProfile(
        userId: userId,
        interests: selectedInterests,
      );

      if (!mounted) return;
      if (res['success'] == true) {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 320),
            pageBuilder: (_, __, ___) => const ProfileStep3Screen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Hata oluştu')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _ctaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFEA5455);
    final bgGrad = const [Color(0xFFFFF0E9), Color(0xFFFFF7F3)];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final minRequired = 5;
    final remaining = (minRequired - selectedInterests.length).clamp(0, 999);
    final ok = selectedInterests.length >= minRequired;

    return Scaffold(
      backgroundColor: bgGrad.first,
      body: Stack(
        children: [
          // Arka plan gradient + blur blob’lar
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: bgGrad,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -120,
            right: -80,
            child: _BlurBlob(
              size: 260,
              color: const Color(0xFFFEB692).withOpacity(.45),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -120,
            child: _BlurBlob(
              size: 340,
              color: accent.withOpacity(.35),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(progress: 50, accent: accent),
                  const SizedBox(height: 12),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _SectionTitle(
                                  title: 'İlgi Alanları',
                                  subtitle:
                                      'Hayatını renklendiren tutkularını paylaş. En az 5 ilgi alanı seç.',
                                ),
                                const SizedBox(height: 12),

                                // Arama & kısayollar
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        onChanged: (v) => setState(() => _query = v),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(Icons.search),
                                          hintText: 'Ara (ör. Koşu, Müzik, Yapay Zeka)…',
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12)),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Tooltip(
                                      message: 'Tümünü temizle',
                                      child: IconButton(
                                        onPressed: selectedInterests.isEmpty
                                            ? null
                                            : () => setState(selectedInterests.clear),
                                        icon: const Icon(Icons.clear_all_rounded),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),
                                _MinInfoBar(
                                  ok: ok,
                                  remaining: remaining,
                                  accent: accent,
                                  count: selectedInterests.length,
                                ),

                                const SizedBox(height: 12),

                                // Chip grid
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _filtered.map((interest) {
                                    final selected =
                                        selectedInterests.contains(interest);
                                    return FilterChip(
                                      label: Text(interest),
                                      selected: selected,
                                      onSelected: (_) => _toggleInterest(interest),
                                      labelStyle: TextStyle(
                                        color: selected ? accent : null,
                                        fontWeight:
                                            selected ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                      selectedColor: accent.withOpacity(.14),
                                      checkmarkColor: accent,
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(999),
                                        side: BorderSide(
                                          color: selected
                                              ? accent.withOpacity(.4)
                                              : Colors.black.withOpacity(.08),
                                        ),
                                      ),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  Row(
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(100, 50),
                          side: BorderSide(color: Colors.orange.shade700),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Geri'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ScaleTransition(
                          scale: _ctaScale,
                          child: ElevatedButton(
                            onPressed: ok && !_isSaving ? _saveAndNext : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Devam Et',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------- Header ----------
class _Header extends StatelessWidget {
  final int progress;
  final Color accent;
  const _Header({required this.progress, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Başlık
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profili Tamamla',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFEA5455),
                      )),
              const SizedBox(height: 4),
              Text(
                'Adım 2 / 4',
                style: TextStyle(
                  color: Colors.black.withOpacity(.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Yüzde çemberi
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                value: progress / 100,
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            Text(
              '%$progress',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ---------- Min 5 uyarı/sayaç ----------
class _MinInfoBar extends StatelessWidget {
  final bool ok;
  final int remaining;
  final int count;
  final Color accent;
  const _MinInfoBar({
    required this.ok,
    required this.remaining,
    required this.count,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final color = ok ? Colors.green : Colors.orange.shade700;
    final icon = ok ? Icons.check_circle : Icons.info_outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: (ok ? Colors.green : Colors.orange).withOpacity(.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (ok ? Colors.green : Colors.orange).withOpacity(.18)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ok
                  ? 'Harika! $count ilgi alanı seçtin.'
                  : 'En az 5 ilgi alanı seç. Kalan: $remaining',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------- Reusable ----------
class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.red, fontWeight: FontWeight.w800, fontSize: 14)),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.black87),
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(.06)),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(.06),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _BlurBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _BlurBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(width: size, height: size, color: color),
      ),
    );
  }
}
