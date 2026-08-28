import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../nurr_design.dart';

class OnboardingCard extends StatelessWidget {
  const OnboardingCard({
    super.key,
    required this.dark,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.borderColor,
  });

  final bool dark;
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? NurrDesign.surface(dark),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: borderColor ?? NurrDesign.gold.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.22 : 0.07),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class OnboardingActionButton extends StatefulWidget {
  const OnboardingActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  State<OnboardingActionButton> createState() => _OnboardingActionButtonState();
}

class _OnboardingActionButtonState extends State<OnboardingActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.975 : 1,
      duration: const Duration(milliseconds: 120),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: Listener(
          onPointerDown: (_) => setState(() => _pressed = true),
          onPointerUp: (_) => setState(() => _pressed = false),
          onPointerCancel: (_) => setState(() => _pressed = false),
          child: FilledButton.icon(
            onPressed: widget.onPressed,
            icon: widget.icon == null
                ? const SizedBox.shrink()
                : Icon(widget.icon, size: 20),
            label: Text(
              widget.label,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: NurrDesign.goldDark,
              foregroundColor: Colors.white,
              disabledBackgroundColor: NurrDesign.gold.withValues(alpha: 0.45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedPageIndicators extends StatelessWidget {
  const AnimatedPageIndicators({
    super.key,
    required this.count,
    required this.current,
  });

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutCubic,
          width: index == current ? 28 : 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: index == current
                ? NurrDesign.gold
                : NurrDesign.muted.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

class OnboardingBackdrop extends StatelessWidget {
  const OnboardingBackdrop({
    super.key,
    required this.dark,
    required this.animation,
    required this.reducedMotion,
  });

  final bool dark;
  final Animation<double> animation;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final value = reducedMotion ? 0.0 : animation.value;
            return Stack(
              children: [
                Positioned(
                  top: -90 + math.sin(value * math.pi * 2) * 8,
                  right: -80,
                  child: _Glow(
                    size: 260,
                    color: NurrDesign.gold.withValues(
                      alpha: dark ? 0.10 : 0.14,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 90 + math.cos(value * math.pi * 2) * 7,
                  left: -100,
                  child: _Glow(
                    size: 240,
                    color: NurrDesign.emerald.withValues(
                      alpha: dark ? 0.10 : 0.07,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class OnboardingLivingLayer extends StatelessWidget {
  const OnboardingLivingLayer({
    super.key,
    required this.dark,
    required this.animation,
    required this.reducedMotion,
  });

  final bool dark;
  final Animation<double> animation;
  final bool reducedMotion;

  static const _points = [
    Offset(.08, .12),
    Offset(.21, .24),
    Offset(.39, .10),
    Offset(.62, .18),
    Offset(.86, .11),
    Offset(.94, .31),
    Offset(.11, .48),
    Offset(.88, .52),
    Offset(.06, .72),
    Offset(.25, .84),
    Offset(.53, .76),
    Offset(.76, .88),
    Offset(.95, .70),
  ];

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: IgnorePointer(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final phase = reducedMotion ? 0.0 : animation.value * math.pi * 2;
          return LayoutBuilder(
            builder: (context, constraints) => Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _IslamicPatternPainter(dark: dark),
                  ),
                ),
                ...List.generate(_points.length, (index) {
                  final point = _points[index];
                  final driftX = math.sin(phase + index * .71) * 9;
                  final driftY = math.cos(phase * .72 + index) * 13;
                  final size = 4.0 + (index % 3) * 2.5;
                  return Positioned(
                    left: point.dx * constraints.maxWidth + driftX,
                    top: point.dy * constraints.maxHeight + driftY,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            (index.isEven
                                    ? NurrDesign.gold
                                    : NurrDesign.emerald)
                                .withValues(alpha: dark ? .35 : .25),
                        boxShadow: [
                          BoxShadow(
                            color: NurrDesign.gold.withValues(alpha: .18),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                PositionedDirectional(
                  top: 24,
                  start: 18,
                  child: Transform.rotate(
                    angle: math.sin(phase) * .08,
                    alignment: Alignment.topCenter,
                    child: _Lantern(dark: dark, small: false),
                  ),
                ),
                PositionedDirectional(
                  top: 78,
                  end: 22,
                  child: Transform.rotate(
                    angle: math.sin(phase + 1.7) * .1,
                    alignment: Alignment.topCenter,
                    child: _Lantern(dark: dark, small: true),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

class _Lantern extends StatelessWidget {
  const _Lantern({required this.dark, required this.small});
  final bool dark;
  final bool small;
  @override
  Widget build(BuildContext context) {
    final scale = small ? .72 : 1.0;
    return Opacity(
      opacity: dark ? .7 : .5,
      child: SizedBox(
        width: 38 * scale,
        height: 76 * scale,
        child: Column(
          children: [
            Container(width: 1.5, height: 24 * scale, color: NurrDesign.gold),
            Container(
              width: 34 * scale,
              height: 43 * scale,
              decoration: BoxDecoration(
                color: NurrDesign.gold.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: NurrDesign.gold, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: NurrDesign.gold.withValues(alpha: .24),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Icon(
                Icons.lightbulb_outline_rounded,
                size: 17 * scale,
                color: NurrDesign.goldDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  const _IslamicPatternPainter({required this.dark});
  final bool dark;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NurrDesign.gold.withValues(alpha: dark ? .045 : .055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const cell = 86.0;
    for (double y = -cell; y < size.height + cell; y += cell) {
      for (double x = -cell; x < size.width + cell; x += cell) {
        final center = Offset(x + cell / 2, y + cell / 2);
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(math.pi / 4);
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: 31, height: 31),
          paint,
        );
        canvas.drawCircle(Offset.zero, 15.5, paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IslamicPatternPainter oldDelegate) =>
      oldDelegate.dark != dark;
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

class MosqueSkyIllustration extends StatelessWidget {
  const MosqueSkyIllustration({
    super.key,
    required this.dark,
    required this.animation,
    this.compact = false,
  });

  final bool dark;
  final Animation<double> animation;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: compact ? 2.15 : 1.5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) => CustomPaint(
            painter: _MosqueSkyPainter(
              dark: dark,
              phase: animation.value,
              compact: compact,
            ),
          ),
        ),
      ),
    );
  }
}

class _MosqueSkyPainter extends CustomPainter {
  const _MosqueSkyPainter({
    required this.dark,
    required this.phase,
    required this.compact,
  });

  final bool dark;
  final double phase;
  final bool compact;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark
              ? const [Color(0xFF102D2A), Color(0xFF1C463E), Color(0xFF9B7132)]
              : const [Color(0xFF174C43), Color(0xFF678C73), Color(0xFFF0D79D)],
        ).createShader(rect),
    );
    final starPaint = Paint()..color = const Color(0xFFFFE8A8);
    const stars = [
      Offset(.14, .18),
      Offset(.27, .11),
      Offset(.43, .22),
      Offset(.69, .12),
      Offset(.83, .25),
      Offset(.91, .10),
    ];
    for (var i = 0; i < stars.length; i++) {
      final glow = .65 + math.sin(phase * math.pi * 2 + i) * .25;
      canvas.drawCircle(
        Offset(stars[i].dx * size.width, stars[i].dy * size.height),
        (i.isEven ? 2.1 : 1.4) * glow,
        starPaint,
      );
    }
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: .12);
    for (var i = 0; i < 2; i++) {
      final cloudX = ((phase + i * .52) % 1.25) * size.width - size.width * .18;
      final cloudY = size.height * (.32 + i * .14);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cloudX, cloudY),
          width: size.width * .22,
          height: size.height * .055,
        ),
        cloudPaint,
      );
      canvas.drawCircle(
        Offset(cloudX - size.width * .045, cloudY - size.height * .016),
        size.height * .032,
        cloudPaint,
      );
    }
    final moonCenter = Offset(size.width * .77, size.height * .28);
    canvas.drawCircle(
      moonCenter,
      size.shortestSide * .09,
      Paint()..color = const Color(0xFFFFE8A8),
    );
    canvas.drawCircle(
      moonCenter.translate(size.shortestSide * .035, -size.shortestSide * .018),
      size.shortestSide * .085,
      Paint()..color = dark ? const Color(0xFF163831) : const Color(0xFF315F50),
    );

    final ground = size.height * (compact ? .77 : .72);
    final silhouette = Paint()..color = const Color(0xFF123A34);
    canvas.drawRect(
      Rect.fromLTRB(0, ground, size.width, size.height),
      silhouette,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .29,
        ground - size.height * .18,
        size.width * .42,
        size.height * .2,
      ),
      silhouette,
    );
    canvas.drawCircle(
      Offset(size.width * .5, ground - size.height * .18),
      size.width * .105,
      silhouette,
    );
    for (final x in [.23, .77]) {
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * (x - .025),
          ground - size.height * .28,
          size.width * .05,
          size.height * .3,
        ),
        silhouette,
      );
      final path = Path()
        ..moveTo(size.width * (x - .045), ground - size.height * .28)
        ..lineTo(size.width * x, ground - size.height * .39)
        ..lineTo(size.width * (x + .045), ground - size.height * .28)
        ..close();
      canvas.drawPath(path, silhouette);
    }
    final windowPaint = Paint()
      ..color = const Color(
        0xFFFFD875,
      ).withValues(alpha: .55 + math.sin(phase * math.pi * 2).abs() * .35);
    for (final x in [.38, .5, .62]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width * x, ground - size.height * .07),
            width: size.width * .035,
            height: size.height * .07,
          ),
          const Radius.circular(8),
        ),
        windowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MosqueSkyPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.dark != dark;
}
