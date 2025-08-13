import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Servis & yardımcılar
// (Projedeki klasör adın "service" mi "services" mi ise ona göre düzelt)
import 'package:easygo/core/service/user_profile_service.dart';
import 'package:easygo/helpers/interests_helper.dart';
import 'package:easygo/helpers/city_helper.dart';

// Ekran yönlendirme
// Eğer profil ekranını "features/profile/profile_screen.dart" altına aldıysan importu değiştir:
import 'package:easygo/features/profile/view/profile_screen.dart';

// Ortak UI
import 'package:easygo/widgets/ui/glass_card.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final nameController = TextEditingController();
  final birthDateController = TextEditingController();

  String? userId;
  bool isLoading = true;
  bool isSaving = false;

  Uint8List? profileImageBytes;
  List<String> selectedInterests = [];
  String? selectedCity;
  String? isoBirthDate; // YYYY-MM-DD

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
        final profile = result['profile'] as Map<String, dynamic>;

        nameController.text = profile['name'] ?? '';

        final raw = profile['birthDate'];
        if (raw is String && raw.isNotEmpty) {
          try {
            final dt = DateTime.parse(raw);
            isoBirthDate = _toIsoDate(dt);
            birthDateController.text = _formatDateForDisplay(dt);
          } catch (_) {
            isoBirthDate = raw.substring(0, 10);
            birthDateController.text = raw.substring(0, 10);
          }
        }

        selectedCity = profile['location'];
        selectedInterests = List<String>.from(profile['interests'] ?? []);

        final photo = profile['profilePhoto'];
        if (photo is String && photo.isNotEmpty) {
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
    return '$d.$m.$y';
  }

  String _toIsoDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() => profileImageBytes = bytes);
    }
  }

  Future<void> _selectDate() async {
    final initial =
        (isoBirthDate != null) ? DateTime.tryParse(isoBirthDate!) : null;

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
        isoBirthDate = _toIsoDate(picked);
        birthDateController.text = _formatDateForDisplay(picked);
      });
    }
  }

  Future<void> _save() async {
    if (userId == null || isSaving) return;
    setState(() => isSaving = true);

    final result = await UserProfileService.updateOrCreateProfile(
      userId: userId!,
      name: nameController.text.trim().isEmpty
          ? null
          : nameController.text.trim(),
      birthDate: isoBirthDate,
      location: selectedCity,
      interests: selectedInterests,
      profilePhoto:
          (profileImageBytes != null) ? base64Encode(profileImageBytes!) : null,
    );

    if (!mounted) return;
    setState(() => isSaving = false);

    if (result['success'] == true) {
      await _showSuccessDialog();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    } else {
      _toast(result['message'] ?? 'Hata oluştu');
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _showSuccessDialog() async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Success',
      barrierColor: Colors.black.withOpacity(0.35),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, a1, __, ___) {
        final curved = CurvedAnimation(parent: a1, curve: Curves.easeOutCubic);
        return Transform.scale(
          scale: 0.9 + 0.1 * curved.value,
          child: Opacity(
            opacity: a1.value,
            child: Center(
              child: Container(
                width: 320,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
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
                    Container(
                      height: 72,
                      width: 72,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF6F61), Color(0xFFFF9472)],
                        ),
                      ),
                      child: const Center(
                        child:
                            Icon(Icons.check_rounded, color: Colors.white, size: 40),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Profil Güncellendi',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Değişikliklerin başarıyla kaydedildi.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
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
                // Üst şerit
                Container(
                  padding: const EdgeInsets.only(
                      top: 50, left: 24, right: 16, bottom: 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF6F61), Color(0xFFFF9472)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Profili Düzenle',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
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

                // İçerik
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
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
                                        : const AssetImage('assets/profile.jpg')
                                            as ImageProvider,
                                  ),
                                ),
                              ),
                              Material(
                                color: Colors.white,
                                shape: const CircleBorder(),
                                elevation: 2,
                                child: IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.deepOrange),
                                  onPressed: _pickImage,
                                  tooltip: 'Fotoğrafı değiştir',
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Ad
                        _LabeledCard(
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

                        // Doğum Tarihi
                        _LabeledCard(
                          title: 'Doğum Tarihi',
                          child: GestureDetector(
                            onTap: _selectDate,
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
                        _LabeledCard(
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
                                .map((c) =>
                                    DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (v) => setState(() => selectedCity = v),
                          ),
                        ),

                        // İlgi Alanları
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'İlgi Alanları',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[800],
                                ),
                          ),
                        ),
                        GlassCard(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: allInterests.map((interest) {
                              final isSelected =
                                  selectedInterests.contains(interest);
                              return FilterChip(
                                selected: isSelected,
                                label: Text(interest),
                                labelStyle: TextStyle(
                                  color:
                                      isSelected ? Colors.deepOrange : null,
                                ),
                                selectedColor:
                                    Colors.deepOrange.withOpacity(.15),
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
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.save),
                            label: Text(isSaving
                                ? 'Kaydediliyor…'
                                : 'Kaydet ve Geri Dön'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 14),
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
}

/// Başlık + GlassCard kombinasyonu (tekrarı azalttık)
class _LabeledCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _LabeledCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
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
          GlassCard(child: child),
        ],
      ),
    );
  }
}
