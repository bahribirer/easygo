import 'dart:ui';
import 'package:easygo/inbox_screen.dart';
import 'package:easygo/messages_screen.dart';
import 'package:easygo/profile_screen.dart';
import 'package:flutter/material.dart';
import 'friends_screen.dart';
import 'package:easygo/active_chats_screen.dart';
import 'package:easygo/archived_chats_screen.dart';
import 'package:easygo/helpers/city_helper.dart';
import 'package:easygo/service/event_service.dart'; // ✅ backend service

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  // ✅ Backend verileri
  final List<_PendingEvent> _pendingList = [];
  int _todayCount = 0;
  bool _loadingPending = false;

  @override
  void initState() {
    super.initState();
    _refreshTodayCount();
    _refreshPending();
  }

  void onTabTapped(int index) {
    setState(() => selectedIndex = index);
    if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FriendsScreen()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesScreen()));
    } else if (index == 4) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
    }
  }

  // =========================
  // Backend fetch helpers
  // =========================
  Future<void> _refreshTodayCount() async {
    try {
      final res = await EventService.getMyTodayCount();
      if (!mounted) return;
      if (res['success'] == true) {
        setState(() => _todayCount = (res['count'] ?? 0) as int);
      }
    } catch (_) {}
  }

  Future<void> _refreshPending() async {
    setState(() => _loadingPending = true);
    try {
      final res = await EventService.getMyPendingEvents();
      if (!mounted) return;
      if (res['success'] == true) {
        final list = (res['events'] as List? ?? [])
            .map((e) => _PendingEvent.fromJson(Map<String, dynamic>.from(e)))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        setState(() {
          _pendingList
            ..clear()
            ..addAll(list);
        });
      }
    } catch (_) {
      // isteğe bağlı: hata popup
    } finally {
      if (mounted) setState(() => _loadingPending = false);
    }
  }

  Future<void> _cancelEvent(String id) async {
    try {
      final res = await EventService.cancelEvent(id);
      if (!mounted) return;
      if (res['success'] == true) {
        await Future.wait([_refreshPending(), _refreshTodayCount()]);
        await showSuccess(context, 'Etkinlik iptal edildi.');
      } else {
        await showError(context, 'İptal edilemedi', res['message']?.toString());
      }
    } catch (e) {
      if (!mounted) return;
      await showError(context, 'Hata', e.toString());
    }
  }

  // =========================
  // Etkinlik Oluştur Sheet
  // =========================
  Future<void> _openCreateEventSheet() async {
    final mq = MediaQuery.of(context);
    final types = <String>['Kahve', 'Yemek', 'Sohbet', 'Ders Çalışma', 'Spor', 'Sinema'];
    final rootContext = context; // sheet dışındaki güvenli context

    String? type;
    DateTime? dateTime;
    String? city;
    bool sending = false;

    if (_todayCount >= 3) {
      _limitSnack();
      return;
    }

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: StatefulBuilder(
            builder: (context, setModal) {
              Future<void> pickDateTime() async {
                final now = DateTime.now();
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: now.add(const Duration(days: 1)),
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 365)),
                  helpText: 'Tarih Seç',
                  cancelText: 'İptal',
                  confirmText: 'Tamam',
                );
                if (pickedDate == null) return;
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  helpText: 'Saat Seç',
                  cancelText: 'İptal',
                  confirmText: 'Tamam',
                );
                if (pickedTime == null) return;
                setModal(() {
                  dateTime = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                });
              }

              final canSend = type != null && dateTime != null && city != null && !sending;

              Future<void> submit() async {
                if (!canSend) return;

                await _refreshTodayCount();
                if (_todayCount >= 3) {
                  _limitSnack();
                  return;
                }

                setModal(() => sending = true);
                try {
                  final res = await EventService.createEvent(
                    type: type!,
                    city: city!,
                    dateTime: dateTime!,
                  );

                  if (!context.mounted) return;

                  if (res['success'] == true) {
                    Future.microtask(() {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop(true); // result: true
                      }
                    });
                    return;
                  } else {
                    setModal(() => sending = false);
                    await showError(context, 'Gönderilemedi', res['message']?.toString());
                  }
                } catch (e) {
                  setModal(() => sending = false);
                  if (!context.mounted) return;
                  await showError(context, 'Hata', e.toString());
                }
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 24,
                      offset: const Offset(0, -6),
                    )
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      10,
                      16,
                      16 + mq.viewInsets.bottom + mq.padding.bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 44,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        Row(
                          children: const [
                            Icon(Icons.event_outlined, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Etkinlik Oluştur',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Tip
                        Text('Etkinlik Tipi',
                            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey[800])),
                        const SizedBox(height: 8),
                        _SheetField(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: type,
                              isExpanded: true,
                              hint: const Text('Seçiniz'),
                              items: types
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => setModal(() => type = v),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Tarih / Saat
                        Text('Tarih & Saat',
                            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey[800])),
                        const SizedBox(height: 8),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: pickDateTime,
                          child: _SheetField(
                            height: 52,
                            child: Row(
                              children: [
                                const Icon(Icons.schedule, color: Colors.black54),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    dateTime == null
                                        ? 'Tarih & saat seçin'
                                        : '${_pad(dateTime!.day)}.${_pad(dateTime!.month)}.${dateTime!.year}  •  ${_pad(dateTime!.hour)}:${_pad(dateTime!.minute)}',
                                    style: TextStyle(
                                      color: dateTime == null ? Colors.black54 : Colors.black87,
                                      fontWeight:
                                          dateTime == null ? FontWeight.w400 : FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.edit_calendar_outlined, color: Colors.black38),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Şehir
                        Text('Şehir',
                            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey[800])),
                        const SizedBox(height: 8),
                        _SheetField(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: city,
                              isExpanded: true,
                              hint: const Text('İl seçiniz'),
                              items: turkishCities
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => setModal(() => city = v),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: canSend ? submit : null,
                            icon: sending
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.send_rounded),
                            label: Text(sending ? 'Gönderiliyor…' : 'Havuza Gönder'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    // ⬇️ Sheet kapandıktan sonra güvenle UI güncelle
    if (!mounted) return;
    if (result == true) {
      await showSuccess(rootContext, 'Etkinlik havuza gönderildi.');
      await _refreshPending();
      await _refreshTodayCount();
    }
  }

  void _limitSnack() {
    showWarning(context, 'Günlük limit doldu',
        'Bugün en fazla 3 buluşma oluşturabilirsin.');
  }

  String _pad(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;

    final hasPending = _pendingList.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      body: SafeArea(
        child: Column(
          children: [
            // Üst Header
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6F61), Color(0xFFFF9472)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Image.asset('assets/easygo_logo.png', height: 44),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const InboxScreen())),
                    borderRadius: BorderRadius.circular(999),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(Icons.notifications_none, color: Colors.white, size: 28),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Sekmeler + Etkinlik
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              child: Row(
                children: [
                  // Düzeltilmiş (Expanded kaldırıldı)
                  _QuickPill(
                    label: 'Aktif Sohbetler',
                    icon: Icons.bolt_rounded,
                    color: const Color(0xFFEA5455),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ActiveChatsScreen()),
                    ),
                  ),

                  const SizedBox(width: 10),
                  // Düzeltilmiş (Expanded kaldırıldı) — doğru sayfaya yönlendirildi
                  _QuickPill(
                    label: 'Arşivlenmiş Sohbetler',
                    icon: Icons.archive_outlined,
                    color: const Color(0xFF6C757D),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ArchivedChatsScreen()),
                    ),
                  ),

                  const SizedBox(width: 10),
                  _EventButton(onTap: _openCreateEventSheet),
                ],
              ),
            ),

            // İçerik
            Expanded(
              child: _loadingPending
                  ? const Center(child: CircularProgressIndicator())
                  : hasPending
                      ? RefreshIndicator(
                          onRefresh: () async {
                            await Future.wait([_refreshPending(), _refreshTodayCount()]);
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: _pendingList.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final p = _pendingList[i];
                              return _PendingEventCard(
                                pending: p,
                                onCancel: () {
                                  // onay penceresi
                                  showConfirm(
                                    context,
                                    title: 'Etkinliği iptal etmek istiyor musun?',
                                    message: 'Bu işlem geri alınamaz.',
                                    ok: 'Evet, iptal et',
                                    cancel: 'Vazgeç',
                                  ).then((ok) {
                                    if (ok) _cancelEvent(p.id);
                                  });
                                },
                              );
                            },
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: w * .66,
                                      height: w * .66,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const RadialGradient(
                                            colors: [Colors.orangeAccent, Colors.white]),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.deepOrangeAccent.withOpacity(.18),
                                              blurRadius: 26)
                                        ],
                                      ),
                                    ),
                                    const CircleAvatar(
                                        radius: 42,
                                        backgroundImage:
                                            AssetImage('assets/user_center.jpg')),
                                    const Positioned(
                                        top: 0,
                                        child: CircleAvatar(
                                            radius: 20,
                                            backgroundImage:
                                                AssetImage('assets/user1.jpg'))),
                                    const Positioned(
                                        bottom: 0,
                                        child: CircleAvatar(
                                            radius: 20,
                                            backgroundImage:
                                                AssetImage('assets/user2.jpg'))),
                                    const Positioned(
                                        left: 0,
                                        child: CircleAvatar(
                                            radius: 20,
                                            backgroundImage:
                                                AssetImage('assets/user3.jpg'))),
                                    const Positioned(
                                        right: 0,
                                        child: CircleAvatar(
                                            radius: 20,
                                            backgroundImage:
                                                AssetImage('assets/user4.jpg'))),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 22.0),
                              child: Column(
                                children: [
                                  Text(
                                    'Ana Sayfadan Yeni Bir Buluşma Oluştur!',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.deepOrange),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Hemen havuza düş; birlikte güzel vakit geçirebileceğin insanlarla tanış.',
                                    style: TextStyle(fontSize: 15, color: Colors.black87),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
            ),
          ],
        ),
      ),

      // Alt Navigasyon
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 12,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (index) {
              final icons = [
                Icons.home,
                Icons.remove_red_eye_outlined,
                Icons.people_outline,
                Icons.chat_bubble_outline,
                Icons.person_outline,
              ];
              return GestureDetector(
                onTap: () => onTabTapped(index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: selectedIndex == index
                            ? Colors.orange.shade50
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icons[index],
                        color:
                            selectedIndex == index ? Colors.deepOrange : Colors.grey,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 3),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 3,
                      width: selectedIndex == index ? 20 : 0,
                      decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(2)),
                    )
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ==== küçük UI parçaları ====

