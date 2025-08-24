import 'dart:convert';
import 'dart:io';

import 'package:easygo/features/profile/steps/verify_email_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🔹 eklendi

import 'package:easygo/core/service/user_profile_service.dart';
import 'package:easygo/features/welcome/welcome_screen.dart';
import 'package:easygo/features/profile/steps/profile_step_common.dart';
import 'package:easygo/l10n/app_localizations.dart';

class ProfileStep4Screen extends StatefulWidget {
  const ProfileStep4Screen({super.key});

  @override
  State<ProfileStep4Screen> createState() => _ProfileStep4ScreenState();
}

class _ProfileStep4ScreenState extends State<ProfileStep4Screen> {
  File? _selectedImage;
  bool _saving = false;

  // ---------- Image picking ----------
  Future<void> _pickImageSource() async {
    final loc = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(loc.photoSource,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(loc.gallery),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(loc.camera),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );

    if (source != null) await _pickImage(source);
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1500,
    );
    if (pickedFile != null && mounted) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  // ---------- Verification dialog ----------
  Future<void> _showVerificationDialog() async {
    final loc = AppLocalizations.of(context)!;
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.email_outlined, size: 50, color: Colors.deepOrange),
              const SizedBox(height: 14),
              Text(
                loc.verifyEmailTitle, // "Doğrulama Maili Gönderildi"
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                loc.verifyEmailMessage, // "Lütfen mail kutunu kontrol et."
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
);

                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: const Color(0xFFEA5455),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(loc.ok),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Save (upload) ----------
  Future<void> _save() async {
    if (_selectedImage == null || _saving) return;
    setState(() => _saving = true);

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

      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final result = await UserProfileService.updateOrCreateProfile(
        userId: userId,
        profilePhoto: base64Image,
      );

      if (!mounted) return;
      if (result['success'] == true) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();
          await _showVerificationDialog();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? AppLocalizations.of(context)!.genericError)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _skipForNow() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      await _showVerificationDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final padBottom = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 120),
          padding: EdgeInsets.only(bottom: padBottom),
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const StepHeader(progress: 1.0),
                          const SizedBox(height: 10),

                          Text(
                            loc.step4Title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.grey.shade900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            loc.step4Subtitle,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 24),

                          Center(
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFF6F61), Color(0xFFFF9472)],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(.08),
                                        blurRadius: 14,
                                        offset: const Offset(0, 6),
                                      )
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 70,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 66,
                                      backgroundColor: Colors.grey.shade200,
                                      backgroundImage: _selectedImage != null
                                          ? FileImage(_selectedImage!)
                                          : null,
                                      child: _selectedImage == null
                                          ? Icon(Icons.person,
                                              size: 64,
                                              color: Colors.grey.shade400)
                                          : null,
                                    ),
                                  ),
                                ),
                                Material(
                                  color: Colors.white,
                                  shape: const CircleBorder(),
                                  elevation: 2,
                                  child: IconButton(
                                    onPressed: _pickImageSource,
                                    icon: const Icon(Icons.edit,
                                        color: Colors.deepOrange),
                                    tooltip: loc.photoSelect,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 26),

                          StepHintCard(text: loc.step4Hint),

                          const Spacer(),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _saving ? null : _skipForNow,
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(52),
                                    side: const BorderSide(color: Color(0xFFFF9E80)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(
                                    loc.skipForNow,
                                    style: const TextStyle(
                                      color: Color(0xFFFB8C00),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed:
                                      _selectedImage != null && !_saving ? _save : null,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(52),
                                    backgroundColor: const Color(0xFFEA5455),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                  icon: _saving
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Icon(Icons.check_rounded),
                                  label: Text(_saving ? loc.uploading : loc.complete),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
