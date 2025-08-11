import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _emailFocus = FocusNode();

  bool _submitting = false;
  bool _touched = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  String? _emailValidator(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return "E‑posta adresinizi giriniz.";
    final emailRe = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");
    if (!emailRe.hasMatch(value)) return "Geçerli bir e‑posta giriniz.";
    return null;
  }

  Future<void> _handleSend() async {
  setState(() => _touched = true);

  final user = FirebaseAuth.instance.currentUser;
  String? emailToSend;

  // Eğer kullanıcı giriş yapmışsa kendi mailini al
  if (user != null && user.email != null) {
    emailToSend = user.email!;
  } else {
    // Form valid mi kontrol et
    if (!_formKey.currentState!.validate()) {
      _showPopup(
        title: "Eksik / Hatalı Bilgi",
        message: "Lütfen e-posta alanını kontrol ederek tekrar deneyin.",
        type: _PopupType.error,
      );
      return;
    }
    emailToSend = _emailCtrl.text.trim();
  }

  FocusScope.of(context).unfocus();
  setState(() => _submitting = true);

  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: emailToSend);
    _showPopup(
      title: "Gönderildi",
      message:
          "Şifre sıfırlama bağlantısı ${user != null ? user.email : emailToSend} adresinize gönderildi. Gelen kutusu ve spam klasörünü kontrol edin.",
      type: _PopupType.success,
    );
  } on FirebaseAuthException catch (e) {
    debugPrint('🔴 FirebaseAuthException code=${e.code} message=${e.message}');
    String errorMsg;
    switch (e.code) {
      case 'invalid-email':
        errorMsg = "Geçersiz e-posta adresi.";
        break;
      case 'network-request-failed':
        errorMsg = "Ağ hatası. İnternet bağlantınızı kontrol edin.";
        break;
      case 'too-many-requests':
        errorMsg = "Çok fazla deneme yapıldı. Bir süre sonra tekrar deneyin.";
        break;
      case 'user-disabled':
        errorMsg = "Bu hesap devre dışı bırakılmış.";
        break;
      default:
        errorMsg =
            "İşlem alınamadı. Bir süre sonra tekrar deneyin veya farklı bir e-posta ile deneyin.";
    }
    _showPopup(title: "Bilgi", message: errorMsg, type: _PopupType.info);
  } catch (e) {
    debugPrint('🔴 Unknown error: $e');
    _showPopup(
      title: "Bilgi",
      message: "İşlem alınamadı. Lütfen tekrar deneyiniz.",
      type: _PopupType.info,
    );
  } finally {
    if (mounted) setState(() => _submitting = false);
  }
}



  void _showPopup({
    required String title,
    required String message,
    _PopupType type = _PopupType.info,
  }) {
    final (icon, color) = switch (type) {
      _PopupType.success => (Icons.check_circle, Colors.green),
      _PopupType.error => (Icons.error_rounded, Colors.red),
      _PopupType.info => (Icons.info, Colors.blue),
    };

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: color.shade700,
                ),
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Tamam",
              style: TextStyle(color: color.shade700, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  bool get _isFormValid =>
      _emailValidator(_emailCtrl.text) == null && _touched;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final red = Colors.red.shade700;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8F9FB),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
            tooltip: "Geri",
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              children: [
                const SizedBox(height: 4),
                Image.asset('assets/easygo_logo.png', height: 56),
                const SizedBox(height: 16),
                Text(
                  "Şifremi Unuttum",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: red,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  "Mail adresine doğrulama bağlantısı göndereceğiz.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 22,
                        offset: Offset(0, 10),
                        color: Color(0x1F000000),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _touched
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailCtrl,
                          focusNode: _emailFocus,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          onChanged: (_) => setState(() {}),
                          onFieldSubmitted: (_) => _handleSend(),
                          validator: _emailValidator,
                          decoration: InputDecoration(
                            labelText: "Üniversite E‑mail Adresi",
                            hintText: "ornek@samsun.edu.tr",
                            prefixIcon:
                                const Icon(Icons.alternate_email_rounded),
                            filled: true,
                            fillColor: const Color(0xFFF5F6F8),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.lock_reset, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Gelen kutunuzu ve spam klasörünü kontrol edin. Kurumsal adreslerde karantinaya düşebilir.",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _submitting ? null : _handleSend,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isFormValid && !_submitting ? red : Colors.grey,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: _submitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text(
                                    "Doğrulama Bağlantısı Gönder",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: .2,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                TextButton.icon(
                  onPressed: () {
                    _showPopup(
                      title: "Yardım",
                      message:
                          "E‑posta gelmediyse spam klasörünü kontrol edin veya birkaç dakika sonra tekrar deneyin.",
                      type: _PopupType.info,
                    );
                  },
                  icon: const Icon(Icons.help_outline),
                  label: const Text("E‑posta gelmedi mi?"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _PopupType { success, error, info }
