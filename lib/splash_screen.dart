import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'welcome_screen.dart';

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
      TweenSequenceItem(tween: Tween(begin: .85, end: 1.08).chain(CurveTween(curve: Curves.easeOutBack)), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 45),
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

    final gradientColors = isDark
        ? const [Color(0xFF111018), Color(0xFF1B1A28)]
        : const [Color(0xFFFFF0E9), Color(0xFFFFF7F3)];

    final accentA = isDark ? const Color(0xFFEA5455) : const Color(0xFFEA5455);
    final accentB = isDark ? const Color(0xFFFEB692) : const Color(0xFFFEB692);

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

          // Soft blobs (blurred)
          Positioned(
            top: h * -0.10,
            left: w * -0.20,
            child: _BlurBlob(size: w * 0.8, color: accentB.withOpacity(.55)),
          ),
          Positioned(
            bottom: h * -0.12,
            right: w * -0.25,
            child: _BlurBlob(size: w * 0.95, color: accentA.withOpacity(.45)),
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
                              // Logo
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
                              // Brand title
                              Text(
                                "easyGO",
                                style: TextStyle(
                                  fontSize: w * 0.10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                  color: isDark ? Colors.white : const Color(0xFFCE1B1B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: h * 0.012),

                  // Tagline
                  FadeTransition(
                    opacity: _fadeCtrl,
                    child: Text(
                      "Seni bekleyen harika insanlar var!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: w * 0.040,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),

                  SizedBox(height: h * 0.04),

                  // Lottie
                  SizedBox(
                    width: w * 0.55,
                    height: w * 0.55,
                    child: Lottie.asset(
                      'assets/people_loading.json',
                      fit: BoxFit.contain,
                    ),
                  ),

                  const Spacer(),

                  // Progress + dots
                  _BottomProgress(accent: accentA),

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

/// Soft blur circle
class _BlurBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _BlurBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// Bottom progress line + animated dots
class _BottomProgress extends StatefulWidget {
  final Color accent;
  const _BottomProgress({required this.accent});

  @override
  State<_BottomProgress> createState() => _BottomProgressState();
}

class _BottomProgressState extends State<_BottomProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Column(
      children: [
        // Animated linear progress (indeterminate feel)
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 6,
            backgroundColor: widget.accent.withOpacity(.15),
            valueColor: AlwaysStoppedAnimation(widget.accent),
          ),
        ),
        SizedBox(height: w * 0.025),
        // Three bouncing dots
        SizedBox(
          height: 16,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              double v(int i) =>
                  (1 + (i * .33) + _ctrl.value) % 1.0; // faz kaydırma
              double dy(double t) => (t < .5 ? t : 1 - t) * 8; // yukarı-aşağı

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final t = v(i);
                  return Transform.translate(
                    offset: Offset(0, -dy(t)),
                    child: Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: widget.accent.withOpacity(.9 - i * 0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }
}
