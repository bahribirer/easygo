import 'package:easygo/main.dart';
import 'package:easygo/service/feedback_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easygo/service/user_settings_service.dart';
import 'package:easygo/welcome_screen.dart';
import 'profile_edit_screen.dart';
import 'package:easygo/service/auth_service.dart';

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
    if (result['success'] == true && mounted) {
      final settings = result['settings'] ?? {};
      setState(() {
        messageFromEveryone = settings['canReceiveMessages'] ?? false;
        showInSuggestions = settings['showInSuggestions'] ?? false;
        followRequestsFromAll = settings['allowFollowRequests'] ?? false;
        isPrivate = settings['isPrivate'] ?? false;
        isDarkMode = settings['isDarkMode'] ?? false;
      });

      await prefs.setBool('canReceiveMessages', messageFromEveryone);
      await prefs.setBool('showInSuggestions', showInSuggestions);
      await prefs.setBool('allowFollowRequests', followRequestsFromAll);
      await prefs.setBool('isPrivate', isPrivate);
      await prefs.setBool('darkMode', isDarkMode);
    }
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

    // Uygulama temasını da değiştir
    ThemeProvider.of(context).toggleTheme(value);
  }

  // =======================
  //   HESAP SİLME BLOKU
  // =======================

  Future<void> _openDeleteSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: isDarkMode ? const Color(0xFF111111) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _DeleteAccountSheet(dark: isDarkMode),
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
    final bool dark = isDarkMode; // ekran paleti için kendi bayrağımız
    final Color bg = dark ? Colors.black : const Color(0xFFFFF7F3);

    return Scaffold(
      backgroundColor: bg,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea( // overflow’u azaltır, çentik/gesture alanlarını korur
              bottom: true,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _FancyHeader(
                    title: 'Ayarlar',
                    dark: dark,
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
                    onBack: () => Navigator.pop(context),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: _PrimaryActionCard(
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
                    child: _SectionCard(
                      title: 'Gizlilik ve Görünürlük',
                      dark: dark,
                      children: [
                        _SettingTile(
                          dark: dark,
                          icon: Icons.message_outlined,
                          title: 'Herkesten Mesaj Al',
                          subtitle: 'Kapalı olduğunda yalnızca takip ettiklerinden mesaj alırsın.',
                          value: messageFromEveryone,
                          onChanged: (val) => updateSetting(
                            'canReceiveMessages',
                            val,
                            (v) => setState(() => messageFromEveryone = v),
                          ),
                        ),
                        _SettingTile(
                          dark: dark,
                          icon: Icons.recommend_outlined,
                          title: 'Hesap Önerileri',
                          subtitle: 'Profilin önerilerde görünür. İstemiyorsan kapat.',
                          value: showInSuggestions,
                          onChanged: (val) => updateSetting(
                            'showInSuggestions',
                            val,
                            (v) => setState(() => showInSuggestions = v),
                          ),
                        ),
                        _SettingTile(
                          dark: dark,
                          icon: Icons.person_add_alt_1,
                          title: 'Takip İstekleri (Herkesten)',
                          subtitle: 'Kapalıysa yalnızca takip ettiklerin sana istek atabilir.',
                          value: followRequestsFromAll,
                          onChanged: (val) => updateSetting(
                            'allowFollowRequests',
                            val,
                            (v) => setState(() => followRequestsFromAll = v),
                          ),
                        ),
                        _SettingTile(
                          dark: dark,
                          icon: Icons.lock_outline,
                          title: 'Hesabı Gizliye Al',
                          subtitle: 'Hesabını gizlemek için aç.',
                          value: isPrivate,
                          onChanged: (val) => updateSetting(
                            'isPrivate',
                            val,
                            (v) => setState(() => isPrivate = v),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Görünüm
                  SliverToBoxAdapter(
                    child: _SectionCard(
                      title: 'Görünüm',
                      dark: dark,
                      children: [
                        _SettingTile(
                          dark: dark,
                          icon: Icons.dark_mode_outlined,
                          title: 'Karanlık Mod',
                          subtitle: 'Uygulama temasını gece moduna al.',
                          value: isDarkMode,
                          onChanged: updateDarkMode,
                        ),
                      ],
                    ),
                  ),

                  // Tehlikeli Bölge
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: _DangerZone(
                        dark: dark,
                        isDeleting: _isDeleting,
                        onDelete: _openDeleteSheet,
                      ),
                    ),
                  ),

                  // Altta nefes
                  SliverToBoxAdapter(
  child: SizedBox(height: 24 + MediaQuery.of(context).padding.bottom),
),

                ],
              ),
            ),
    );
  }
}

