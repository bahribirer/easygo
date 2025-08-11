import 'package:easygo/helpers/city_helper.dart';
import 'package:easygo/service/user_profile_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_step4.dart';

class ProfileStep3Screen extends StatefulWidget {
  const ProfileStep3Screen({super.key});

  @override
  State<ProfileStep3Screen> createState() => _ProfileStep3ScreenState();
}

class _ProfileStep3ScreenState extends State<ProfileStep3Screen> {
  String? selectedCity;
  DateTime? selectedDate;
  final List<String> cities = turkishCities;

  // UI state
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

  String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString().padLeft(4, '0');
    return '$dd.$mm.$yy';
  }

  String _fmtIso(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final yy = d.year.toString().padLeft(4, '0');
    return '$yy-$mm-$dd';
  }

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
                          _Header(progress: 0.75),
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

                          // City Card
                          _GlassCard(
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

                          // Birth Date Card
                          _GlassCard(
                            title: 'Doğum Tarihi',
                            child: GestureDetector(
                              onTap: _pickDate,
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.cake_outlined),
                                    labelText: 'Doğum Tarihi',
                                    hintText: 'GG.AA.YYYY',
                                    border: const OutlineInputBorder(),
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

                          // Actions
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

class _Header extends StatelessWidget {
  final double progress; // 0..1
  const _Header({required this.progress});

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const _StepTitle(),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 4,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEA5455)),
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            Text('%$pct', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.flag_rounded, color: Color(0xFFEA5455)),
        const SizedBox(width: 8),
        Text(
          'Profili Tamamla',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.grey.shade900,
          ),
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _GlassCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor.withOpacity(.95);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ]),
    );
  }
}
