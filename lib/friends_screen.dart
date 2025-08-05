import 'package:easygo/friend_profile_screen.dart';
import 'package:flutter/material.dart';
import '../service/friendService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<dynamic> friendRequests = [];
  List<dynamic> friends = [];
  String? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    if (userId == null) return;

    try {
      final data = await FriendService.getFriendData(userId!);
      setState(() {
        friendRequests = data['friendRequests'] ?? [];
        friends = data['friends'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      showAlert("Veri alınırken bir hata oluştu");
    }
  }

  void showAlert(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Bilgi", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("Tamam"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> handleAccept(String fromUserId) async {
    await FriendService.acceptRequest(userId!, fromUserId);
    fetchData();
  }

  Future<void> handleReject(String fromUserId) async {
    await FriendService.rejectRequest(userId!, fromUserId);
    fetchData();
  }

  void showSearchDialog() {
    String query = '';
    List<dynamic> results = [];
    bool searching = false;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Kullanıcı Ara", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (value) => query = value,
                  decoration: InputDecoration(
                    hintText: "İsim girin",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text("Ara"),
                  onPressed: () async {
                    if (query.isEmpty) return;
                    setState(() => searching = true);
                    final res = await FriendService.searchUsers(query);
                    setState(() {
                      results = res;
                      searching = false;
                    });
                  },
                ),
                if (searching)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                const SizedBox(height: 12),
                ...results.map((user) {
                  final alreadyFriend = friends.any((f) => f['_id'] == user['_id']);
                  final alreadyRequested = friendRequests.any((f) => f['_id'] == user['_id']);

                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(user['name']),
                    subtitle: Text(user['universityEmail']),
                    trailing: alreadyFriend || alreadyRequested
                        ? const Icon(Icons.check_circle, color: Colors.grey)
                        : IconButton(
                            icon: const Icon(Icons.person_add_alt_1, color: Colors.green),
                            onPressed: () async {
                              await FriendService.sendRequest(userId!, user['_id']);
                              Navigator.pop(context);
                              showAlert("Arkadaşlık isteği gönderildi");
                            },
                          ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSection(String title, List<dynamic> items, bool isRequestSection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Center(
            child: Column(
              children: [
                Icon(
                  isRequestSection ? Icons.group_add_outlined : Icons.people_outline,
                  color: isRequestSection ? Colors.red : Colors.grey,
                  size: 64,
                ),
                const SizedBox(height: 8),
                Text(
                  isRequestSection ? 'Henüz arkadaşlık isteğiniz yok' : 'Henüz arkadaşınız yok',
                  style: TextStyle(
                    color: isRequestSection ? Colors.redAccent : Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(item['name'] ?? 'İsim yok'),
                  subtitle: Text(item['universityEmail'] ?? ''),
                  trailing: isRequestSection
    ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () => handleAccept(item['_id']),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => handleReject(item['_id']),
          ),
        ],
      )
    : const Icon(Icons.chevron_right, color: Colors.red),
onTap: isRequestSection
    ? null
    : () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FriendProfileScreen(user: item),
          ),
        );
      },

                ),
              );
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0E9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Arkadaşlar',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.red),
            onPressed: showSearchDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildSection("Gelen İstekler", friendRequests, true),
                    const Divider(thickness: 1, height: 40, color: Colors.redAccent),
                    buildSection("Arkadaşlar", friends, false),
                  ],
                ),
              ),
            ),
    );
  }
}