class _QuickPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickPill(
      {required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: color,
        elevation: 0,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EventButton extends StatelessWidget {
  final VoidCallback onTap;
  const _EventButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1E88E5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          child: Row(
            children: [
              Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Etkinlik',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final Widget child;
  final double? height;
  const _SheetField({required this.child, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}

// —— Pending (beklemede) veri modeli ——
class _PendingEvent {
  final String id;
  final String type;
  final String city;
  final DateTime dateTime;
  final DateTime createdAt;

  _PendingEvent({
    required this.id,
    required this.type,
    required this.city,
    required this.dateTime,
    required this.createdAt,
  });

  factory _PendingEvent.fromJson(Map<String, dynamic> j) => _PendingEvent(
        id: j['_id'] as String,
        type: j['type'] as String,
        city: j['city'] as String,
        dateTime: DateTime.parse(j['dateTime'] as String),
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}

class _PendingEventCard extends StatelessWidget {
  final _PendingEvent pending;
  final VoidCallback onCancel;
  const _PendingEventCard({required this.pending, required this.onCancel});

  String _pad(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final dt = pending.dateTime;
    final dateStr =
        '${_pad(dt.day)}.${_pad(dt.month)}.${dt.year}  •  ${_pad(dt.hour)}:${_pad(dt.minute)}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFE3F2FD),
            child:
                Icon(Icons.hourglass_top_rounded, color: Color(0xFF1E88E5)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Beklemede',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text('${pending.type} • ${pending.city}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(dateStr,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54)),
                ]),
          ),
          TextButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.close_rounded, size: 18),
            label: const Text('İptal'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          )
        ],
      ),
    );
  }
}

