import 'package:easygo/messages_screen.dart';
import 'package:easygo/profile_screen.dart';
import 'package:flutter/material.dart';
import 'friends_screen.dart'; // Bu dosyayı oluşturduğundan emin ol 
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
  }
  if (index == 4) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Logo ve bildirim
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/easygo_logo.png', height: 50),
                  const Icon(Icons.notifications_none, color: Colors.black, size: 28),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Sekmeler
            Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ActiveChatsScreen()),
        );
      },
      child: const Text(
        'Aktif Sohbetler',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ArchivedChatsScreen()),
        );
      },
      child: const Text(
        'Arşivlenmiş Sohbetler',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
),

            const SizedBox(height: 20),
            // Havuz avatarları
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
                        color: Colors.orange.shade50,
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
            // Mesaj
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text.rich(
                TextSpan(
                  text: "Ana Sayfadan Yeni\n",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                  children: [
                    TextSpan(
                      text: "Bir Buluşma Oluştur!",
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "Hemen Havuza Düş, Harika Zaman Geçirebileceğin İnsanlarla Tanış",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onTabTapped,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.remove_red_eye_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: ''), // İki kafa
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }
}
