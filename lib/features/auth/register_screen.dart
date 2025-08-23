import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:easygo/core/service/auth_service.dart';
import 'package:easygo/features/profile/steps/profile_step1.dart';
import 'package:easygo/widgets/ui/glass_card.dart';
import 'package:easygo/widgets/ui/blur_blob.dart';
import 'package:easygo/l10n/app_localizations.dart'; // 🔹 eklendi

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Form + UI flags
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscure = true;

  // Password strength & checklist
  double _strength = 0; // 0..1
  bool _hasMinLen = false;
  bool _hasUpper = false;
  bool _hasSpecial = false;

  // -------- POPUP (animated) --------
  Future<void> _showAnimatedDialog({
    required String title,
    required String message,
    required IconData icon,
    Color? color,
  }) async {
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..forward();

    await showGeneralDialog(
      context: context,
      barrierLabel: 'dialog',
      barrierColor: Colors.black45,
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: ctrl, curve: Curves.easeOutBack),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Material(
                color: Colors.white,
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
                          child: Icon(icon,
                              color: color ?? Colors.red.shade700, size: 30),
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
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
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
                              AppLocalizations.of(context)!.ok, // 🔹 çeviri
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 15),
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
      transitionBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    );

    ctrl.dispose();
  }

  Future<void> _info(String msg) => _showAnimatedDialog(
        title: AppLocalizations.of(context)!.dialogInfoTitle, // 🔹
        message: msg,
        icon: Icons.info_outline_rounded,
        color: Colors.orange.shade700,
      );

  Future<void> _error(String msg) => _showAnimatedDialog(
        title: AppLocalizations.of(context)!.dialogErrorTitle, // 🔹
        message: msg,
        icon: Icons.error_outline_rounded,
        color: Colors.red.shade700,
      );

  // -------- VALIDATION --------
  bool _isValidUniversityEmail(String email) {
    final re = RegExp(r'^[\w\.-]+@metu\.edu\.tr$');
    return re.hasMatch(email);
  }

  void _calcPasswordHints(String text) {
    _hasMinLen = text.length >= 8;
    _hasUpper = RegExp(r'[A-Z]').hasMatch(text);
    _hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(text);

    double s = 0;
    if (text.length >= 6) s += .25;
    if (_hasUpper) s += .25;
    if (_hasSpecial) s += .25;
    if (text.length >= 10) s += .25;
    _strength = s;
  }

  Color _strengthColor() {
    if (_strength <= .25) return Colors.red;
    if (_strength <= .5) return Colors.orange;
    if (_strength <= .75) return Colors.blue;
    return Colors.green;
  }

  String _strengthText(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (_strength <= .25) return loc.strengthWeak;
    if (_strength <= .5) return loc.strengthMedium;
    if (_strength <= .75) return loc.strengthGood;
    return loc.strengthStrong;
  }

  // -------- SUBMIT --------
  Future<void> _submit() async {
    final loc = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      await _info(loc.infoFillForm); // 🔹
      return;
    }

    setState(() => _isLoading = true);

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    final res = await AuthService.register(
      name: name,
      universityEmail: email,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.toLowerCase(),
          password: password,
        );
      } catch (_) {}

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', res['user']['_id']);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 380),
          pageBuilder: (_, __, ___) => const ProfileStep1Screen(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        ),
      );
    } else {
      await _error(res['message'] ?? loc.dialogErrorTitle); // 🔹
    }
  }

  // -------- UI --------
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    final baseGrad = const [Color(0xFFFFF0E9), Color(0xFFFFF7F3)];
    final accent = const Color(0xFFEA5455);

    return Scaffold(
      backgroundColor: baseGrad.first,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
          tooltip: loc.commonBack, // 🔹
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: baseGrad,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -h * .18,
            right: -w * .2,
            child: BlurBlob(
              size: w * .9,
              color: const Color(0xFFFEB692).withOpacity(.55),
            ),
          ),
          Positioned(
            bottom: -h * .22,
            left: -w * .25,
            child: BlurBlob(
              size: w * 1.1,
              color: accent.withOpacity(.40),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: accent.withOpacity(.22),
                                blurRadius: 28,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/easygo_logo.png',
                            width: w * .26,
                            height: w * .26,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${loc.registerTitle}\n', // 🔹
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              TextSpan(
                                text: loc.registerSubtitle, // 🔹
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    GlassCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: nameController,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              decoration: _decoration(
                                label: loc.nameLabel, // 🔹
                                hint: loc.nameHint, // 🔹
                                icon: Icons.person_outline_rounded,
                              ),
                              validator: (v) {
                                final t = (v ?? '').trim();
                                if (t.isEmpty) return loc.nameLabel;
                                if (t.length < 2) return loc.infoFillForm;
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              textInputAction: TextInputAction.next,
                              decoration: _decoration(
                                label: loc.emailLabel, // 🔹
                                hint: loc.emailHint, // 🔹
                                icon: Icons.alternate_email_rounded,
                              ),
                              validator: (v) {
                                final t = (v ?? '').trim();
                                if (t.isEmpty) return loc.errorEmptyEmail;
                                if (!_isValidUniversityEmail(t)) {
                                  return loc.errorEmailDomain;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: passwordController,
                              obscureText: _obscure,
                              onChanged: (text) =>
                                  setState(() => _calcPasswordHints(text)),
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: _decoration(
                                label: loc.passwordLabel, // 🔹
                                hint: loc.passwordHint, // 🔹
                                icon: Icons.lock_outline_rounded,
                                suffix: IconButton(
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                  icon: Icon(_obscure
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded),
                                ),
                              ),
                              validator: (v) {
                                final t = v ?? '';
                                if (t.isEmpty) return loc.passwordRequired;
                                if (t.length < 8) return loc.passwordMinChars(8);
                                if (!RegExp(r'[A-Z]').hasMatch(t)) {
                                  return 'En az bir büyük harf'; // 🔹 istersen loc’a eklenir
                                }
                                if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]')
                                    .hasMatch(t)) {
                                  return 'En az bir özel karakter (@,#,!)'; // 🔹 istersen loc’a eklenir
                                }
                                return null;
                              },
                            ),

                            if (passwordController.text.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _StrengthMeter(
                                strength: _strength,
                                color: _strengthColor(),
                                label: _strengthText(context), // 🔹
                              ),
                              const SizedBox(height: 8),
                              _ChecklistRow(
                                ok: _hasMinLen,
                                text: loc.passwordMinChars(8), // 🔹
                              ),
                              _ChecklistRow(
                                ok: _hasUpper,
                                text: 'En az bir büyük harf (A-Z)', // 🔹
                              ),
                              _ChecklistRow(
                                ok: _hasSpecial,
                                text: 'En az bir özel karakter (@,#,!)', // 🔹
                              ),
                            ],

                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        loc.btnRegister, // 🔹
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
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

  InputDecoration _decoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEA5455), width: 1.4),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

// ---- Strength meter ----
class _StrengthMeter extends StatelessWidget {
  final double strength; // 0..1
  final Color color;
  final String label;
  const _StrengthMeter({
    required this.strength,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      strength >= .10,
      strength >= .35,
      strength >= .65,
      strength >= .90,
    ];
    return Row(
      children: [
        for (int i = 0; i < 4; i++)
          Expanded(
            child: Container(
              height: 8,
              margin: EdgeInsets.only(right: i == 3 ? 0 : 6),
              decoration: BoxDecoration(
                color: steps[i] ? color : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ---- Checklist row ----
class _ChecklistRow extends StatelessWidget {
  final bool ok;
  final String text;
  const _ChecklistRow({required this.ok, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18, color: ok ? Colors.green : Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.5,
              color: ok ? Colors.black87 : Colors.black54,
              fontWeight: ok ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
