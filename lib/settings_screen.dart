import 'package:easygo/main.dart';
import 'package:easygo/service/feedback_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easygo/service/user_settings_service.dart';
import 'package:easygo/welcome_screen.dart';
import 'profile_edit_screen.dart';
import 'package:easygo/service/auth_service.dart'; // hesabı silmek için

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool messageFromEveryone = false;
  bool showInSuggestions = false;
  bool followRequestsFromAll = false;
  bool isPrivate = false;
  bool isDarkMode = false;
  bool isLoading = true;

  bool _isDeleting = false; // silme sırasında buton kilitle

  @override
  void initState() {
    super.initState();
    loadFromCache();
    loadSettings();
  }

  Future<void> loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      messageFromEveryone = prefs.getBool('canReceiveMessages') ?? false;
      showInSuggestions = prefs.getBool('showInSuggestions') ?? false;
      followRequestsFromAll = prefs.getBool('allowFollowRequests') ?? false;
      isPrivate = prefs.getBool('isPrivate') ?? false;
      isDarkMode = prefs.getBool('darkMode') ?? false;
      isLoading = false;
    });
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    final result = await UserSettingsService.getSettings(userId);
    if (!(result['success'] == true)) return;

    final settings = result['settings'];
    if (!mounted) return;
    setState(() {
      messageFromEveryone = settings['canReceiveMessages'] ?? false;
      showInSuggestions = settings['showInSuggestions'] ?? false;
      followRequestsFromAll = settings['allowFollowRequests'] ?? false;
      isPrivate = settings['isPrivate'] ?? false;
      isDarkMode = settings['isDarkMode'] ?? false;
    });

    // Cache’e kaydet
    await prefs.setBool('canReceiveMessages', messageFromEveryone);
    await prefs.setBool('showInSuggestions', showInSuggestions);
    await prefs.setBool('allowFollowRequests', followRequestsFromAll);
    await prefs.setBool('isPrivate', isPrivate);
    await prefs.setBool('darkMode', isDarkMode);
  }

  Future<void> updateSetting(String key, bool value, void Function(bool) setLocalState) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    setLocalState(value);
    await prefs.setBool(key, value);
    await UserSettingsService.updateSettings(userId: userId, updates: {key: value});
  }

  Future<void> updateDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    await prefs.setBool('darkMode', value);
    await UserSettingsService.updateSettings(userId: userId, updates: {'isDarkMode': value});

    if (!mounted) return;
    setState(() => isDarkMode = value);
    ThemeProvider.of(context).toggleTheme(value);
  }

  // =======================
  //   HESAP SİLME BLOKU
  // =======================

  // Sheet’i açar; true dönerse silme işlemini başlatırız
  Future<void> _openDeleteSheet() async {
  final result = await showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => const _DeleteAccountSheet(),
  );

  if (result != null && result['confirm'] == true) {
    await _performDelete(
      reasons: List<String>.from(result['reasons'] ?? []),
      note: result['note'] ?? '',
    );
  }
}

