import 'package:easygo/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easygo/service/user_settings_service.dart';
import 'package:easygo/welcome_screen.dart';
import 'profile_edit_screen.dart';

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

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      final result = await UserSettingsService.getSettings(userId);
      final darkPref = prefs.getBool('darkMode') ?? false;

      if (result['success']) {
        final settings = result['settings'];
        setState(() {
          messageFromEveryone = settings['canReceiveMessages'] ?? false;
          showInSuggestions = settings['showInSuggestions'] ?? false;
          followRequestsFromAll = settings['allowFollowRequests'] ?? false;
          isPrivate = settings['isPrivate'] ?? false;
          isDarkMode = darkPref;
          isLoading = false;
        });
      } else {
        setState(() {
          isDarkMode = darkPref;
          isLoading = false;
        });
      }
    }
  }

  Future<void> updateSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    await UserSettingsService.updateSettings(userId: userId, updates: {key: value});
  }

  Future<void> updateDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() => isDarkMode = value);
    ThemeProvider.of(context).toggleTheme(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Başlık Alanı
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
      Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            "Ayarlar",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      IconButton(
        icon: const Icon(Icons.logout, color: Colors.white),
        onPressed: () {
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
                            );
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
                            setState(() => messageFromEveryone = val);
                            updateSetting('canReceiveMessages', val);
                          },
                        ),
                        buildToggleCard(
                          icon: Icons.recommend_outlined,
                          title: "Hesap Önerileri",
                          subtitle: "Profilin önerilerde görünür. İstemiyorsan kapat.",
                          value: showInSuggestions,
                          onChanged: (val) {
                            setState(() => showInSuggestions = val);
                            updateSetting('showInSuggestions', val);
                          },
                        ),
                        buildToggleCard(
                          icon: Icons.person_add_alt_1,
                          title: "Takip İstekleri (Herkesten)",
                          subtitle: "Kapalıysa yalnızca takip ettiklerin sana istek atabilir.",
                          value: followRequestsFromAll,
                          onChanged: (val) {
                            setState(() => followRequestsFromAll = val);
                            updateSetting('allowFollowRequests', val);
                          },
                        ),
                        buildToggleCard(
                          icon: Icons.lock_outline,
                          title: "Hesabı Gizliye Al",
                          subtitle: "Hesabını gizlemek için aç.",
                          value: isPrivate,
                          onChanged: (val) {
                            setState(() => isPrivate = val);
                            updateSetting('isPrivate', val);
                          },
                        ),
                        buildToggleCard(
                          icon: Icons.dark_mode,
                          title: "Karanlık Mod",
                          subtitle: "Uygulama temasını gece moduna al.",
                          value: isDarkMode,
                          onChanged: (val) {
                            updateDarkMode(val);
                          },
                        ),
                      ],
                    ),
                  ),
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
