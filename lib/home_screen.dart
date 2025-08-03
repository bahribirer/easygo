import 'package:easygo/inbox_screen.dart';
import 'package:easygo/messages_screen.dart';
import 'package:easygo/profile_screen.dart';
import 'package:flutter/material.dart';
import 'friends_screen.dart';
import 'package:easygo/active_chats_screen.dart';
import 'package:easygo/archived_chats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FriendsScreen()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MessagesScreen()),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      body: SafeArea(
        child: Column(
          children: [
            // Üst Logo ve Bildirim Alanı
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/easygo_logo.png', height: 48),
                  GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InboxScreen()),
    );
  },
  child: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Sekmeler
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ActionChip(
                    label: const Text("Aktif Sohbetler"),
                    labelStyle: const TextStyle(color: Colors.white),
                    backgroundColor: Colors.redAccent,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveChatsScreen()));
                    },
                  ),
                  ActionChip(
                    label: const Text("Arşivlenmiş"),
                    labelStyle: const TextStyle(color: Colors.white),
                    backgroundColor: Colors.deepOrange,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ArchivedChatsScreen()));
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Avatar Havuzu
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Colors.orangeAccent, Colors.white],
                        ),
                        boxShadow: [BoxShadow(color: Colors.deepOrange.shade100, blurRadius: 20)],
                      ),
                    ),
                    const CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/user_center.jpg'),
                    ),
                    const Positioned(
                      top: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/user1.jpg'),
                      ),
                    ),
                    const Positioned(
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/user2.jpg'),
                      ),
                    ),
                    const Positioned(
                      left: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/user3.jpg'),
                      ),
                    ),
                    const Positioned(
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/user4.jpg'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Bilgilendirici Metin
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: const [
                  Text(
                    "Ana Sayfadan Yeni Bir Buluşma Oluştur!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Hemen Havuza Düş, Harika Zaman Geçirebileceğin İnsanlarla Tanış",
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // Alt Navigasyon Barı
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 10,
        shape: const CircularNotchedRectangle(),
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
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: selectedIndex == index
                            ? Colors.orange.shade50
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icons[index],
                        color: selectedIndex == index ? Colors.deepOrange : Colors.grey,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 3,
                      width: selectedIndex == index ? 20 : 0,
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(2),
                      ),
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
