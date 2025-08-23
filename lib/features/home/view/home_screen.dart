import 'package:easygo/core/inbox_badge.dart';
import 'package:easygo/features/profile_views/profile_views_screen.dart';
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
import 'package:easygo/l10n/app_localizations.dart';

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
  }

  void _onTabTapped(int index) {
    setState(() => selectedIndex = index);
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileViewsScreen()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FriendsScreen()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesScreen()));
    } else if (index == 4) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
    }
  }

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
    final loc = AppLocalizations.of(context)!;
    try {
      final res = await EventService.cancelEvent(id);
      if (!mounted) return;
      if (res['success'] == true) {
        await Future.wait([_refreshPending(), _refreshTodayCount()]);
        await showSuccess(context, loc.eventCancelled);
      } else {
        await showError(context, loc.cancelFailed, res['message']?.toString());
      }
    } catch (e) {
      if (!mounted) return;
      await showError(context, loc.error, e.toString());
    }
  }

  Future<void> _openCreateEventSheet() async {
    final mq = MediaQuery.of(context);
    final loc = AppLocalizations.of(context)!;

    final types = <String>[
      loc.eventTypeCoffee,
      loc.eventTypeMeal,
      loc.eventTypeChat,
      loc.eventTypeStudy,
      loc.eventTypeSport,
      loc.eventTypeCinema,
    ];

    final rootContext = context;

    String? type;
    DateTime? dateTime;
    String? city;
    int? selectedSlot;
    bool sending = false;

    final timeSlots = {
      0: ['09:00', '12:00'],
      1: ['15:00', '18:00'],
      2: ['21:00', '00:00'],
    };

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
              Future<void> pickDate() async {
                final now = DateTime.now();
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: now.add(const Duration(days: 1)),
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 90)),
                  selectableDayPredicate: (day) {
                    return day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
                  },
                  helpText: loc.selectDate,
                  cancelText: loc.cancel,
                  confirmText: loc.ok,
                );
                if (pickedDate == null) return;
                setModal(() {
                  dateTime = pickedDate;
                });
              }

              final canSend =
                  type != null && dateTime != null && selectedSlot != null && city != null && !sending;

              Future<void> submit() async {
                if (!canSend) return;

                await _refreshTodayCount();
                if (_todayCount >= 3) {
                  _limitSnack();
                  return;
                }

                setModal(() => sending = true);
                try {
                  final slot = timeSlots[selectedSlot]!;
                  final res = await EventService.createEvent(
                    type: type!,
                    city: city!,
                    dateTime: DateTime(
                      dateTime!.year,
                      dateTime!.month,
                      dateTime!.day,
                      int.parse(slot[0].split(':')[0]),
                    ),
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
                    await showError(context, loc.sendFailed, res['message']?.toString());
                  }
                } catch (e) {
                  setModal(() => sending = false);
                  if (!context.mounted) return;
                  await showError(context, loc.error, e.toString());
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
                      20, 10, 20,
                      20 + mq.viewInsets.bottom + mq.padding.bottom,
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
                          children: [
                            const Icon(Icons.event_outlined, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(loc.createEvent,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Text(loc.eventType,
                            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey[800])),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: type,
                              isExpanded: true,
                              hint: Text(loc.select),
                              items: types.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (v) => setModal(() => type = v),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(loc.dateWeekendOnly,
                            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey[800])),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: pickDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.black54),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    dateTime == null
                                        ? loc.selectDateShort
                                        : '${dateTime!.day}.${dateTime!.month}.${dateTime!.year}',
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
                        const SizedBox(height: 16),

                        Text(loc.timeSlot,
                            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey[800])),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          children: timeSlots.entries.map((entry) {
                            final idx = entry.key;
                            final label = "${entry.value[0]} - ${entry.value[1]}";
                            final selected = selectedSlot == idx;
                            return ChoiceChip(
                              label: Text(label),
                              selected: selected,
                              onSelected: (_) => setModal(() => selectedSlot = idx),
                              selectedColor: Colors.red.shade100,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        Text(loc.city,
                            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey[800])),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: city,
                              isExpanded: true,
                              hint: Text(loc.selectCity),
                              items: turkishCities
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => setModal(() => city = v),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: canSend ? submit : null,
                            icon: sending
                                ? const SizedBox(
                                    width: 18, height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.send_rounded),
                            label: Text(sending ? loc.sending : loc.sendToPool),
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
      await showSuccess(rootContext, loc.eventSent);
      await _refreshPending();
      await _refreshTodayCount();
    }
  }

  void _limitSnack() {
    final loc = AppLocalizations.of(context)!;
    showWarning(context, loc.limitReachedTitle, loc.limitReachedMessage);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final loc = AppLocalizations.of(context)!;
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
                    label: loc.activeChats,
                    icon: Icons.bolt_rounded,
                    color: const Color(0xFFEA5455),
                    onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const ActiveChatsScreen()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  QuickPill(
                    label: loc.archivedChats,
                    icon: Icons.archive_outlined,
                    color: const Color(0xFF6C757D),
                    onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const ArchivedChatsScreen()),
                    ),
                  ),
                  const SizedBox(width: 10),
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
                                    title: loc.confirmCancelTitle,
                                    message: loc.confirmCancelMessage,
                                    ok: loc.confirmCancelOk,
                                    cancel: loc.cancel,
                                  );
                                  if (ok) _cancelEvent(p.id);
                                },
                              );
                            },
                          ),
                        )
                      : _EmptyEventsState(
                          onCreateTap: _openCreateEventSheet,
                          todayCount: _todayCount,
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

class _EmptyEventsState extends StatelessWidget {
  final VoidCallback onCreateTap;
  final int todayCount;

  const _EmptyEventsState({
    required this.onCreateTap,
    required this.todayCount,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      _Blob(size: 240, colors: [
                        Colors.orange.withOpacity(0.18),
                        Colors.deepOrange.withOpacity(0.10),
                      ]),
                      Container(
                        height: 88,
                        width: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6F61), Color(0xFFFF9472)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepOrange.withOpacity(0.25),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.event_available_rounded, color: Colors.white, size: 42),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    loc.noEventsTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF2B2B2B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.noEventsMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: todayCount >= 3 ? null : onCreateTap,
                      icon: const Icon(Icons.add_rounded),
                      label: Text(todayCount >= 3 ? loc.limitReachedTitle : loc.createEvent),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (todayCount >= 3)
                    Text(
                      loc.limitReachedMessage,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.redAccent),
                    ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final List<Color> colors;
  const _Blob({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BlobPainter(colors),
      size: Size.square(size),
    );
  }
}

class _BlobPainter extends CustomPainter {
  final List<Color> colors;
  _BlobPainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: colors,
        center: Alignment.center,
        radius: 0.85,
      ).createShader(rect);

    final path = Path()
      ..moveTo(size.width * .50, 0)
      ..cubicTo(size.width * .85, size.height * .05, size.width * .95, size.height * .35, size.width * .90, size.height * .55)
      ..cubicTo(size.width * .85, size.height * .80, size.width * .55, size.height * .95, size.width * .40, size.height * .90)
      ..cubicTo(size.width * .15, size.height * .80, size.width * .05, size.height * .45, size.width * .18, size.height * .30)
      ..cubicTo(size.width * .28, size.height * .12, size.width * .45, size.height * .02, size.width * .50, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) {
    return oldDelegate.colors != colors;
  }
}
