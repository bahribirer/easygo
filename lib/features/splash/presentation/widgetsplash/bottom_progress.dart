import 'package:flutter/material.dart';

class BottomProgress extends StatefulWidget {
  final Color accent;
  const BottomProgress({super.key, required this.accent});

  @override
  State<BottomProgress> createState() => _BottomProgressState();
}

class _BottomProgressState extends State<BottomProgress>
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
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 6,
            backgroundColor: widget.accent.withOpacity(.15),
            valueColor: AlwaysStoppedAnimation(widget.accent),
          ),
        ),
        SizedBox(height: w * 0.025),
        SizedBox(
          height: 16,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              double v(int i) => (1 + (i * .33) + _ctrl.value) % 1.0;
              double dy(double t) => (t < .5 ? t : 1 - t) * 8;

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
