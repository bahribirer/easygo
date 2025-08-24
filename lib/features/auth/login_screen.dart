import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:easygo/core/service/auth_service.dart';
import 'package:easygo/features/auth/forgot_password_screen.dart';
import 'package:easygo/features/home/view/home_screen.dart';
import 'package:easygo/widgets/ui/glass_card.dart';
import 'package:easygo/widgets/ui/blur_blob.dart';
import 'package:easygo/widgets/ui/back_to_main_button.dart';
import 'package:easygo/l10n/app_localizations.dart'; // 🔹 eklendi

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscure = true;

  // ----------------- POPUP HELPERS -----------------
  Future<void> _showAnimatedDialog({
    required String title,
    required String message,
    required IconData icon,
    Color? color,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..forward();

    await showGeneralDialog(
      context: context,
      barrierLabel: 'dialog',
      barrierColor: Colors.black54,
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: ctrl, curve: Curves.easeOutBack),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Material(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                elevation: 0,
                borderRadius: BorderRadius.circular(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            color: (color ?? Colors.red.shade700).withOpacity(.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: color ?? Colors.red.shade700, size: 30),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: color ?? Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color ?? Colors.red.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.ok,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim, _, child) => FadeTransition(opacity: anim, child: child),
    );

    ctrl.dispose();
  }

  Future<void> _showInfoDialog(String msg) => _showAnimatedDialog(
        title: AppLocalizations.of(context)!.loginInfoTitle,
        message: msg,
        icon: Icons.info_outline,
        color: Colors.orange.shade700,
      );

  Future<void> _showErrorDialog(String msg) => _showAnimatedDialog(
        title: AppLocalizations.of(context)!.loginErrorTitle,
        message: msg,
        icon: Icons.error_outline,
        color: Colors.red.shade700,
      );

  // ----------------- LOGIN -----------------
  Future<void> _handleLogin() async {
    final loc = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      await _showInfoDialog(loc.loginInfoMessage);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim().toLowerCase(),
        password: passwordController.text,
      );

      final res = await AuthService.loginUsingCurrentFirebaseUser();

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res['success'] == true) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          ),
        );
      } else {
        await _showErrorDialog(res['message'] ?? loc.loginErrorTitle);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      String msg;
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
          msg = loc.loginErrorWrongCredentials;
          break;
        case 'user-not-found':
          msg = loc.loginErrorNotFound;
          break;
        case 'too-many-requests':
          msg = loc.loginErrorTooMany;
          break;
        case 'network-request-failed':
          msg = loc.loginErrorNetwork;
          break;
        case 'invalid-email':
          msg = loc.loginErrorInvalidEmail;
          break;
        default:
          msg = loc.loginErrorUnexpected(e.code);
      }
      await _showErrorDialog(msg);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      await _showErrorDialog(loc.loginErrorUnexpected(e.toString()));
    }
  }

  // ----------------- UI -----------------
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseGrad = isDark
        ? const [Color(0xFF1E1E1E), Color(0xFF2C2C2C)]
        : const [Color(0xFFFFF0E9), Color(0xFFFFF7F3)];
    final accent = const Color(0xFFEA5455);

    return Scaffold(
      backgroundColor: baseGrad.first,
      body: Stack(
        children: [
          // BG gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: baseGrad,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Subtle blobs
          Positioned(
            top: -h * .18,
            right: -w * .2,
            child: BlurBlob(size: w * .9, color: const Color(0xFFFEB692).withOpacity(.45)),
          ),
          Positioned(
            bottom: -h * .22,
            left: -w * .25,
            child: BlurBlob(size: w * 1.1, color: accent.withOpacity(.35)),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: const BackToMainButton(),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo & Title
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: accent.withOpacity(.25),
                                blurRadius: 28,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/easygo_logo.png',
                            width: w * .28,
                            height: w * .28,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${loc.loginTitleLine1}\n',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: isDark ? Colors.orangeAccent : Colors.red.shade700,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              TextSpan(
                                text: loc.loginTitleLine2,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: isDark ? Colors.lightBlueAccent : Colors.blue.shade700,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Glass card form
                    GlassCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              decoration: _inputDecoration(
                                label: loc.emailLabel,
                                hint: loc.emailHint,
                                icon: Icons.alternate_email_rounded,
                                isDark: isDark,
                              ),
                              validator: (val) {
                                final t = (val ?? '').trim();
                                if (t.isEmpty) return loc.emailRequired;
                                final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(t);
                                if (!ok) return loc.emailInvalid;
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: passwordController,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _handleLogin(),
                              decoration: _inputDecoration(
                                label: loc.passwordLabel,
                                hint: loc.passwordHint,
                                icon: Icons.lock_outline_rounded,
                                suffix: IconButton(
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                  ),
                                ),
                                isDark: isDark,
                              ),
                              validator: (val) {
                                if ((val ?? '').isEmpty) return loc.passwordRequired;
                                if ((val ?? '').length < 6) return loc.passwordMinLength;
                                return null;
                              },
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                                  );
                                },
                                child: Text(
                                  loc.forgotPassword,
                                  style: TextStyle(
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 22, width: 22,
                                        child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                                      )
                                    : Text(
                                        loc.loginButton,
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_isLoading)
            IgnorePointer(
              ignoring: true,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: .25,
                child: Container(color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
    required bool isDark,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: isDark ? Colors.white70 : Colors.black87),
      suffixIcon: suffix,
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
      hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black38),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black.withOpacity(.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEA5455), width: 1.4),
      ),
      filled: true,
      fillColor: isDark ? Colors.black.withOpacity(.25) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}
