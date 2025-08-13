import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:easygo/main.dart';
import 'package:easygo/features/welcome/welcome_screen.dart';
import 'package:easygo/features/profile/edit/profile_edit_screen.dart';

import 'package:easygo/core/service/user_settings_service.dart';
import 'package:easygo/core/service/feedback_service.dart';
import 'package:easygo/core/service/auth_service.dart';

import 'package:easygo/features/settings/widgetsettings/fancy_header.dart';
import 'package:easygo/features/settings/widgetsettings/primary_action_card.dart';
import 'package:easygo/features/settings/widgetsettings/section_card.dart';
import 'package:easygo/features/settings/widgetsettings/setting_tile.dart';
import 'package:easygo/features/settings/widgetsettings/danger_zone.dart';
import 'package:easygo/features/settings/widgetsettings/delete_account_sheet.dart';

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
        showInSuggestions  = s['showInSuggestions'] ?? false;
        followRequestsFromAll = s['allowFollowRequests'] ?? false;
        isPrivate          = s['isPrivate'] ?? false;
        isDarkMode         = s['isDarkMode'] ?? false;
      });

      await prefs.setBool('canReceiveMessages', messageFromEveryone);
      await prefs.setBool('showInSuggestions', showInSuggestions);
      await prefs.setBool('allowFollowRequests', followRequestsFromAll);
      await prefs.setBool('isPrivate', isPrivate);
      await prefs.setBool('darkMode', isDarkMode);
    }
  }

  Future<void> _updateSetting(
    String key,
    bool value,
    void Function(bool) setLocalState,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    setLocalState(value);
    await prefs.setBool(key, value);
    await UserSettingsService.updateSettings(userId: userId, updates: {key: value});
  }

  Future<void> _updateDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    await prefs.setBool('darkMode', value);
    await UserSettingsService.updateSettings(userId: userId, updates: {'isDarkMode': value});

    if (!mounted) return;
    setState(() => isDarkMode = value);
    ThemeProvider.of(context).toggleTheme(value);
  }

  Future<void> _openDeleteSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: isDarkMode ? const Color(0xFF111111) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DeleteAccountSheet(dark: isDarkMode),
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
      await FeedbackService.sendDeleteAccountFeedback(reasons: reasons, note: note);
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

  @override
  Widget build(BuildContext context) {
    final dark = isDarkMode;
    final bg = dark ? Colors.black : const Color(0xFFFFF7F3);

    return Scaffold(
      backgroundColor: bg,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              bottom: true,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  FancyHeader(
                    title: 'Ayarlar',
                    dark: dark,
                    onBack: () => Navigator.pop(context),
                    onLogout: () async {
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

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: PrimaryActionCard(
                        icon: Icons.edit_outlined,
                        label: 'Profili Düzenle',
                        dark: dark,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
                          );
                        },
                      ),
                    ),
                  ),

                  // Gizlilik
                  SliverToBoxAdapter(
                    child: SectionCard(
                      title: 'Gizlilik ve Görünürlük',
                      dark: dark,
                      children: [
                        SettingTile(
                          dark: dark,
                          icon: Icons.message_outlined,
                          title: 'Herkesten Mesaj Al',
                          subtitle: 'Kapalı olduğunda yalnızca takip ettiklerinden mesaj alırsın.',
                          value: messageFromEveryone,
                          onChanged: (val) => _updateSetting(
                            'canReceiveMessages', val, (v) => setState(() => messageFromEveryone = v)),
                        ),
                        SettingTile(
                          dark: dark,
                          icon: Icons.recommend_outlined,
                          title: 'Hesap Önerileri',
                          subtitle: 'Profilin önerilerde görünür. İstemiyorsan kapat.',
                          value: showInSuggestions,
                          onChanged: (val) => _updateSetting(
                            'showInSuggestions', val, (v) => setState(() => showInSuggestions = v)),
                        ),
                        SettingTile(
                          dark: dark,
                          icon: Icons.person_add_alt_1,
                          title: 'Takip İstekleri (Herkesten)',
                          subtitle: 'Kapalıysa yalnızca takip ettiklerin sana istek atabilir.',
                          value: followRequestsFromAll,
                          onChanged: (val) => _updateSetting(
                            'allowFollowRequests', val, (v) => setState(() => followRequestsFromAll = v)),
                        ),
                        SettingTile(
                          dark: dark,
                          icon: Icons.lock_outline,
                          title: 'Hesabı Gizliye Al',
                          subtitle: 'Hesabını gizlemek için aç.',
                          value: isPrivate,
                          onChanged: (val) => _updateSetting(
                            'isPrivate', val, (v) => setState(() => isPrivate = v)),
                        ),
                      ],
                    ),
                  ),

                  // Görünüm
                  SliverToBoxAdapter(
                    child: SectionCard(
                      title: 'Görünüm',
                      dark: dark,
                      children: [
                        SettingTile(
                          dark: dark,
                          icon: Icons.dark_mode_outlined,
                          title: 'Karanlık Mod',
                          subtitle: 'Uygulama temasını gece moduna al.',
                          value: isDarkMode,
                          onChanged: _updateDarkMode,
                        ),
                      ],
                    ),
                  ),

                  // Tehlikeli Bölge
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: DangerZone(
                        dark: dark,
                        isDeleting: _isDeleting,
                        onDelete: _openDeleteSheet,
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(height: 24 + MediaQuery.of(context).padding.bottom),
                  ),
                ],
              ),
            ),
    );
  }
}
