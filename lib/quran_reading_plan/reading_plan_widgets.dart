import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../nurr_design.dart';

String readingPlanText(String language, String de, String en, String ar) =>
    language == 'ar' ? ar : (language == 'en' ? en : de);

Duration readingPlanDuration(BuildContext context, [int milliseconds = 550]) =>
    MediaQuery.disableAnimationsOf(context)
    ? Duration.zero
    : Duration(milliseconds: milliseconds);

class ReadingPlanSurface extends StatelessWidget {
  const ReadingPlanSurface({
    super.key,
    required this.darkMode,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.accent = false,
  });

  final bool darkMode;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool accent;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: accent
          ? Color.alphaBlend(
              NurrDesign.gold.withValues(alpha: darkMode ? .10 : .08),
              NurrDesign.surface(darkMode),
            )
          : NurrDesign.surface(darkMode),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(
        color: NurrDesign.gold.withValues(alpha: accent ? .28 : .14),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: darkMode ? .08 : .035),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: child,
  );
}

/// A small pressed state, shared by the primary actions and choice cards.
class ReadingPlanPress extends StatefulWidget {
  const ReadingPlanPress({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = 22,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;

  @override
  State<ReadingPlanPress> createState() => _ReadingPlanPressState();
}

class _ReadingPlanPressState extends State<ReadingPlanPress> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => AnimatedScale(
    scale: _pressed ? .98 : 1,
    duration: readingPlanDuration(context, 160),
    curve: Curves.easeOutCubic,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        onTap: widget.onTap,
        onHighlightChanged: (value) => setState(() => _pressed = value),
        child: widget.child,
      ),
    ),
  );
}

class ReadingPlanButton extends StatelessWidget {
  const ReadingPlanButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.darkMode,
    this.icon = Icons.arrow_forward_rounded,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool darkMode;
  final IconData icon;
  final bool busy;

  @override
  Widget build(BuildContext context) => ReadingPlanPress(
    onTap: busy ? null : onPressed,
    child: Ink(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: darkMode ? NurrDesign.gold : NurrDesign.emerald,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (busy)
            SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: darkMode ? NurrDesign.ink : Colors.white,
              ),
            )
          else
            Icon(
              icon,
              size: 21,
              color: darkMode ? NurrDesign.ink : Colors.white,
            ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: darkMode ? NurrDesign.ink : Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class ReadingPlanProgressRing extends StatelessWidget {
  const ReadingPlanProgressRing({
    super.key,
    required this.value,
    required this.darkMode,
    required this.child,
    this.size = 160,
  });

  final double value;
  final bool darkMode;
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: value.clamp(0, 1)),
    duration: readingPlanDuration(context, 650),
    curve: Curves.easeOutCubic,
    child: child,
    builder: (context, progress, child) => CustomPaint(
      painter: _ProgressPainter(progress, darkMode),
      child: SizedBox.square(
        dimension: size,
        child: Padding(padding: const EdgeInsets.all(24), child: child),
      ),
    ),
  );
}

class _ProgressPainter extends CustomPainter {
  const _ProgressPainter(this.progress, this.darkMode);
  final double progress;
  final bool darkMode;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(
      center,
      radius,
      paint..color = NurrDesign.gold.withValues(alpha: .12),
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: [
            darkMode ? NurrDesign.gold : NurrDesign.emerald,
            NurrDesign.gold,
          ],
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(rect),
    );
    if (progress > 0) {
      final angle = -math.pi / 2 + 2 * math.pi * progress;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas.drawCircle(
        point,
        9,
        Paint()..color = NurrDesign.gold.withValues(alpha: .13),
      );
      canvas.drawCircle(point, 4.5, Paint()..color = NurrDesign.gold);
    }
  }

  @override
  bool shouldRepaint(_ProgressPainter oldDelegate) =>
      progress != oldDelegate.progress || darkMode != oldDelegate.darkMode;
}

/// Vector artwork: a book resting in an architectural arch. No Quran text is
/// used as decoration. Only this isolated painter repaints for the slow motion.
class ReadingPlanArtwork extends StatefulWidget {
  const ReadingPlanArtwork({super.key, required this.darkMode});

  final bool darkMode;

  @override
  State<ReadingPlanArtwork> createState() => _ReadingPlanArtworkState();
}

class _ReadingPlanArtworkState extends State<ReadingPlanArtwork>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) || !TickerMode.of(context)) {
      _motion.stop();
    } else if (!_motion.isAnimating) {
      _motion.repeat();
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RepaintBoundary(
      child: CustomPaint(
        painter: _ReadingPlanArtworkPainter(_motion, widget.darkMode),
        child: const AspectRatio(aspectRatio: 1.6),
      ),
    ),
  );
}

class _ReadingPlanArtworkPainter extends CustomPainter {
  _ReadingPlanArtworkPainter(this.motion, this.darkMode)
    : super(repaint: motion);

