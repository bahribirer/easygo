import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:easygo/helpers/interests_helper.dart'; // allInterests
import 'package:easygo/core/service/user_profile_service.dart';
import 'package:easygo/features/profile/steps/profile_step3.dart';
import 'package:easygo/features/profile/steps/profile_step_common.dart';
import 'package:easygo/l10n/app_localizations.dart';

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
  final keys = InterestsHelper.keys; // 🔹 sabit key listesi
  if (_query.trim().isEmpty) return keys;

  final q = _query.toLowerCase();
  return keys.where((k) {
    final label = InterestsHelper.label(context, k).toLowerCase();
    return label.contains(q);
  }).toList();
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
          SnackBar(content: Text(AppLocalizations.of(context)!.errorMissingInfoMessage)),
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
          SnackBar(content: Text(res['message'] ?? AppLocalizations.of(context)!.genericError)),
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
    final loc = AppLocalizations.of(context)!;
    final accent = const Color(0xFFEA5455);
    final bgGrad = const [Color(0xFFFFF0E9), Color(0xFFFFF7F3)];

    final minRequired = 5;
    final remaining = (minRequired - selectedInterests.length).clamp(0, 999);
    final ok = selectedInterests.length >= minRequired;

    return Scaffold(
      backgroundColor: bgGrad.first,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: bgGrad,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Soft blur blobs (lokal)
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
                  // Ortak header + adım etiketi
                  StepHeader(
                    progress: .50,
                    trailing: Text(
                      loc.stepCount(2, 4), // Adım 2 / 4
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StepGlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StepSectionTitle(
                                  title: loc.interestsTitle,
                                  subtitle: loc.interestsSubtitle,
                                ),
                                const SizedBox(height: 12),

                                // Search & clear
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        onChanged: (v) => setState(() => _query = v),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(Icons.search),
                                          hintText: loc.searchHint,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Tooltip(
                                      message: loc.clearAll,
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

                                // Interest chips
                                // Interest chips
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: _filtered.map((key) {
    final selected = selectedInterests.contains(key);
    final label = InterestsHelper.label(context, key);

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => _toggleInterest(key),
      labelStyle: TextStyle(
        color: selected ? accent : null,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                        child: Text(loc.backButton),
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
                                : Text(
                                    loc.continueButton,
                                    style: const TextStyle(
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

/// ---------- Min 5 info ----------
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
    final loc = AppLocalizations.of(context)!;
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
                  ? loc.minInfoOk(count)
                  : loc.minInfoNotEnough(remaining),
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

/// ---------- Local blur blob ----------
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