/* ===============================
   Popup Yardımcıları (Genel Kullanım)
   =============================== */

enum AppPopupType { success, warning, error, info }

Future<bool> showAppPopup(
  BuildContext context, {
  required AppPopupType type,
  required String title,
  String? message,
  String primaryText = 'Tamam',
  String? secondaryText,
}) async {
  IconData icon;
  Color color;
  switch (type) {
    case AppPopupType.success:
      icon = Icons.check_circle_rounded; color = const Color(0xFF2E7D32); break;
    case AppPopupType.warning:
      icon = Icons.warning_amber_rounded; color = const Color(0xFFF9A825); break;
    case AppPopupType.error:
      icon = Icons.error_rounded; color = const Color(0xFFC62828); break;
    case AppPopupType.info:
      icon = Icons.info_rounded; color = const Color(0xFF1565C0); break;
  }

  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'popup',
    barrierColor: Colors.black.withOpacity(0.35),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (ctx, anim1, anim2) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (ctx, anim, _, __) {
      return Transform.scale(
        scale: 0.95 + (0.05 * anim.value),
        child: Opacity(
          opacity: anim.value,
          child: Stack(
            children: [
              // arka plan blur
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(color: Colors.transparent),
              ),
              Center(
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: color.withOpacity(.10),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, size: 34, color: color),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                          if (message != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              message!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14, color: Colors.black87),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              if (secondaryText != null)
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text(secondaryText!,
                                        style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              if (secondaryText != null) const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: color,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: Text(primaryText,
                                      style: const TextStyle(fontWeight: FontWeight.w800)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  return result ?? false; // primary: true, secondary/tap-out: false
}

/// Kısa kısayollar:
Future<void> showSuccess(BuildContext c, String t, [String? m]) =>
  showAppPopup(c, type: AppPopupType.success, title: t, message: m).then((_) {});
Future<void> showError(BuildContext c, String t, [String? m]) =>
  showAppPopup(c, type: AppPopupType.error, title: t, message: m).then((_) {});
Future<void> showWarning(BuildContext c, String t, [String? m]) =>
  showAppPopup(c, type: AppPopupType.warning, title: t, message: m).then((_) {});
Future<bool> showConfirm(BuildContext c, {required String title, String? message,
  String ok = 'Onayla', String cancel = 'Vazgeç'}) =>
  showAppPopup(c,
    type: AppPopupType.info, title: title, message: message,
    primaryText: ok, secondaryText: cancel);
