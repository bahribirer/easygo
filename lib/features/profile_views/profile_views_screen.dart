import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'models/profile_view.dart';
import 'package:easygo/core/service/profile_view_service.dart';
import 'package:easygo/l10n/app_localizations.dart'; // 🔹 eklendi

class ProfileViewsScreen extends StatelessWidget {
  const ProfileViewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final loc = AppLocalizations.of(context)!; // 🔹

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.profileViewsTitle), // 🔹 "Profili Görüntüleyenler"
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ProfileViewService.queryProfileViews(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text(loc.noDataYet)); // 🔹 "Henüz veri yok"
          }

          final docs = snapshot.data!.docs;
          final items = docs
              .map((d) => ProfileView.fromMap(d.id, d.data() as Map<String, dynamic>))
              .toList();

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final item = items[i];
              final isFreeVisible = i < 3; // ilk 3 kişi net, sonrası blur
              return _ProfileViewTile(
                view: item,
                isBlurred: !isFreeVisible,
                onUnlockTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.premiumSoon)), // 🔹
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ProfileViewTile extends StatelessWidget {
  final ProfileView view;
  final bool isBlurred;
  final VoidCallback onUnlockTap;

  const _ProfileViewTile({
    required this.view,
    required this.isBlurred,
    required this.onUnlockTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // 🔹

    final avatar = ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        width: 48,
        height: 48,
        child: view.viewerPhotoUrl == null || view.viewerPhotoUrl!.isEmpty
            ? Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.person, size: 28),
              )
            : Image.network(view.viewerPhotoUrl!, fit: BoxFit.cover),
      ),
    );

    final nameText = Text(
      view.viewerName == "unknown" ? loc.unknownUser : view.viewerName, // 🔹
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final sub = Text(
      _timeAgo(view.lastViewedAt, loc), // 🔹
      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
    );

    if (!isBlurred) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(.15)),
        ),
        child: Row(
          children: [
            avatar,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [nameText, sub],
              ),
            ),
            const Icon(Icons.remove_red_eye_outlined,
                size: 18, color: Colors.deepOrange),
          ],
        ),
      );
    }

    // BLURRED CARD
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(.15)),
              ),
              child: Row(
                children: [
                  // avatar + blur overlay
                  Stack(
                    children: [
                      avatar,
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                            child: Container(color: Colors.transparent),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _blurLine(width: 140, height: 16),
                        const SizedBox(height: 6),
                        _blurLine(width: 90, height: 12),
                      ],
                    ),
                  ),
                  const Icon(Icons.lock_outline, size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
        // CTA overlay
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onUnlockTap,
              child: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 12),
                child: TextButton.icon(
                  onPressed: onUnlockTap,
                  icon: const Icon(Icons.workspace_premium_outlined),
                  label: Text(loc.unlockAll), // 🔹 "Tümünü aç"
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepOrange,
                    backgroundColor: Colors.orange.shade50,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _timeAgo(DateTime? dt, AppLocalizations loc) {
    if (dt == null) return loc.justNow;
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return loc.justNow;
    if (diff.inMinutes < 60) return loc.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return loc.hoursAgo(diff.inHours);
    if (diff.inDays < 7) return loc.daysAgo(diff.inDays);
    return loc.weeksAgo((diff.inDays / 7).floor());
  }
}

Widget _blurLine({required double width, required double height}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(6),
    ),
  );
}
