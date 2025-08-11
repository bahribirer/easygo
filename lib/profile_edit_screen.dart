import 'dart:convert';
import 'dart:typed_data';

import 'package:easygo/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easygo/service/user_profile_service.dart';
import 'package:easygo/helpers/interests_helper.dart';
import 'package:easygo/helpers/city_helper.dart'; // Türkiye illeri listesi

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  String? userId;
  bool isLoading = true;
  bool isSaving = false;

  // Görsel
  Uint8List? profileImageBytes;

  // İlgi alanları
  List<String> selectedInterests = [];

  // Şehir
  String? selectedCity;

  // ISO gönderim için (YYYY-MM-DD)
  String? isoBirthDate;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    nameController.dispose();
    birthDateController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');

    if (userId != null) {
      final result = await UserProfileService.getProfile(userId!);
      if (result['success'] == true) {
        final profile = result['profile'];

        // Ad
        nameController.text = profile['name'] ?? '';

        // Doğum tarihi
        final String? raw = profile['birthDate'];
        if (raw != null && raw.isNotEmpty) {
          try {
            final dt = DateTime.parse(raw);
            isoBirthDate = dt.toIso8601String().substring(0, 10);
            birthDateController.text = _formatDateForDisplay(dt);
          } catch (_) {
            isoBirthDate = raw.substring(0, 10);
            birthDateController.text = raw.substring(0, 10);
          }
        }

        // Şehir
        selectedCity = profile['location'];

        // İlgi alanları
        selectedInterests = List<String>.from(profile['interests'] ?? []);

        // Fotoğraf
        final photo = profile['profilePhoto'];
        if (photo != null && photo.toString().isNotEmpty) {
          try {
            profileImageBytes = base64Decode(photo);
          } catch (_) {}
        }
      }
    }

    if (mounted) setState(() => isLoading = false);
  }

  String _formatDateForDisplay(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return '$d.$m.$y'; // 10.08.2025
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      if (mounted) {
        setState(() {
          profileImageBytes = bytes;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final initial = isoBirthDate != null
        ? DateTime.tryParse(isoBirthDate!)
        : DateTime(2000, 1, 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      helpText: 'Doğum Tarihini Seç',
      cancelText: 'İptal',
      confirmText: 'Tamam',
    );

    if (picked != null) {
      setState(() {
        isoBirthDate = picked.toIso8601String().substring(0, 10);
        birthDateController.text = _formatDateForDisplay(picked);
      });
    }
  }

  Future<void> _save() async {
    if (userId == null || isSaving) return;
    setState(() => isSaving = true);

    final result = await UserProfileService.updateOrCreateProfile(
      userId: userId!,
      name: nameController.text.trim().isNotEmpty ? nameController.text.trim() : null,
      birthDate: isoBirthDate, // ISO 8601 (YYYY-MM-DD)
      location: selectedCity,
      interests: selectedInterests,
      profilePhoto: profileImageBytes != null ? base64Encode(profileImageBytes!) : null,
    );

    if (!mounted) return;
    setState(() => isSaving = false);

    if (result['success'] == true) {
      await _showSuccessDialog(); // şık başarı popup
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Hata oluştu'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _showSuccessDialog() async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Success',
      barrierColor: Colors.black.withOpacity(0.35),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation1, animation2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, a1, a2, _) {
        final curved = CurvedAnimation(parent: a1, curve: Curves.easeOutCubic);
        return Transform.scale(
          scale: 0.9 + 0.1 * curved.value,
          child: Opacity(
            opacity: a1.value,
            child: Center(
              child: Container(
                width: 320,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Halkalı arka plan + check
                    Container(
                      height: 72,
                      width: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6F61), Color(0xFFFF9472)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.check_rounded, color: Colors.white, size: 40),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Profil Güncellendi',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Değişikliklerin başarıyla kaydedildi.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Tamam'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF0F0F10)
        : const Color(0xFFFFF8F3);

    return Scaffold(
      backgroundColor: bg,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Başlık / AppBar benzeri şerit
                Container(
                  padding: const EdgeInsets.only(top: 50, left: 24, right: 16, bottom: 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF6F61), Color(0xFFFF9472)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Profili Düzenle",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        tooltip: 'Kapat',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar + Değiştir
                        Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFF6F61), Color(0xFFFF9472)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 6),
                                    )
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 56,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                    radius: 52,
                                    backgroundImage: profileImageBytes != null
                                        ? MemoryImage(profileImageBytes!)
                                        : const AssetImage('assets/profile.jpg') as ImageProvider,
                                  ),
                                ),
                              ),
                              Material(
                                color: Colors.white,
                                shape: const CircleBorder(),
                                elevation: 2,
                                child: IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.deepOrange),
                                  onPressed: _pickImage,
                                  tooltip: 'Fotoğrafı değiştir',
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Ad Soyad
                        _sectionCard(
                          context: context,
                          title: 'Ad / Kullanıcı Adı',
                          child: TextField(
                            controller: nameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person_outline),
                              hintText: 'Adını yaz',
                              labelText: 'Ad',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),

                        // Doğum tarihi
                        _sectionCard(
                          context: context,
                          title: 'Doğum Tarihi',
                          child: GestureDetector(
                            onTap: () => _selectDate(context),
                            child: AbsorbPointer(
                              child: TextField(
                                controller: birthDateController,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.cake_outlined),
                                  hintText: 'GG.AA.YYYY',
                                  labelText: 'Doğum Tarihi',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Şehir
                        _sectionCard(
                          context: context,
                          title: 'Şehir',
                          child: DropdownButtonFormField<String>(
                            value: selectedCity,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.location_on_outlined),
                              labelText: 'Şehir Seç',
                              border: OutlineInputBorder(),
                            ),
                            items: turkishCities
                                .map((c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => selectedCity = v),
                          ),
                        ),

                        // İlgi alanları
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'İlgi Alanları',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[800],
                                ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.06),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: allInterests.map((interest) {
                              final isSelected = selectedInterests.contains(interest);
                              return FilterChip(
                                selected: isSelected,
                                label: Text(interest),
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.deepOrange : null,
                                ),
                                selectedColor: Colors.deepOrange.withOpacity(.15),
                                checkmarkColor: Colors.deepOrange,
                                onSelected: (sel) {
                                  setState(() {
                                    if (sel) {
                                      selectedInterests.add(interest);
                                    } else {
                                      selectedInterests.remove(interest);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Kaydet
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isSaving ? null : _save,
                            icon: isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.save),
                            label: Text(isSaving ? 'Kaydediliyor…' : 'Kaydet ve Geri Dön'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _sectionCard({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
              ),
            ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
