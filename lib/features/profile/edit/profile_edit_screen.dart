import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Servis & yardımcılar
import 'package:easygo/core/service/user_profile_service.dart';
import 'package:easygo/helpers/interests_helper.dart';
import 'package:easygo/helpers/city_helper.dart';
import 'package:easygo/features/profile/view/profile_screen.dart';
import 'package:easygo/l10n/app_localizations.dart';

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
List<String> selectedInterests = []; // sadece KEY'ler tutulacak
  String? selectedCity;
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
        final profile = result['profile'] as Map<String, dynamic>;
        nameController.text = profile['name'] ?? '';
        final raw = profile['birthDate'];
        if (raw is String && raw.isNotEmpty) {
          try {
            final dt = DateTime.parse(raw);
            isoBirthDate = _toIsoDate(dt);
            birthDateController.text = _formatDateForDisplay(dt);
          } catch (_) {}
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

  String _formatDateForDisplay(DateTime dt) =>
      "${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}";

  String _toIsoDate(DateTime dt) =>
      "${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";

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
    final loc = AppLocalizations.of(context)!;
    final initial =
        (isoBirthDate != null) ? DateTime.tryParse(isoBirthDate!) : null;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      helpText: loc.birthDateHelp,
      cancelText: loc.cancel,
      confirmText: loc.ok,
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
  name: nameController.text.trim().isEmpty ? null : nameController.text.trim(),
  birthDate: isoBirthDate,
  location: selectedCity,
  interests: selectedInterests, // 🔹 key listesi gidiyor
  profilePhoto: (profileImageBytes != null) ? base64Encode(profileImageBytes!) : null,
);


    if (!mounted) return;
    setState(() => isSaving = false);

    if (result['success'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    } else {
      _toast(result['message'] ?? AppLocalizations.of(context)!.genericError);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final bg = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF0F0F10)
        : const Color(0xFFFFF8F3);

    return Scaffold(
      backgroundColor: bg,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 180,
                  pinned: true,
                  backgroundColor: Colors.deepOrange,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(loc.editProfileTitle),
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF6F61), Color(0xFFFF9472)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Profil Fotoğrafı
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: profileImageBytes != null
                                  ? MemoryImage(profileImageBytes!)
                                  : const AssetImage('assets/profile.jpg')
                                      as ImageProvider,
                            ),
                            FloatingActionButton.small(
                              backgroundColor: Colors.deepOrange,
                              onPressed: _pickImage,
                              child: const Icon(Icons.edit, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Ad
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            filled: true,
                            prefixIcon: const Icon(Icons.person),
                            labelText: loc.editProfileName,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Doğum Tarihi
                        GestureDetector(
                          onTap: _selectDate,
                          child: AbsorbPointer(
                            child: TextField(
                              controller: birthDateController,
                              decoration: InputDecoration(
                                filled: true,
                                prefixIcon: const Icon(Icons.cake_outlined),
                                labelText: loc.editProfileBirthDate,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Şehir
                        DropdownButtonFormField<String>(
                          value: selectedCity,
                          decoration: InputDecoration(
                            filled: true,
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            labelText: loc.editProfileCity,
                            border: const OutlineInputBorder(),
                          ),
                          items: turkishCities
                              .map((c) =>
                                  DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) => setState(() => selectedCity = v),
                        ),
                        const SizedBox(height: 20),

                        // İlgi Alanları
                        // İlgi Alanları
// İlgi Alanları
Align(
  alignment: Alignment.centerLeft,
  child: Text(
    loc.editProfileInterests,
    style: Theme.of(context).textTheme.titleMedium,
  ),
),
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: InterestsHelper.keys.map((key) {
    final label = InterestsHelper.label(context, key); // 🔹 çeviri
    final isSelected = selectedInterests.contains(key);

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.deepOrange,
      onSelected: (sel) {
        setState(() {
          if (sel) {
            selectedInterests.add(key);
          } else {
            selectedInterests.remove(key);
          }
        });
      },
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
      ),
    );
  }).toList(),
),


                        const SizedBox(height: 30),

                        // Kaydet Butonu
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isSaving ? null : _save,
                            icon: isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.save),
                            label: Text(isSaving
                                ? loc.editProfileSaving
                                : loc.editProfileSave),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