  final Animation<double> motion;
  final bool darkMode;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 400, size.height / 250);
    final wave = math.sin(motion.value * math.pi * 2);
    final gold = NurrDesign.gold;
    final arch = Path()
      ..moveTo(113, 210)
      ..lineTo(113, 108)
      ..cubicTo(113, 65, 166, 42, 200, 18)
      ..cubicTo(234, 42, 287, 65, 287, 108)
      ..lineTo(287, 210)
      ..close();
    canvas.drawPath(
      arch,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: darkMode
              ? [const Color(0xFF203B33), const Color(0xFF17251F)]
              : [const Color(0xFFE2EADC), const Color(0xFFF3E8CD)],
        ).createShader(const Rect.fromLTWH(100, 18, 200, 192)),
    );
    canvas.drawPath(
      arch,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = gold.withValues(alpha: .3),
    );
    canvas.drawOval(
      const Rect.fromLTWH(77, 204, 246, 18),
      Paint()..color = gold.withValues(alpha: darkMode ? .1 : .14),
    );
    for (var i = 0; i < 7; i++) {
      final angle = (i / 7) * math.pi * 2 + .25;
      final point = Offset(
        200 + math.cos(angle) * (130 + (i % 2) * 15),
        123 + math.sin(angle) * 78 + wave * (i.isEven ? 3 : -3),
      );
      final opacity =
          .2 + .35 * ((math.sin(motion.value * math.pi * 2 + i) + 1) / 2);
      _star(canvas, point, i.isEven ? 4 : 2.5, gold.withValues(alpha: opacity));
    }
    final crescent = Path.combine(
      PathOperation.difference,
      Path()..addOval(
        Rect.fromCircle(center: Offset(218, 66 + wave * 1.8), radius: 14),
      ),
      Path()..addOval(
        Rect.fromCircle(center: Offset(225, 61 + wave * 1.8), radius: 13),
      ),
    );
    canvas.drawPath(crescent, Paint()..color = gold);
    final linePaint = Paint()
      ..color = gold.withValues(alpha: .35)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      const Rect.fromLTWH(50, 130, 300, 92),
      .15,
      2.7,
      false,
      linePaint,
    );
    canvas.save();
    canvas.translate(0, wave * 2);
    // The book stand and covers, shared across every animation frame.
    final stand = Paint()
      ..color = darkMode ? const Color(0xFFBA914A) : NurrDesign.goldDark
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(170, 172), const Offset(226, 207), stand);
    canvas.drawLine(const Offset(230, 172), const Offset(174, 207), stand);
    final leftCover = Path()
      ..moveTo(104, 145)
      ..quadraticBezierTo(149, 133, 200, 158)
      ..lineTo(200, 186)
      ..quadraticBezierTo(149, 163, 107, 174)
      ..close();
    final rightCover = Path()
      ..moveTo(296, 145)
      ..quadraticBezierTo(251, 133, 200, 158)
      ..lineTo(200, 186)
      ..quadraticBezierTo(251, 163, 293, 174)
      ..close();
    for (final path in [leftCover, rightCover]) {
      canvas.drawPath(path, Paint()..color = NurrDesign.emerald);
      canvas.drawPath(path, linePaint..color = gold);
    }
    final leftPage = Path()
      ..moveTo(112, 134)
      ..quadraticBezierTo(160, 126, 200, 152)
      ..lineTo(200, 177)
      ..quadraticBezierTo(152, 153, 113, 164)
      ..close();
    final rightPage = Path()
      ..moveTo(288, 134)
      ..quadraticBezierTo(240, 126, 200, 152)
      ..lineTo(200, 177)
      ..quadraticBezierTo(248, 153, 287, 164)
      ..close();
    canvas.drawPath(leftPage, Paint()..color = const Color(0xFFFFFDF5));
    canvas.drawPath(rightPage, Paint()..color = const Color(0xFFF1E7D1));
    // Simple inset page borders, not simulated scripture or distorted text.
    for (final side in [-1.0, 1.0]) {
      final border = Path()
        ..moveTo(200 + side * 12, 154)
        ..quadraticBezierTo(200 + side * 44, 139, 200 + side * 75, 143)
        ..lineTo(200 + side * 74, 156)
        ..quadraticBezierTo(200 + side * 42, 153, 200 + side * 12, 166);
      canvas.drawPath(border, linePaint..color = gold.withValues(alpha: .45));
    }
    canvas.drawLine(
      const Offset(200, 153),
      const Offset(200, 176),
      Paint()..color = NurrDesign.goldDark.withValues(alpha: .4),
    );
    final bookmark = Path()
      ..moveTo(247, 157)
      ..lineTo(247, 179)
      ..lineTo(254, 173)
      ..lineTo(261, 179)
      ..lineTo(261, 154)
      ..close();
    canvas.drawPath(bookmark, Paint()..color = gold);
    canvas.restore();
    canvas.restore();
  }

  void _star(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(
        center.dx + radius * .2,
        center.dy - radius * .2,
        center.dx + radius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx + radius * .2,
        center.dy + radius * .2,
        center.dx,
        center.dy + radius,
      )
      ..quadraticBezierTo(
        center.dx - radius * .2,
        center.dy + radius * .2,
        center.dx - radius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx - radius * .2,
        center.dy - radius * .2,
        center.dx,
        center.dy - radius,
      );
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ReadingPlanArtworkPainter oldDelegate) =>
      darkMode != oldDelegate.darkMode || motion != oldDelegate.motion;
}