Future<void> _performDelete({required List<String> reasons, String? note}) async {
  if (_isDeleting) return;
  if (!mounted) return;
  setState(() => _isDeleting = true);

  try {
    // 1- Önce feedback gönder
    await FeedbackService.sendDeleteAccountFeedback(reasons: reasons, note: note);

    // 2- Hesabı sil
    final ok = await AuthService.deleteAndSignOut();
    if (!mounted) return;
    if (ok) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hesap silinemedi. Lütfen tekrar deneyin.')),
      );
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Hata: $e')),
    );
  } finally {
    if (mounted) setState(() => _isDeleting = false);
  }
}


  static Widget _dangerBullet(String text) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.error_outline, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Başlık
                Container(
                  padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF6F61), Color(0xFFFF9472)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Ayarlar",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          if (!mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Profil düzenleme
                        ElevatedButton.icon(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text("Profili Düzenle", style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                        const SizedBox(height: 30),

                        buildToggleCard(
                          icon: Icons.message_outlined,
                          title: "Herkesten Mesaj Al",
                          subtitle: "Kapalı olduğunda yalnızca takip ettiklerinden mesaj alırsın",
                          value: messageFromEveryone,
                          onChanged: (val) {
                            updateSetting('canReceiveMessages', val, (v) => setState(() => messageFromEveryone = v));
                          },
                        ),
                        buildToggleCard(
                          icon: Icons.recommend_outlined,
                          title: "Hesap Önerileri",
                          subtitle: "Profilin önerilerde görünür. İstemiyorsan kapat.",
                          value: showInSuggestions,
                          onChanged: (val) {
                            updateSetting('showInSuggestions', val, (v) => setState(() => showInSuggestions = v));
                          },
                        ),
                        buildToggleCard(
                          icon: Icons.person_add_alt_1,
                          title: "Takip İstekleri (Herkesten)",
                          subtitle: "Kapalıysa yalnızca takip ettiklerin sana istek atabilir.",
                          value: followRequestsFromAll,
                          onChanged: (val) {
                            updateSetting('allowFollowRequests', val, (v) => setState(() => followRequestsFromAll = v));
                          },
                        ),
                        buildToggleCard(
                          icon: Icons.lock_outline,
                          title: "Hesabı Gizliye Al",
                          subtitle: "Hesabını gizlemek için aç.",
                          value: isPrivate,
                          onChanged: (val) {
                            updateSetting('isPrivate', val, (v) => setState(() => isPrivate = v));
                          },
                        ),
                        buildToggleCard(
                          icon: Icons.dark_mode,
                          title: "Karanlık Mod",
                          subtitle: "Uygulama temasını gece moduna al.",
                          value: isDarkMode,
                          onChanged: updateDarkMode,
                        ),

                        const SizedBox(height: 28),
                        _dangerZoneCard(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _dangerZoneCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(.18)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tehlikeli Bölge',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.red)),
          const SizedBox(height: 8),
          const Text(
            'Hesabını silersen tüm verilerin kalıcı olarak kaldırılır. Bu işlem geri alınamaz.',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isDeleting ? null : _openDeleteSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            icon: const Icon(Icons.delete_forever),
            label: Text(_isDeleting ? 'Siliniyor…' : 'Hesabı Sil'),
          ),
        ],
      ),
    );
  }

  Widget buildToggleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.deepOrange.shade50,
          child: Icon(icon, color: Colors.deepOrange),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}

/// Alt sayfa (bottom sheet) — kendi controller’ını yönetir ve dispose eder.
/// Sheet kapandıktan sonra parent silme işlemini başlatır, bu sayede
/// "controller used after dispose" ve assertion hataları yaşanmaz.
class _DeleteAccountSheet extends StatefulWidget {
  const _DeleteAccountSheet({Key? key}) : super(key: key);

  @override
  State<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<_DeleteAccountSheet> {
  final reasons = <String>[
    'Uygulamayı artık kullanmıyorum',
    'Gizlilik/Veri endişeleri',
    'Bildirimler rahatsız etti',
    'Teknik sorunlar yaşadım',
    'Başka bir uygulamaya geçtim',
    'Diğer',
  ];
  final selected = <String>{};
  final noteCtrl = TextEditingController();
  bool confirm = false;

  @override
  void dispose() {
    noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final maxH = mq.size.height * 0.9;

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                ),
                const Text('Hesabı Silmeden Önce',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                _dangerBullet('Bu işlem kalıcıdır ve geri alınamaz.'),
                _dangerBullet('Profil ve ayarlar dahil tüm verilerin silinir.'),
                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Neden silmek istiyorsun? (opsiyonel)',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800]),
                  ),
                ),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: reasons.map((r) {
                    final isSel = selected.contains(r);
                    return ChoiceChip(
                      label: Text(r),
                      selected: isSel,
                      onSelected: (v) => setState(() {
                        if (v) {
                          selected.add(r);
                        } else {
                          selected.remove(r);
                        }
                      }),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Eklemek istediğin bir not var mı?',
                    hintText: 'Kısaca yazabilirsin…',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: confirm,
                  onChanged: (v) => setState(() => confirm = v ?? false),
                  title: const Text('Eminim. Hesabımı kalıcı olarak silmek istiyorum.'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                        child: const Text('Vazgeç'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
  onPressed: confirm
      ? () => Navigator.pop(context, {
            'confirm': true,
            'reasons': selected.toList(),
            'note': noteCtrl.text.trim(),
          })
      : null,
  style: ElevatedButton.styleFrom(
    minimumSize: const Size.fromHeight(48),
    backgroundColor: Colors.red,
  ),
  icon: const Icon(Icons.delete_forever),
  label: const Text('Hesabı Sil'),
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
  }

  Widget _dangerBullet(String text) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.error_outline, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      );
}