// =================== UI Bileşenleri ===================

class _FancyHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onLogout;
  final bool dark;

  const _FancyHeader({
    required this.title,
    required this.onBack,
    required this.onLogout,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final coverH = (MediaQuery.of(context).size.height * 0.22).clamp(160.0, 220.0);
    return SliverAppBar(
      automaticallyImplyLeading: false, // ✅ ikinci geri ok bitti
      pinned: true,
      expandedHeight: coverH,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          // Arka plan: dark ise full black, değilse gradient
          Container(
            decoration: BoxDecoration(
              gradient: dark
                  ? const LinearGradient(
                      colors: [Colors.black, Colors.black],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFFF6F61), Color(0xFFFF9472)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
          ),
          if (!dark) Opacity(opacity: 0.06, child: Container(color: Colors.white)),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                12,
                MediaQuery.of(context).padding.top + 6,
                12,
                14,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: onBack,
                        tooltip: 'Geri',
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: onLogout,
                        tooltip: 'Çıkış Yap',
                      ),
                    ],
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool dark;

  const _PrimaryActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = dark ? const Color(0xFF111111) : Theme.of(context).cardColor;
    final border = dark ? const Color(0xFF222222) : Colors.grey.shade200;
    final textColor = dark ? Colors.white : Colors.black87;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: dark ? const Color(0xFF222222) : const Color(0xFFFFE3D6),
              child: Icon(icon, color: dark ? Colors.white : Colors.deepOrange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: textColor),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: dark ? Colors.white60 : Colors.black45),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool dark;

  const _SectionCard({required this.title, required this.children, required this.dark});

  @override
  Widget build(BuildContext context) {
    final cardColor = dark ? const Color(0xFF111111) : Theme.of(context).cardColor;
    final border = dark ? const Color(0xFF222222) : Colors.grey.shade200;
    final titleColor = dark ? Colors.white : Colors.black87;
    final dividerColor = dark ? const Color(0xFF222222) : Colors.grey.shade200;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: titleColor),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: dividerColor),
            ..._withDividers(children, dividerColor),
          ],
        ),
      ),
    );
  }

  List<Widget> _withDividers(List<Widget> tiles, Color divider) {
    final out = <Widget>[];
    for (var i = 0; i < tiles.length; i++) {
      out.add(tiles[i]);
      if (i != tiles.length - 1) out.add(Divider(height: 1, color: divider));
    }
    return out;
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool dark;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(fontWeight: FontWeight.w700, color: dark ? Colors.white : Colors.black87);
    final subtitleStyle = TextStyle(fontSize: 12, color: dark ? Colors.white70 : Colors.grey.shade700);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: dark ? const Color(0xFF222222) : const Color(0xFFFFE3D6),
        child: Icon(icon, color: dark ? Colors.white : Colors.deepOrange),
      ),
      title: Text(title, style: titleStyle),
      subtitle: Text(subtitle, style: subtitleStyle),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: dark ? Colors.white : null,
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  final bool isDeleting;
  final VoidCallback onDelete;
  final bool dark;
  const _DangerZone({required this.dark, required this.isDeleting, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cardColor = dark ? const Color(0xFF111111) : Theme.of(context).cardColor;
    final border = dark ? const Color(0x33FF0000) : Colors.red.withOpacity(.18);
    final textColor = dark ? Colors.white : Colors.black87;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'Tehlikeli Bölge',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: dark ? Colors.red.shade300 : Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Hesabını silersen tüm verilerin kalıcı olarak kaldırılır. Bu işlem geri alınamaz.',
          style: TextStyle(fontSize: 13, color: textColor),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: isDeleting ? null : onDelete,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          icon: const Icon(Icons.delete_forever),
          label: Text(isDeleting ? 'Siliniyor…' : 'Hesabı Sil'),
        ),
      ]),
    );
  }
}

