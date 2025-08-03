import 'package:easygo/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easygo/service/user_profile_service.dart';
import 'package:easygo/helpers/interests_helper.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  List<String> selectedInterests = [];
  String? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');

    if (userId != null) {
      final result = await UserProfileService.getProfile(userId!);
      if (result['success']) {
        final profile = result['profile'];
        nameController.text = profile['name'] ?? '';
        birthDateController.text = profile['birthDate']?.substring(0, 10) ?? '';
        selectedInterests = List<String>.from(profile['interests'] ?? []);
      }
    }

    setState(() => isLoading = false);
  }

  Future<void> updateProfile() async {
    if (userId == null) return;

    final result = await UserProfileService.updateOrCreateProfile(
      userId: userId!,
      birthDate: birthDateController.text,
      interests: selectedInterests,
    );

    if (result['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Hata oluştu')),
      );
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final initialDate = DateTime.tryParse(birthDateController.text) ?? DateTime(2000);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        birthDateController.text = picked.toIso8601String().substring(0, 10);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 24),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Profili Düzenle",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: "Kullanıcı Adı",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: GestureDetector(
                              onTap: () => selectDate(context),
                              child: AbsorbPointer(
                                child: TextField(
                                  controller: birthDateController,
                                  decoration: const InputDecoration(
                                    labelText: "Doğum Tarihi",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text("İlgi Alanları", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: allInterests.map((interest) {
                            final isSelected = selectedInterests.contains(interest);
                            return FilterChip(
                              label: Text(interest),
                              selected: isSelected,
                              selectedColor: Colors.deepOrange.shade100,
                              backgroundColor: Colors.grey.shade100,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.deepOrange : Colors.black,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  isSelected
                                      ? selectedInterests.remove(interest)
                                      : selectedInterests.add(interest);
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 40),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: updateProfile,
                            icon: const Icon(Icons.save),
                            label: const Text("Kaydet ve Geri Dön"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
