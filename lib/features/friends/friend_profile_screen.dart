import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

// servisler
import 'package:easygo/core/service/user_profile_service.dart';
import 'package:easygo/core/service/friendService.dart';
import 'package:easygo/core/service/profile_view_service.dart';

import 'package:easygo/features/friends/widgets/section_card.dart';
import 'package:easygo/l10n/app_localizations.dart';

class FriendProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user; // { _id, name, ... }

  const FriendProfileScreen({super.key, required this.user});

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;
  String? currentUserId;
  bool _viewRecorded = false; // aynı ekranda tekrar tekrar kaydetme engeli

  @override
  void initState() {
    super.initState();
    _fetchFriendProfile();
    _recordProfileView(); // 🔴 profil açılınca kaydı at
  }

  Future<void> _recordProfileView() async {
    if (_viewRecorded) return;
    final current = FirebaseAuth.instance.currentUser;
    if (current == null) return;

    try {
      await ProfileViewService.recordProfileView(
        viewedUserId: widget.user['_id'], // profili açılan kişi
        viewerUid: current.uid, // ben kimim
        viewerName: current.displayName ?? 'User',
        viewerPhotoUrl: current.photoURL,
      );
      _viewRecorded = true;
    } catch (e) {
      debugPrint("ProfileView kaydedilemedi: $e");
    }
  }

  Future<void> _fetchFriendProfile() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      currentUserId = prefs.getString('userId');

      final result = await UserProfileService.getProfile(widget.user['_id']);
      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          profileData = result['profile'] as Map<String, dynamic>?;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _toast(AppLocalizations.of(context)!.profileLoadFailed);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _toast(AppLocalizations.of(context)!.genericError);
    }
  }

  int _calculateAge(String? birthDateStr) {
    if (birthDateStr == null || birthDateStr.isEmpty) return 0;
    DateTime birthDate;
    try {
      birthDate = DateTime.parse(birthDateStr);
    } catch (_) {
      return 0;
    }
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _confirmUnfriend() async {
    final loc = AppLocalizations.of(context)!;
    if (currentUserId == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(loc.unfriendConfirmTitle),
        content: Text(
          loc.unfriendConfirmMessage(profileData?['name'] ?? loc.userDefault),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(loc.unfriendConfirmYes),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await FriendService.unfriend(currentUserId!, widget.user['_id']);
      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(loc.unfriendSuccessTitle,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(loc.unfriendSuccessMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.ok, style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      Navigator.pop(context, true); // listeye dön ve refresh tetikle
    } catch (_) {
      _toast(loc.genericError);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final bg = const Color(0xFFFFF0E9);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (profileData == null)
              ? Center(child: Text(loc.profileLoadFailed))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Avatar
                            Hero(
                              tag: "friend_${widget.user['_id']}",
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage: (profileData!['profilePhoto'] != null &&
                                        profileData!['profilePhoto'].toString().isNotEmpty)
                                    ? MemoryImage(
                                        base64Decode(profileData!['profilePhoto']))
                                    : const AssetImage('assets/profile.jpg')
                                        as ImageProvider,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "${profileData!['name'] ?? loc.userDefault}, ${_calculateAge(profileData!['birthDate'])}",
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profileData!['universityEmail'] ?? '',
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on,
                                    size: 16, color: Colors.red),
                                const SizedBox(width: 4),
                                Text(
                                  "${profileData!['location'] ?? loc.unknown}, TÜRKİYE",
                                  style: const TextStyle(
                                      color: Colors.black54, fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Arkadaş sayısı
                            SectionCard(
                              title: loc.friendsSection,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  loc.friendCountLabel(
                                      (profileData!['friends'] as List?)?.length ?? 0),
                                  style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // İlgi alanları
                            SectionCard(
                              title: loc.interestsSection,
                              child: (profileData!['interests'] != null &&
                                      (profileData!['interests'] as List).isNotEmpty)
                                  ? Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: (profileData!['interests'] as List)
                                          .map((it) => Chip(
                                                label: Text('$it'),
                                                backgroundColor:
                                                    Colors.red.shade50,
                                                labelStyle: const TextStyle(
                                                    color: Colors.red),
                                              ))
                                          .toList()
                                          .cast<Widget>(),
                                    )
                                  : Text(loc.noInterests,
                                      style: const TextStyle(color: Colors.black54)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // alt aksiyon bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.delete_forever),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _confirmUnfriend,
                              label: Text(loc.unfriendButton),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.message),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                // TODO: Mesajlaşma akışı bağlanacak
                              },
                              label: Text(
                                loc.sendMessage,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
