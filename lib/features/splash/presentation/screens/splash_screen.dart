import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:easygo/features/welcome/welcome_screen.dart';
import '../widgetsplash/blur_blob.dart';
import '../widgetsplash/bottom_progress.dart';
import 'package:easygo/l10n/app_localizations.dart'; // ✅ eklendi

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoTilt;
  late final AnimationController _fadeCtrl;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: .85, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 45,
      ),
    ]).animate(_logoCtrl);

    _logoTilt = Tween<double>(begin: -0.02, end: 0.02)
        .chain(CurveTween(curve: Curves.easeInOutSine))
        .animate(_logoCtrl);

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _logoCtrl.forward();
    _fadeCtrl.forward();

    _navTimer = Timer(const Duration(seconds: 3), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (_, __, ___) => const WelcomeScreen(),
      transitionsBuilder: (_, anim, __, child) {
        return FadeTransition(opacity: anim, child: child);
      },
    ));
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _logoCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final loc = AppLocalizations.of(context)!; // ✅ lokalizasyon

    final gradientColors = isDark
        ? const [Color(0xFF111018), Color(0xFF1B1A28)]
        : const [Color(0xFFFFF0E9), Color(0xFFFFF7F3)];

    final accentA = const Color(0xFFEA5455);
    final accentB = const Color(0xFFFEB692);

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Soft blobs
          Positioned(
            top: h * -0.10,
            left: w * -0.20,
            child: BlurBlob(size: w * 0.8, color: accentB.withOpacity(.55)),
          ),
          Positioned(
            bottom: h * -0.12,
            right: w * -0.25,
            child: BlurBlob(size: w * 0.95, color: accentA.withOpacity(.45)),
          ),

          // Foreground content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.08),
              child: Column(
                children: [
                  SizedBox(height: h * 0.08),

                  // Logo + brand
                  AnimatedBuilder(
                    animation: _logoCtrl,
                    builder: (_, __) {
                      return Transform.rotate(
                        angle: _logoTilt.value,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(w * 0.02),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentA.withOpacity(.25),
                                      blurRadius: 30,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/easygo_logo.png',
                                  width: w * 0.36,
                                  height: w * 0.36,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: h * 0.018),
                              Text(
                                "easyGO", // marka adı çevrilmez
                                style: TextStyle(
                                  fontSize: w * 0.10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFFCE1B1B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: h * 0.012),

                  FadeTransition(
                    opacity: _fadeCtrl,
                    child: Text(
                      loc.splashSubtitle, // 🔹 lokalize edildi
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: w * 0.040,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),

                  SizedBox(height: h * 0.04),

                  SizedBox(
                    width: w * 0.55,
                    height: w * 0.55,
                    child: Lottie.asset(
                      'assets/people_loading.json',
                      fit: BoxFit.contain,
                    ),
                  ),

                  const Spacer(),

                  BottomProgress(accent: accentA),

                  SizedBox(height: mq.padding.bottom + h * 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
