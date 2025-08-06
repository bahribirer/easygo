import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easygo/friend_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/friendService.dart';

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

    // 👇 TAM BURAYA BUNU EKLE:
    print("📦 Gelen Arkadaş Verisi:");
    print(jsonEncode(data));  // <<< BURASI!

    setState(() {
      friendRequests = data['friendRequests'] ?? [];
      friends = data['friends'] ?? [];
      isLoading = false;
    });
  } catch (e) {
    print("❌ Veri çekilirken hata: $e");
    setState(() => isLoading = false);
  }
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

  Widget buildRequestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Arkadaşlık İstekleri",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: friendRequests.length,
            itemBuilder: (context, index) {
              final req = friendRequests[index];
final location = req['location'] ?? '';
final name = req['name'] ?? '';

              return Container(
                margin: const EdgeInsets.only(right: 12),
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.pink.shade50,
                  image: req['profilePhoto'] != null && req['profilePhoto'] != ''
                      ? DecorationImage(
                          image: MemoryImage(base64Decode(req['profilePhoto'])),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                        )
                      : null,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => handleAccept(req['_id']),
                            child: const CircleAvatar(radius: 14, backgroundColor: Colors.green, child: Icon(Icons.check, size: 16, color: Colors.white)),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => handleReject(req['_id']),
                            child: const CircleAvatar(radius: 14, backgroundColor: Colors.red, child: Icon(Icons.close, size: 16, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 8,
                      right: 8,
                      child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      name,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      overflow: TextOverflow.ellipsis,
    ),
    const SizedBox(height: 2),
    Row(
      children: [
        const Icon(Icons.location_on, size: 12, color: Colors.white70),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            location,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  ],
)

                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildFriendGrid() {
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.75,
    ),
    itemCount: friends.length,
    itemBuilder: (context, index) {
      final friend = friends[index];
      final photo = friend['profilePhoto'];
      final name = friend['name'] ?? '';
      final location = friend['location'] ?? '';

      return GestureDetector(
        onTap: () async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => FriendProfileScreen(user: friend),
    ),
  );

  if (result == true) {
    // 🌀 Arkadaş silindiyse, veriyi yeniden çek
    fetchData();
  }
},

        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFFFBE6E0), Color(0xFFFFD6CB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(2, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundImage: (photo != null && photo != '')
                    ? MemoryImage(base64Decode(photo))
                    : const AssetImage('assets/profile.jpg') as ImageProvider,
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      location,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
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
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildRequestSection(),
                    const SizedBox(height: 20),
                    const Text(
                      "Arkadaşlar",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    buildFriendGrid(),
                  ],
                ),
              ),
            ),
    );
  }
}
