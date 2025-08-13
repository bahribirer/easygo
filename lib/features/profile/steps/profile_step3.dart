import 'package:easygo/helpers/city_helper.dart';
import 'package:easygo/core/service/user_profile_service.dart';
import 'package:easygo/features/profile/steps/profile_step4.dart';
import 'package:easygo/features/profile/steps/profile_step_common.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileStep3Screen extends StatefulWidget {
  const ProfileStep3Screen({super.key});

  @override
  State<ProfileStep3Screen> createState() => _ProfileStep3ScreenState();
}

class _ProfileStep3ScreenState extends State<ProfileStep3Screen> {
  String? selectedCity;
  DateTime? selectedDate;
  final List<String> cities = turkishCities;
  bool _saving = false;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = DateTime(2000, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? initial,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Doğum Tarihini Seç',
      cancelText: 'İptal',
      confirmText: 'Tamam',
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  String _fmtIso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _saveAndNext() async {
    if (selectedCity == null || selectedDate == null || _saving) return;
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

      final res = await UserProfileService.updateOrCreateProfile(
        userId: userId,
        birthDate: _fmtIso(selectedDate!),
        location: selectedCity,
      );

      if (!mounted) return;
      if (res['success'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileStep4Screen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Hata oluştu')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padBottom = MediaQuery.of(context).viewInsets.bottom;
    final isFormValid = selectedCity != null && selectedDate != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.only(bottom: padBottom),
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const StepHeader(progress: 0.75),
                          const SizedBox(height: 20),

                          Text(
                            'Konum ve Doğum Tarihi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey.shade900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Seni daha iyi tanımamıza yardım et. Konumun keşfet içeriklerinde, yaşın ise önerilerde daha iyi eşleşmeler için kullanılır.',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 20),

                          StepTitledCard(
                            title: 'Konum',
                            child: DropdownButtonFormField<String>(
                              value: selectedCity,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.location_on_outlined),
                                labelText: 'İl Seçiniz',
                                border: OutlineInputBorder(),
                              ),
                              items: cities
                                  .map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(() => selectedCity = v),
                            ),
                          ),

                          StepTitledCard(
                            title: 'Doğum Tarihi',
                            child: GestureDetector(
                              onTap: _pickDate,
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.cake_outlined),
                                    labelText: 'Doğum Tarihi',
                                    hintText: 'GG.AA.YYYY',
                                    border: OutlineInputBorder(),
                                  ),
                                  controller: TextEditingController(
                                    text: selectedDate == null ? '' : _fmtDate(selectedDate!),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          if (!isFormValid)
                            Row(
                              children: const [
                                Icon(Icons.info_outline, size: 18, color: Colors.orange),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Devam etmek için şehir ve doğum tarihi seçmelisin.',
                                    style: TextStyle(color: Colors.orange, fontSize: 12.5),
                                  ),
                                ),
                              ],
                            ),

                          const Spacer(),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(52),
                                    side: BorderSide(color: Colors.orange.shade700),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    'Geri',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: isFormValid && !_saving ? _saveAndNext : null,
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
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.arrow_forward_rounded),
                                  label: Text(_saving ? 'Kaydediliyor…' : 'Devam Et'),
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
