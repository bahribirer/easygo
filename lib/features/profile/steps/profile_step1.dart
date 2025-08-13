import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:easygo/core/service/user_profile_service.dart';
import 'package:easygo/features/profile/steps/profile_step2.dart';
import 'package:easygo/features/profile/steps/profile_step_common.dart';
import 'package:easygo/widgets/ui/blur_blob.dart';

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
          // Blur “blob”lar (ortak widget)
          const Positioned(
            top: -120,
            right: -80,
            child: BlurBlob(
              size: 260,
              color: Color(0x73FEB692), // .45 opaklık
            ),
          ),
          Positioned(
            bottom: -140,
            left: -120,
            child: BlurBlob(
              size: 340,
              color: Color(0x59EA5455), // accent.withOpacity(.35)
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StepHeader(
                    progress: .25,
                    trailing: Text(
                      'Adım 1 / 4',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 18),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          StepGlassCard(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const StepSectionTitle(
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
                                      DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
                                      DropdownMenuItem(value: 'en', child: Text('İngilizce')),
                                    ],
                                    onChanged: (v) => setState(() => selectedLanguage = v),
                                    validator: (v) => v == null ? 'Lütfen bir dil seçin' : null,
                                  ),

                                  const SizedBox(height: 18),
                                  const StepSectionTitle(
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
                                      DropdownMenuItem(value: 'Kadın', child: Text('Kadın')),
                                      DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
                                      DropdownMenuItem(value: 'Diğer', child: Text('Diğer')),
                                    ],
                                    onChanged: (v) => setState(() => selectedGender = v),
                                    validator: (v) =>
                                        v == null ? 'Lütfen bir cinsiyet seçin' : null,
                                  ),

                                  const SizedBox(height: 6),
                                  const StepHintCard(
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
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFFEA5455), width: 1.4),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}
