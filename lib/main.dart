import 'dart:io';
import 'package:easygo/core/inbox_badge.dart';
import 'package:easygo/features/friends/friends_screen.dart';
import 'package:easygo/features/inbox/inbox_screen.dart';
import 'package:easygo/features/messages/messages_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

// Firebase paketleri
import 'package:firebase_core/firebase_core.dart';
import 'core/firebase/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔹 Background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("💌 Arka planda gelen mesaj: ${message.messageId}");

  final data = message.data;
  final toUserId = data['toUserId'];
  if (toUserId != null) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(toUserId)
        .collection('notifications')
        .add({
      'title': message.notification?.title,
      'body': message.notification?.body,
      'data': data,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _initLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  const initSettings = InitializationSettings(android: android, iOS: ios);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  const channel = AndroidNotificationChannel(
    'easygo_default',
    'Genel Bildirimler',
    description: 'Uygulama içi bildirim kanalı',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> _showLocalNotification(RemoteMessage message) async {
  final notification = message.notification;
  if (notification == null) return;

  const android = AndroidNotificationDetails(
    'easygo_default',
    'Genel Bildirimler',
    importance: Importance.high,
    priority: Priority.high,
  );

  const ios = DarwinNotificationDetails();

  const details = NotificationDetails(android: android, iOS: ios);

  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    notification.title,
    notification.body,
    details,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await _initLocalNotifications();

  // 🔥 InboxBadge başlat (Firestore unread dinleme)
  await InboxBadge.init();

  runApp(const AppInitializer());
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _initFCM();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('darkMode') ?? false;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDark);
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> _initFCM() async {
  final messaging = FirebaseMessaging.instance;

  // iOS için izin iste
  if (Platform.isIOS) {
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  try {
    // Token almaya çalış
    final token = await messaging.getToken();
    print("📲 FCM Token: $token");

    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId'); 
      if (userId != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).set(
          {'fcmToken': token},
          SetOptions(merge: true),
        );
        print("🔥 Token Firestore'a kaydedildi -> $userId");
      }
    } else {
      // iOS fallback
      print("⚠️ iOS FCM token alınamadı, local notification fallback çalışıyor.");
    }
  } catch (e) {
    print("❌ FCM Token alınırken hata: $e");
    if (Platform.isIOS) {
      print("⚠️ iOS fallback aktif (APNs ayarları yok)");
    }
  }

  // Token değişirse güncelle
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).set(
        {'fcmToken': newToken},
        SetOptions(merge: true),
      );
      print("♻️ Token Firestore'da güncellendi -> $userId");
    }
  });

  // Foreground mesaj (Android’de çalışır, iOS’ta local fallback)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("📨 Foreground mesaj: ${message.notification?.title}");
    _showLocalNotification(message);

    // Bildirimi Firestore’a kaydet
    SharedPreferences.getInstance().then((prefs) {
      final uid = prefs.getString('userId');
      if (uid != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .add({
          'title': message.notification?.title ?? "Test Bildirimi",
          'body': message.notification?.body ?? "Bu bir local fallback",
          'data': message.data,
          'createdAt': FieldValue.serverTimestamp(),
          'read': false,
        });
      }
    });
  });
}


  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      themeMode: _themeMode,
      toggleTheme: _toggleTheme,
      child: const MyApp(),
    );
  }
}

class ThemeProvider extends InheritedWidget {
  final ThemeMode themeMode;
  final void Function(bool isDark) toggleTheme;

  const ThemeProvider({
    super.key,
    required this.themeMode,
    required this.toggleTheme,
    required Widget child,
  }) : super(child: child);

  static ThemeProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>()!;
  }

  @override
  bool updateShouldNotify(covariant ThemeProvider oldWidget) {
    return oldWidget.themeMode != themeMode;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'easyGO',
      theme: ThemeData(
        useMaterial3: false,
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
      ),
      darkTheme: ThemeData(
        useMaterial3: false,
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
      ),
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
    );
  }
}
