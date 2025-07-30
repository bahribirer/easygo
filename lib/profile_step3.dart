import 'package:flutter/material.dart';
import 'profile_step4.dart';


class ProfileStep3Screen extends StatefulWidget {
  const ProfileStep3Screen({super.key});

  @override
  State<ProfileStep3Screen> createState() => _ProfileStep3ScreenState();
}

class _ProfileStep3ScreenState extends State<ProfileStep3Screen> {
  String? selectedCity;
  DateTime? selectedDate;
  final List<String> cities = [
    'İstanbul',
    'Ankara',
    'İzmir',
    'Bursa',
    'Antalya',
    'Samsun',
    'Konya',
    'Trabzon',
    'Adana',
    'Eskişehir'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profili Tamamla',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 38,
                  height: 38,
                  child: CircularProgressIndicator(
                    value: 0.75,
                    strokeWidth: 4,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.red,
                  ),
                ),
                const Text(
                  '%75',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              "Konum",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              value: selectedCity,
              hint: const Text("İl Seçiniz"),
              onChanged: (value) {
                setState(() {
                  selectedCity = value;
                });
              },
              items: cities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              "Doğum Tarihi",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: selectedDate == null
                        ? "GG.AA.YYYY"
                        : "${selectedDate!.day.toString().padLeft(2, '0')}.${selectedDate!.month.toString().padLeft(2, '0')}.${selectedDate!.year}",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(120, 50),
                  ),
                  child: const Text(
                    "Geri",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
  onPressed: selectedCity != null && selectedDate != null
      ? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileStep4Screen(),
            ),
          );
        }
      : null,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    minimumSize: const Size(120, 50),
  ),
  child: const Text(
    "Devam Et",
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
),

              ],
            ),
          ],
        ),
      ),
    );
  }
}