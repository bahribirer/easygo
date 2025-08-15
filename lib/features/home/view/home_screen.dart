import 'package:easygo/core/inbox_badge.dart';
import 'package:easygo/core/service/notification_service.dart';
import 'package:easygo/core/service/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:easygo/features/inbox/inbox_screen.dart';
import 'package:easygo/features/messages/messages_screen.dart';
import 'package:easygo/features/profile/view/profile_screen.dart';
import 'package:easygo/features/friends/friends_screen.dart';
import 'package:easygo/features/chat/active_chats_screen.dart';
import 'package:easygo/features/chat/archived_chats_screen.dart';
import 'package:easygo/helpers/city_helper.dart';
import 'package:easygo/core/service/event_service.dart';

import 'package:easygo/shared/popups/app_popups.dart';
import 'package:easygo/features/home/models/pending_event.dart';
import 'package:easygo/features/home/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final List<PendingEvent> _pendingList = [];
  int _todayCount = 0;
  bool _loadingPending = false;

  @override
void initState() {
  super.initState();
  _refreshTodayCount();
  _refreshPending();

  // 🛎️ Bildirim sayısını çek ve socket dinle
  NotificationService.getUnreadCount().then((count) {
    InboxBadge.notifier.value = count;
  });
  SocketService.connect().then((socket) {
    socket.on('notification', (_) {
      InboxBadge.notifier.value = InboxBadge.notifier.value + 1;
    });
  });
}



  

  void _onTabTapped(int index) {
    setState(() => selectedIndex = index);
    if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FriendsScreen()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesScreen()));
    } else if (index == 4) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
    }
  }

  // ===== backend helpers
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
            .map((e) => PendingEvent.fromJson(Map<String, dynamic>.from(e)))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        setState(() {
          _pendingList
            ..clear()
            ..addAll(list);
        });
      }
    } catch (_) {
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

  // ===== etkinlik sheet
  Future<void> _openCreateEventSheet() async {
    final mq = MediaQuery.of(context);
    final types = <String>['Kahve', 'Yemek', 'Sohbet', 'Ders Çalışma', 'Spor', 'Sinema'];
    final rootContext = context;

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
                    pickedDate.year, pickedDate.month, pickedDate.day,
                    pickedTime.hour, pickedTime.minute,
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
                        Navigator.of(context).pop(true);
                      }
                    });
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
                      16, 10, 16,
                      16 + mq.viewInsets.bottom + mq.padding.bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 44, height: 5,
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

                        Text('Etkinlik Tipi',
                            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey[800])),
                        const SizedBox(height: 8),
                        SheetField(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: type,
                              isExpanded: true,
                              hint: const Text('Seçiniz'),
                              items: types.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (v) => setModal(() => type = v),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        Text('Tarih & Saat',
                            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey[800])),
                        const SizedBox(height: 8),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: pickDateTime,
                          child: SheetField(
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
                                      fontWeight: dateTime == null ? FontWeight.w400 : FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.edit_calendar_outlined, color: Colors.black38),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        Text('Şehir',
                            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey[800])),
                        const SizedBox(height: 8),
                        SheetField(
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
                            onPressed: (type != null && dateTime != null && city != null && !sending)
                                ? submit
                                : null,
                            icon: sending
                                ? const SizedBox(
                                    width: 18, height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.send_rounded),
                            label: Text(sending ? 'Gönderiliyor…' : 'Havuza Gönder'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

    if (!mounted) return;
    if (result == true) {
      await showSuccess(rootContext, 'Etkinlik havuza gönderildi.');
      await _refreshPending();
      await _refreshTodayCount();
    }
  }

  void _limitSnack() {
    showWarning(context, 'Günlük limit doldu', 'Bugün en fazla 3 buluşma oluşturabilirsin.');
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
            // header
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
  onTap: () async {
    await Navigator.push(
      context, MaterialPageRoute(builder: (_) => const InboxScreen()),
    );
    // Inbox’tan dönünce badge’i sıfırla
    InboxBadge.notifier.value = 0;
  },
  borderRadius: BorderRadius.circular(999),
  child: Padding(
    padding: const EdgeInsets.all(6.0),
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_none, color: Colors.white, size: 28),
        Positioned(
          right: -2,
          top: -2,
          child: ValueListenableBuilder<int>(
            valueListenable: InboxBadge.notifier,
            builder: (_, count, __) {
              if (count <= 0) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
),

                ],
              ),
            ),

            const SizedBox(height: 10),

            // quick actions
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              child: Row(
                children: [
                  QuickPill(
                    label: 'Aktif Sohbetler',
                    icon: Icons.bolt_rounded,
                    color: const Color(0xFFEA5455),
                    onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const ActiveChatsScreen()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  QuickPill(
                    label: 'Arşivlenmiş Sohbetler',
                    icon: Icons.archive_outlined,
                    color: const Color(0xFF6C757D),
                    onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const ArchivedChatsScreen()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  EventButton(onTap: _openCreateEventSheet),
                ],
              ),
            ),

            // content
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
                              return PendingEventCard(
                                pending: p,
                                onCancel: () async {
                                  final ok = await showConfirm(
                                    context,
                                    title: 'Etkinliği iptal etmek istiyor musun?',
                                    message: 'Bu işlem geri alınamaz.',
                                    ok: 'Evet, iptal et',
                                    cancel: 'Vazgeç',
                                  );
                                  if (ok) _cancelEvent(p.id);
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
                                      backgroundImage: AssetImage('assets/user_center.jpg')),
                                    const Positioned(
                                      top: 0,
                                      child: CircleAvatar(radius: 20, backgroundImage: AssetImage('assets/user1.jpg'))),
                                    const Positioned(
                                      bottom: 0,
                                      child: CircleAvatar(radius: 20, backgroundImage: AssetImage('assets/user2.jpg'))),
                                    const Positioned(
                                      left: 0,
                                      child: CircleAvatar(radius: 20, backgroundImage: AssetImage('assets/user3.jpg'))),
                                    const Positioned(
                                      right: 0,
                                      child: CircleAvatar(radius: 20, backgroundImage: AssetImage('assets/user4.jpg'))),
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
                                      fontSize: 22, fontWeight: FontWeight.w900, color: Colors.deepOrange),
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

      // bottom nav
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
                onTap: () => _onTabTapped(index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: selectedIndex == index ? Colors.orange.shade50 : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icons[index],
                        color: selectedIndex == index ? Colors.deepOrange : Colors.grey,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 3),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 3,
                      width: selectedIndex == index ? 20 : 0,
                      decoration: BoxDecoration(
                        color: Colors.deepOrange, borderRadius: BorderRadius.circular(2)),
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