/// Alt sayfa — anket + onay
class _DeleteAccountSheet extends StatefulWidget {
  final bool dark;
  const _DeleteAccountSheet({Key? key, required this.dark}) : super(key: key);

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

  bool get dark => widget.dark;

  @override
  void dispose() {
    noteCtrl.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  final mq = MediaQuery.of(context);
  final bool dark = widget.dark;

  final bg = dark ? const Color(0xFF111111) : Colors.white;
  final text = dark ? Colors.white : Colors.black87;
  final chipBg = dark ? const Color(0xFF222222) : Colors.grey.shade100;
  final chipSel = dark ? const Color(0x33FF5252) : Colors.red.shade50;
  final border = dark ? const Color(0xFF222222) : Colors.black12;

  return FractionallySizedBox(
    heightFactor: 0.92, // 👈 sheet yüksekliği ekranın %92’si
    child: SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bottomSafe = mq.padding.bottom;
          final keyboard = mq.viewInsets.bottom;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16, 16, 16,
              16 + bottomSafe + keyboard, // 👈 ALT NEFES: safe area + klavye
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight, // 👈 içerik en az sheet kadar
              ),
              child: DefaultTextStyle(
                style: TextStyle(color: text),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // tutamaç
                    Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: dark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    Text('Hesabı Silmeden Önce',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: text)),
                    const SizedBox(height: 8),
                    _dangerBullet('Bu işlem kalıcıdır ve geri alınamaz.', text),
                    _dangerBullet('Profil ve ayarlar dahil tüm verilerin silinir.', text),
                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Neden silmek istiyorsun? (opsiyonel)',
                        style: TextStyle(fontWeight: FontWeight.w700, color: text),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: reasons.map((r) {
                        final isSel = selected.contains(r);
                        return ChoiceChip(
                          label: Text(r, style: TextStyle(color: isSel ? Colors.red.shade300 : text)),
                          selected: isSel,
                          selectedColor: chipSel,
                          backgroundColor: chipBg,
                          side: BorderSide(color: border),
                          onSelected: (v) => setState(() {
                            if (v) { selected.add(r); } else { selected.remove(r); }
                          }),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 12),
                    TextField(
                      controller: noteCtrl,
                      maxLines: 3,
                      style: TextStyle(color: text),
                      decoration: InputDecoration(
                        labelText: 'Eklemek istediğin bir not var mı?',
                        hintText: 'Kısaca yazabilirsin…',
                        labelStyle: TextStyle(color: text.withOpacity(.8)),
                        hintStyle: TextStyle(color: text.withOpacity(.6)),
                        border: OutlineInputBorder(borderSide: BorderSide(color: border)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: border)),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                        filled: true,
                        fillColor: bg,
                      ),
                    ),
                    const SizedBox(height: 12),

                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: confirm,
                      onChanged: (v) => setState(() => confirm = v ?? false),
                      title: Text(
                        'Eminim. Hesabımı kalıcı olarak silmek istiyorum.',
                        style: TextStyle(fontWeight: FontWeight.w600, color: text),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: dark ? Colors.white : null,
                    ),

                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              side: BorderSide(color: dark ? Colors.white24 : const Color(0xFFFF9E80)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              foregroundColor: dark ? Colors.white70 : const Color(0xFFFB8C00),
                            ),
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.delete_forever),
                            label: const Text('Hesabı Sil'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8), // 👈 altta küçük nefes
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}


  static Widget _dangerBullet(String text, Color color) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.error_outline, size: 18, color: Colors.red),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: color))),
        ],
      );
}
