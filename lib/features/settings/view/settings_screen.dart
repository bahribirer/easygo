import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:easygo/main.dart';
import 'package:easygo/features/welcome/welcome_screen.dart';
import 'package:easygo/features/profile/edit/profile_edit_screen.dart';

import 'package:easygo/core/service/user_settings_service.dart';
import 'package:easygo/core/service/feedback_service.dart';
import 'package:easygo/core/service/auth_service.dart';

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
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadFromCache();
    _loadSettings();
  }

  Future<void> _loadFromCache() async {
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

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    final result = await UserSettingsService.getSettings(userId);
    if (result['success'] == true && mounted) {
      final s = result['settings'] ?? {};
      setState(() {
        messageFromEveryone = s['canReceiveMessages'] ?? false;
        showInSuggestions = s['showInSuggestions'] ?? false;
        followRequestsFromAll = s['allowFollowRequests'] ?? false;
        isPrivate = s['isPrivate'] ?? false;
        isDarkMode = s['isDarkMode'] ?? false;
      });

      await prefs.setBool('canReceiveMessages', messageFromEveryone);
      await prefs.setBool('showInSuggestions', showInSuggestions);
      await prefs.setBool('allowFollowRequests', followRequestsFromAll);
      await prefs.setBool('isPrivate', isPrivate);
      await prefs.setBool('darkMode', isDarkMode);
    }
  }

  Future<void> _updateSetting(
      String key, bool value, void Function(bool) setLocalState) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    setLocalState(value);
    await prefs.setBool(key, value);
    await UserSettingsService.updateSettings(
        userId: userId, updates: {key: value});
  }

  Future<void> _updateDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    await prefs.setBool('darkMode', value);
    await UserSettingsService.updateSettings(
        userId: userId, updates: {'isDarkMode': value});

    if (!mounted) return;
    setState(() => isDarkMode = value);
    ThemeProvider.of(context).toggleTheme(value);
  }

  Future<void> _performDelete(
      {required List<String> reasons, String? note}) async {
    if (_isDeleting) return;
    if (!mounted) return;
    setState(() => _isDeleting = true);

    try {
      // ✅ Anket backend’e gönderiliyor
      await FeedbackService.sendDeleteAccountFeedback(
          reasons: reasons, note: note);

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
          const SnackBar(
              content: Text('Hesap silinemedi. Lütfen tekrar deneyin.')),
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

  void _showDeleteSurvey() async {
  final selectedReasons = <String>{};
  final allReasons = <String>[
    "Uygulama beklentimi karşılamadı",
    "Çok fazla bildirim alıyorum",
    "Gizlilik endişeleri",
    "Başka bir hesap kullanıyorum",
  ];
  final noteCtrl = TextEditingController();

  final result = await showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: StatefulBuilder(
          builder: (ctx, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Hesabınızı neden silmek istiyorsunuz?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),

                // Çoklu seçim – Set ile güvenli
                ...allReasons.map((reason) {
                  final checked = selectedReasons.contains(reason);
                  return CheckboxListTile(
                    value: checked,
                    title: Text(reason),
                    onChanged: (val) {
                      setModalState(() {
                        if (val == true) {
                          selectedReasons.add(reason);
                        } else {
                          selectedReasons.remove(reason);
                        }
                      });
                    },
                  );
                }),

                const SizedBox(height: 8),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    labelText: "Eklemek istediğiniz bir not?",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  icon: const Icon(Icons.delete_forever, color: Colors.white),
                  label: const Text("Onayla ve Hesabı Sil",
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    // Sonucu modal’dan geri döndür
                    Navigator.pop(ctx, {
                      'confirm': true,
                      'reasons': selectedReasons.toList(),
                      'note': noteCtrl.text,
                    });
                  },
                ),
              ],
            );
          },
        ),
      );
    },
  );

  // Modal sonucu burada işleniyor
  if (result != null && result['confirm'] == true) {
    final reasons = List<String>.from(result['reasons'] ?? const []);
    final note = (result['note'] ?? '') as String;

    // Geçici debug: gerçekten dolu mu?
    // ignore: avoid_print
    print('DELETE SURVEY -> reasons=$reasons, note="$note"');

    if (reasons.isEmpty) {
      // İstersen burada kullanıcıya uyarı da gösterebilirsin:
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen en az bir neden seçin.')));
    }

    await _performDelete(reasons: reasons, note: note);
  }
}


  @override
  Widget build(BuildContext context) {
    final dark = isDarkMode;

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 180,
                  pinned: true,
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: dark
                            ? [Colors.deepPurple.shade900, Colors.black]
                            : [Colors.pinkAccent, Colors.orangeAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: FlexibleSpaceBar(
                      title: const Text("Ayarlar"),
                      background: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Icon(Icons.settings,
                              size: 64,
                              color: Colors.white.withOpacity(0.3)),
                        ),
                      ),
                    ),
                  ),
                ),

                // Profili Düzenle
                SliverToBoxAdapter(
                  child: _buildCard(
                    ListTile(
                      leading:
                          const Icon(Icons.edit_note, color: Colors.blueAccent),
                      title: const Text("Profili Düzenle"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfileEditScreen()),
                        );
                      },
                    ),
                  ),
                ),

                // Gizlilik
                SliverToBoxAdapter(
                  child: _buildSection("🔒 Gizlilik ve Görünürlük", [
                    _buildSwitchTile(
                      icon: Icons.message_outlined,
                      title: "Herkesten Mesaj Al",
                      subtitle:
                          "Kapalı olduğunda yalnızca takip ettiklerinden mesaj alırsın.",
                      value: messageFromEveryone,
                      onChanged: (val) => _updateSetting(
                          'canReceiveMessages',
                          val,
                          (v) =>
                              setState(() => messageFromEveryone = v)),
                    ),
                    _buildSwitchTile(
                      icon: Icons.recommend_outlined,
                      title: "Hesap Önerileri",
                      subtitle:
                          "Profilin önerilerde görünür. İstemiyorsan kapat.",
                      value: showInSuggestions,
                      onChanged: (val) => _updateSetting(
                          'showInSuggestions',
                          val,
                          (v) => setState(() => showInSuggestions = v)),
                    ),
                    _buildSwitchTile(
                      icon: Icons.person_add_alt_1,
                      title: "Takip İstekleri (Herkesten)",
                      subtitle:
                          "Kapalıysa yalnızca takip ettiklerin sana istek atabilir.",
                      value: followRequestsFromAll,
                      onChanged: (val) => _updateSetting(
                          'allowFollowRequests',
                          val,
                          (v) =>
                              setState(() => followRequestsFromAll = v)),
                    ),
                    _buildSwitchTile(
                      icon: Icons.lock_outline,
                      title: "Hesabı Gizliye Al",
                      subtitle: "Hesabını gizlemek için aç.",
                      value: isPrivate,
                      onChanged: (val) => _updateSetting(
                          'isPrivate', val, (v) => setState(() => isPrivate = v)),
                    ),
                  ]),
                ),

                // Görünüm
                SliverToBoxAdapter(
                  child: _buildSection("🎨 Görünüm", [
                    _buildSwitchTile(
                      icon: Icons.dark_mode_outlined,
                      title: "Karanlık Mod",
                      subtitle: "Uygulama temasını gece moduna al.",
                      value: isDarkMode,
                      onChanged: _updateDarkMode,
                    ),
                  ]),
                ),

                // Çıkış Yap
SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Card(
      color: Colors.grey.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.redAccent),
        title: const Text("Çıkış Yap",
            style: TextStyle(color: Colors.redAccent)),
        onTap: () async {
  await AuthService.signOut();
  if (!mounted) return;
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    (route) => false,
  );
}

      ),
    ),
  ),
),


                // Danger Zone
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      color: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: ListTile(
                        leading: const Icon(Icons.delete_forever,
                            color: Colors.white),
                        title: const Text("Hesabı Sil",
                            style: TextStyle(color: Colors.white)),
                        onTap: _showDeleteSurvey, // ✅ anket açılıyor
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: SizedBox(
                      height: 32 + MediaQuery.of(context).padding.bottom),
                ),
              ],
            ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: child,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return _buildCard(
      SwitchListTile(
        secondary: Icon(icon, color: Colors.blueAccent),
        title:
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        activeColor: Colors.blueAccent,
        onChanged: onChanged,
      ),
    );
  }
}
