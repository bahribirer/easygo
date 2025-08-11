import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _scale;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _scale = CurvedAnimation(parent: _ac, curve: Curves.easeOutBack);
    _float = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    // responsive ölçüler
    final logoH = (w * 0.16).clamp(52.0, 96.0);
    final ring = (w * 0.68).clamp(240.0, 340.0);
    final centerAv = (w * 0.23).clamp(64.0, 92.0);
    final miniAv = (w * 0.11).clamp(26.0, 34.0);

    final bgColor = isDark ? const Color(0xFF0B0B0C) : const Color(0xFFFFF8F3);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (_, c) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 16 + MediaQuery.of(context).padding.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: c.maxHeight - 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: h * 0.02),

                    // Logo
                    Semantics(
                      label: 'easyGO Logo',
                      child: Image.asset(
                        'assets/easygo_logo.png',
                        height: logoH,
                        fit: BoxFit.contain,
                      ),
                    ),

                    SizedBox(height: h * 0.03),

                    // Hero dairesi + avatarlar
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // büyük yumuşak degrade halka
                          _BlurredCircle(
                            size: ring,
                            colors: isDark
                                ? const [Color(0xFF1F1F22), Color(0xFF1A1A1C)]
                                : [Colors.orange.shade100, Colors.orange.shade200],
                          ),

                          // yüzen minik avatarlar
                          _FloatingMiniAvatar(
                            angle: -math.pi / 2,
                            radius: ring * 0.42,
                            size: miniAv,
                            color: isDark
                                ? const Color(0xFF2E2E31)
                                : Colors.blue.shade200,
                            float: _float,
                          ),
                          _FloatingMiniAvatar(
                            angle: math.pi / 6,
                            radius: ring * 0.44,
                            size: miniAv,
                            color: isDark
                                ? const Color(0xFF2A2A2D)
                                : Colors.green.shade200,
                            float: _float,
                          ),
                          _FloatingMiniAvatar(
                            angle: math.pi - math.pi / 5,
                            radius: ring * 0.46,
                            size: miniAv,
                            color: isDark
                                ? const Color(0xFF2B2B2E)
                                : Colors.purple.shade200,
                            float: _float,
                          ),

                          // ortadaki avatar
                          ScaleTransition(
                            scale: _scale,
                            child: CircleAvatar(
                              radius: centerAv,
                              backgroundColor:
                                  isDark ? const Color(0xFFEA5455) : Colors.red.shade400,
                              child: const Icon(Icons.person, size: 48, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.03),

                    // Başlık
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Hoş',
                        style: GoogleFonts.poppins(
                          fontSize: (w * 0.08).clamp(22.0, 30.0),
                          color: isDark ? const Color(0xFFFF6F6F) : Colors.red.shade700,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                        children: [
                          TextSpan(
                            text: 'geldiniz…',
                            style: GoogleFonts.poppins(
                              color: isDark ? const Color(0xFF7AB8FF) : Colors.blue.shade700,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Tagline
                    Text(
                      '"Bağlantılar kur,\nsohbet et, eğlen"',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: (w * 0.042).clamp(14.0, 18.0),
                        color: textSecondary,
                        height: 1.35,
                      ),
                    ),

                    SizedBox(height: h * 0.035),

                    // Cam efektli CTA kart
                    _GlassCard(
                      dark: isDark,
                      child: Column(
                        children: [
                          // Giriş Yap
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isDark ? const Color(0xFFEA5455) : Colors.red.shade600,
                                elevation: 0,
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                              },
                              child: Text(
                                "Giriş Yap",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Google ile Devam Et (placeholder)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.g_mobiledata, size: 28),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    isDark ? Colors.white : const Color(0xFF5F6368),
                                side: BorderSide(
                                  color: isDark ? Colors.white24 : const Color(0xFFDBDBDB),
                                ),
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                backgroundColor:
                                    isDark ? const Color(0xFF121212) : Colors.white,
                              ),
                              label: Text(
                                "Google ile Devam Et",
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: () {
                                // TODO: Google Sign-In entegre edilecek
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Kayıt Ol linki
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Hesabın yok mu? ",
                          style: GoogleFonts.poppins(
                            color: textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor:
                                isDark ? const Color(0xFF7AB8FF) : Colors.blue.shade700,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                          child: Text(
                            "Kayıt Ol",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ----------------- Helpers -----------------

class _BlurredCircle extends StatelessWidget {
  final double size;
  final List<Color> colors;
  const _BlurredCircle({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(.35),
            blurRadius: 40,
            spreadRadius: 6,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(.55),
            width: 0.6,
          ),
        ),
      ),
    );
  }
}

class _FloatingMiniAvatar extends StatelessWidget {
  final double angle; // radyan
  final double radius;
  final double size;
  final Color color;
  final Animation<double> float;

  const _FloatingMiniAvatar({
    required this.angle,
    required this.radius,
    required this.size,
    required this.color,
    required this.float,
  });

  @override
  Widget build(BuildContext context) {
    final dx = radius * math.cos(angle);
    final dy = radius * math.sin(angle);

    return AnimatedBuilder(
      animation: float,
      builder: (_, __) {
        final bob = math.sin(float.value * math.pi) * 6; // hafif yukarı-aşağı
        return Transform.translate(
          offset: Offset(dx, dy + bob),
          child: CircleAvatar(
            radius: size,
            backgroundColor: color,
            child: const Icon(Icons.person, size: 18, color: Colors.white),
          ),
        );
      },
    );
  }
}

class _GlassCard extends StatelessWidget {
  final bool dark;
  final Widget child;
  const _GlassCard({required this.dark, required this.child});

  @override
  Widget build(BuildContext context) {
    final cardColor = dark ? const Color(0xFF121212) : Colors.white;
    final border = dark ? Colors.white10 : Colors.black12;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(dark ? .9 : .85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
