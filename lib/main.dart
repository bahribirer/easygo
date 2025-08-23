import 'dart:io';
import 'package:easygo/core/inbox_badge.dart';
import 'package:easygo/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'core/firebase/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


// 🔹 Background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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

  // 🔹 Lokalizasyon kullanılacağı için sadece kanal id sabit
  const channel = AndroidNotificationChannel(
    'easygo_default',
    'easyGO Channel', // varsayılan, runtime'da localize edilebilir
    description: 'App notification channel',
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
    'easyGO Channel',
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
  await InboxBadge.init(); // 🔥 unread dinleme

  runApp(const AppInitializer());
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});
  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  ThemeMode _themeMode = ThemeMode.light;

  // 🔹 EKLENDİ: dil için state
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _loadLocale(); // 🔹 EKLENDİ
    _initFCM();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('darkMode') ?? false;
    setState(() => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light);
  }

  // 🔹 EKLENDİ: kaydedilmiş dili yükle
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('lang'); // 'tr' | 'en'
    if (code != null) setState(() => _locale = Locale(code));
  }

  // 🔹 EKLENDİ: dili ayarla
  Future<void> _setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', code);
    setState(() => _locale = Locale(code));
  }

  void _toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDark);
    setState(() => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _initFCM() async {
    final messaging = FirebaseMessaging.instance;

    if (Platform.isIOS) {
      await messaging.requestPermission(alert: true, badge: true, sound: true);
    }

    try {
      final token = await messaging.getToken();
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('userId');
        if (userId != null) {
          await FirebaseFirestore.instance.collection('users').doc(userId).set(
            {'fcmToken': token},
            SetOptions(merge: true),
          );
        }
      }
    } catch (_) {}

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).set(
          {'fcmToken': newToken},
          SetOptions(merge: true),
        );
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
      SharedPreferences.getInstance().then((prefs) {
        final uid = prefs.getString('userId');
        if (uid != null) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('notifications')
              .add({
            'title': message.notification?.title ??
                AppLocalizations.of(context)!.testNotificationTitle,
            'body': message.notification?.body ??
                AppLocalizations.of(context)!.testNotificationBody,
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
      locale: _locale,                 // 🔹 EKLENDİ
      setLanguage: _setLanguage,       // 🔹 EKLENDİ
      child: const MyApp(),
    );
  }
}

class ThemeProvider extends InheritedWidget {
  final ThemeMode themeMode;
  final void Function(bool isDark) toggleTheme;

  // 🔹 EKLENDİ
  final Locale? locale;
  final Future<void> Function(String code) setLanguage;

  const ThemeProvider({
    super.key,
    required this.themeMode,
    required this.toggleTheme,
    required this.locale,
    required this.setLanguage,
    required Widget child,
  }) : super(child: child);

  static ThemeProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeProvider>()!;

  @override
  bool updateShouldNotify(covariant ThemeProvider old) {
    return old.themeMode != themeMode || old.locale != locale;
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
      // 🔹 DİL BAĞLANTISI
      locale: themeProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

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
