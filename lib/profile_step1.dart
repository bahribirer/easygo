import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easygo/service/user_profile_service.dart';
import 'profile_step2.dart';

class ProfileStep1Screen extends StatefulWidget {
  const ProfileStep1Screen({super.key});

  @override
  State<ProfileStep1Screen> createState() => _ProfileStep1ScreenState();
}

class _ProfileStep1ScreenState extends State<ProfileStep1Screen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  String? selectedLanguage;
  String? selectedGender;

  bool _isSaving = false;

  late final AnimationController _ctaCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 240))
        ..forward();
  late final Animation<double> _ctaScale =
      CurvedAnimation(parent: _ctaCtrl, curve: Curves.easeOutBack);

  @override
  void dispose() {
    _ctaCtrl.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kullanıcı ID bulunamadı')),
        );
        return;
      }

      final res = await UserProfileService.updateOrCreateProfile(
        userId: userId,
        gender: selectedGender,
        language: selectedLanguage,
      );

      if (!mounted) return;
      if (res['success'] == true) {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 320),
            pageBuilder: (_, __, ___) => const ProfileStep2Screen(),
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
  Widget build(BuildContext context) {
    final bgLight = const [Color(0xFFFFF0E9), Color(0xFFFFF7F3)];
    final accent = const Color(0xFFEA5455);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: bgLight.first,
      body: Stack(
        children: [
          // Gradient arkaplan
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: bgLight,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Blur “blob”lar
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
                  _Header(progress: 25, accent: accent),
                  const SizedBox(height: 18),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _GlassCard(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _SectionTitle(
                                    title: 'Dil',
                                    subtitle:
                                        'Uygulamayı hangi dilde kullanmak istersin?',
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    value: selectedLanguage,
                                    isExpanded: true,
                                    decoration: _fieldDeco(
                                      label: 'Dil Seçiniz',
                                      icon: Icons.language_outlined,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'tr', child: Text('Türkçe')),
                                      DropdownMenuItem(
                                          value: 'en', child: Text('İngilizce')),
                                    ],
                                    onChanged: (v) =>
                                        setState(() => selectedLanguage = v),
                                    validator: (v) =>
                                        v == null ? 'Lütfen bir dil seçin' : null,
                                  ),

                                  const SizedBox(height: 18),
                                  _SectionTitle(
                                    title: 'Cinsiyet',
                                    subtitle: 'Kendini nasıl tanımlıyorsun?',
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    value: selectedGender,
                                    isExpanded: true,
                                    decoration: _fieldDeco(
                                      label: 'Cinsiyet Seçiniz',
                                      icon: Icons.person_outline_rounded,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'Kadın', child: Text('Kadın')),
                                      DropdownMenuItem(
                                          value: 'Erkek', child: Text('Erkek')),
                                      DropdownMenuItem(
                                          value: 'Diğer', child: Text('Diğer')),
                                    ],
                                    onChanged: (v) =>
                                        setState(() => selectedGender = v),
                                    validator: (v) => v == null
                                        ? 'Lütfen bir cinsiyet seçin'
                                        : null,
                                  ),

                                  const SizedBox(height: 6),
                                  _Hint(
                                    text:
                                        'Bu bilgileri daha sonra profil ayarlarından değiştirebilirsin.',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  ScaleTransition(
                    scale: _ctaScale,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDeco({required String label, required IconData icon}) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEA5455), width: 1.4),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}

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
                'Adım 1 / 4',
                style: TextStyle(
                  color: Colors.black.withOpacity(.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Yüzdelik halka
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 44,
              width: 44,
              child: CircularProgressIndicator(
                value: progress / 100,
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            Text('%$progress',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}

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

class _Hint extends StatelessWidget {
  final String text;
  const _Hint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.info_outline_rounded,
            size: 18, color: Colors.black45),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
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
