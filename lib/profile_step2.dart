import 'package:flutter/material.dart';
import 'profile_step3.dart';

class ProfileStep2Screen extends StatefulWidget {
  const ProfileStep2Screen({super.key});

  @override
  State<ProfileStep2Screen> createState() => _ProfileStep2ScreenState();
}

class _ProfileStep2ScreenState extends State<ProfileStep2Screen> {
  final List<String> selectedInterests = [];
  final List<String> allInterests = [
    'Yoga', 'Koşu', 'Yüzme', 'Basketbol', 'Futbol', 'Tenis',
    'Bisiklet Sürme', 'Kaya Tırmanışı', 'Doğa Yürüyüşü',
    'Gym & Fitness', 'Dövüş Sanatları', 'Golf', 'Voleybol', 'Kayak', 'Sörf'
  ];

  void toggleInterest(String interest) {
    setState(() {
      if (selectedInterests.contains(interest)) {
        selectedInterests.remove(interest);
      } else {
        selectedInterests.add(interest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(progress: 50),
              const SizedBox(height: 20),
              const Text("İlgi Alanları", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              const Text(
                '"Hayatını renklendiren tutkularını paylaş! İlgi alanlarınla kendini ifade et.\nEn az 5 ilgi alanı seç."',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allInterests.map((interest) {
                  final bool isSelected = selectedInterests.contains(interest);
                  return ChoiceChip(
                    label: Text(interest),
                    selected: isSelected,
                    onSelected: (_) => toggleInterest(interest),
                    selectedColor: Colors.red.shade100,
                    backgroundColor: Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.red.shade800 : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              Row(
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(100, 50),
                      side: BorderSide(color: Colors.orange.shade700),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Geri"),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: selectedInterests.length >= 5
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileStep3Screen(),
                                ),
                              );
                            }
                          : null,
                      child: const Text("Devam Et"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({required int progress}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Profili Tamamla",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                value: progress / 100,
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            Text("%$progress", style: const TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }
}