import 'package:flutter/material.dart';

/// Adım başlığı + yüzde çemberi (0..1)
class StepHeader extends StatelessWidget {
  final double progress; // 0..1
  final String title;
  final Color color;
  final Widget? leading;  // opsiyonel özel ikon/leading
  final Widget? trailing; // opsiyonel sağdaki ekstra aksiyon

  const StepHeader({
    super.key,
    required this.progress,
    this.title = 'Profili Tamamla',
    this.color = const Color(0xFFEA5455),
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);
    final pct = (p * 100).round();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            leading ??
                Icon(Icons.flag_rounded, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? const Color(0xFFF5F5F5) : const Color(0xFF212121),
              ),
            ),
          ],
        ),
        Row(
          children: [
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 8),
            ],
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    value: p,
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    backgroundColor:
                        isDark ? const Color(0xFF424242) : const Color(0xFFE0E0E0),
                  ),
                ),
                Text(
                  '%$pct',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Küçük ipucu kartı
class StepHintCard extends StatelessWidget {
  final String text;
  const StepHintCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor.withOpacity(.95);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Color(0xFFFFA000)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF424242),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bölüm başlığı (kırmızı küçük başlık + açıklama)
class StepSectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const StepSectionTitle({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            )),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.black87),
        ),
      ],
    );
  }
}

/// Başlıksız cam kart (genel amaçlı)
class StepGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const StepGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 18, 16, 16),
    this.margin = const EdgeInsets.fromLTRB(4, 8, 4, 8),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? const Color(0x22FFFFFF) : Colors.black.withOpacity(.06);

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(.06),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Başlıklı cam kart (Step3'teki gibi)
class StepTitledCard extends StatelessWidget {
  final String title;
  final Widget child;
  const StepTitledCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return StepGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
