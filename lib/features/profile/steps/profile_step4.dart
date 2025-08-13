import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:easygo/core/service/user_profile_service.dart';
import 'package:easygo/features/welcome/welcome_screen.dart';
import 'package:easygo/features/profile/steps/profile_step_common.dart';

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
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text('Fotoğraf Kaynağı',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Galeri'),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Kamera'),
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
      imageQuality: 85, // hafif sıkıştırma
      maxWidth: 1500,
    );
    if (pickedFile != null && mounted) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  // ---------- Success dialog ----------
  Future<void> _showSuccessDialog() async {
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
              // gradient halka + check icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  ),
                ),
                child: const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.check_rounded, size: 34, color: Color(0xFF43A047)),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Kayıt Tamamlandı!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Hesabın hazır. Keyifle keşfetmeye başlayabilirsin 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Uygulamaya Başla'),
                ),
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
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Kullanıcı ID bulunamadı')));
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
        await _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Hata oluştu')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---------- Skip (do it later) ----------
  void _skipForNow() {
    _showSuccessDialog();
  }

  @override
  Widget build(BuildContext context) {
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
                            'Profil Fotoğrafın',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.grey.shade900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Gülümsemeyi unutma! Fotoğrafın ilk izlenim için çok önemli.',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 24),

                          // Avatar + çerçeve + edit butonu
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
                                      backgroundImage:
                                          _selectedImage != null ? FileImage(_selectedImage!) : null,
                                      child: _selectedImage == null
                                          ? Icon(Icons.person, size: 64, color: Colors.grey.shade400)
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
                                    icon: const Icon(Icons.edit, color: Colors.deepOrange),
                                    tooltip: 'Fotoğrafı seç',
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 26),

                          const StepHintCard(
                            text:
                                'Net ve aydınlık bir fotoğraf seç. Yüzün görünür olsun, bu seni daha bulunabilir kılar.',
                          ),

                          const Spacer(),

                          // Actions
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
                                  child: const Text(
                                    'Sonra Yapacağım',
                                    style: TextStyle(
                                      color: Color(0xFFFB8C00),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _selectedImage != null && !_saving ? _save : null,
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
                                          height: 18, width: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Icon(Icons.check_rounded),
                                  label: Text(_saving ? 'Yükleniyor…' : 'Tamamla'),
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
