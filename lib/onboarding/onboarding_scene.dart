import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../nurr_design.dart';

/// Decorative vector artwork shared by the introduction screens.
///
/// Animation repaints the canvas without rebuilding its surrounding content.
/// The book intentionally contains ornaments only, never simulated scripture.
class OnboardingScene extends StatefulWidget {
  final bool dark;
  final Animation<double> animation;
  final String scene;
  final int selectedPrayer;

  const OnboardingScene({
    super.key,
    required this.dark,
    required this.animation,
    required this.scene,
    this.selectedPrayer = 3,
  });

  @override
  State<OnboardingScene> createState() => _OnboardingSceneState();
}

class _OnboardingSceneState extends State<OnboardingScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _prayerController;
  late Animation<double> _prayer;
  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();
    _prayerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: 1,
    );
    _prayer = AlwaysStoppedAnimation(
      widget.selectedPrayer.clamp(0, 4).toDouble(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion =
        MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context);
    if (_reducedMotion) _prayerController.value = 1;
  }

  @override
  void didUpdateWidget(covariant OnboardingScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPrayer != widget.selectedPrayer) {
      _prayer =
          Tween<double>(
                begin: _prayer.value,
                end: widget.selectedPrayer.clamp(0, 4).toDouble(),
              )
              .chain(CurveTween(curve: Curves.easeInOutCubic))
              .animate(_prayerController);
      if (_reducedMotion) {
        _prayerController.value = 1;
      } else {
        _prayerController.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _prayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: AspectRatio(
          aspectRatio: 400 / 260,
          child: CustomPaint(
            painter: _ScenePainter(
              dark: widget.dark,
              animation: widget.animation,
              scene: widget.scene,
              prayer: _prayer,
              reducedMotion: _reducedMotion,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  final bool dark;
  final Animation<double> animation;
  final String scene;
  final Animation<double> prayer;
  final bool reducedMotion;

  _ScenePainter({
    required this.dark,
    required this.animation,
    required this.scene,
    required this.prayer,
    required this.reducedMotion,
  }) : super(
         repaint: reducedMotion ? null : Listenable.merge([animation, prayer]),
       );

  double get phase => (reducedMotion ? .18 : animation.value) * math.pi * 2;
  Color get surface => NurrDesign.surface(dark);
  Color get quietGold => NurrDesign.gold.withValues(alpha: dark ? .22 : .16);

  Paint _fill(Color color) => Paint()..color = color;
  Paint _line(Color color, [double width = 1]) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = width;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 400, size.height / 260);
    canvas.save();
    canvas.translate(
      (size.width - 400 * scale) / 2,
      (size.height - 260 * scale) / 2,
    );
    canvas.scale(scale);
    switch (scene) {
      case 'quran':
        _quran(canvas);
      case 'prayer':
        _prayerSky(canvas);
      case 'location':
        _location(canvas);
      case 'ready':
        _ready(canvas);
      default:
        _welcome(canvas);
    }
    canvas.restore();
  }

  void _halo(
    Canvas canvas,
    Offset center,
    double radius, {
    double strength = 1,
  }) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            NurrDesign.gold.withValues(alpha: (dark ? .19 : .14) * strength),
            NurrDesign.gold.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  Path _arch(Rect bounds) {
    final middle = bounds.center.dx;
    return Path()
      ..moveTo(bounds.left, bounds.bottom)
      ..lineTo(bounds.left, bounds.top + bounds.height * .48)
      ..cubicTo(
        bounds.left,
        bounds.top + bounds.height * .22,
        middle - bounds.width * .16,
        bounds.top + bounds.height * .16,
        middle,
        bounds.top,
      )
      ..cubicTo(
        middle + bounds.width * .16,
        bounds.top + bounds.height * .16,
        bounds.right,
        bounds.top + bounds.height * .22,
        bounds.right,
        bounds.top + bounds.height * .48,
      )
      ..lineTo(bounds.right, bounds.bottom)
      ..close();
  }

  void _crescent(
    Canvas canvas,
    Offset center,
    double radius, {
    double opacity = 1,
  }) {
    final outer = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    final inner = Path()
      ..addOval(
        Rect.fromCircle(
          center: center + Offset(radius * .43, -radius * .25),
          radius: radius * .9,
        ),
      );
    final moon = Path.combine(PathOperation.difference, outer, inner);
    canvas.drawShadow(
      moon,
      NurrDesign.goldDark.withValues(alpha: .16 * opacity),
      5,
      true,
    );
    canvas.drawPath(
      moon,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(
              NurrDesign.paper,
              NurrDesign.gold,
              .47,
            )!.withValues(alpha: opacity),
            NurrDesign.gold.withValues(alpha: opacity),
            NurrDesign.goldDark.withValues(alpha: opacity),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  void _star(Canvas canvas, Offset center, double radius, double opacity) {
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(
        center.dx + radius * .17,
        center.dy - radius * .17,
        center.dx + radius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx + radius * .17,
        center.dy + radius * .17,
        center.dx,
        center.dy + radius,
      )
      ..quadraticBezierTo(
        center.dx - radius * .17,
        center.dy + radius * .17,
        center.dx - radius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx - radius * .17,
        center.dy - radius * .17,
        center.dx,
        center.dy - radius,
      )
      ..close();
    canvas.drawPath(path, _fill(NurrDesign.gold.withValues(alpha: opacity)));
  }

  void _sparkles(Canvas canvas, {double opacity = 1}) {
    const points = [
      Offset(62, 87),
      Offset(325, 63),
      Offset(342, 161),
      Offset(97, 36),
      Offset(281, 26),
    ];
    for (var i = 0; i < points.length; i++) {
      final light = .4 + .28 * (1 + math.sin(phase + i * 1.7)) / 2;
      _star(
        canvas,
        points[i] + Offset(0, math.sin(phase + i) * 2),
        i.isEven ? 4 : 2.8,
        light * opacity,
      );
    }
  }

  void _mosque(
    Canvas canvas,
    Offset base,
    double width,
    Color color, {
    double windowLight = .6,
  }) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.scale(width / 160);
    final building = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-52, -41, 104, 41),
          const Radius.circular(2),
        ),
      )
      ..addRect(const Rect.fromLTWH(-70, -25, 25, 25))
      ..addRect(const Rect.fromLTWH(45, -25, 25, 25));
    final dome = Path()
      ..moveTo(-44, -41)
      ..cubicTo(-43, -65, -17, -66, 0, -88)
      ..cubicTo(17, -66, 43, -65, 44, -41)
      ..close();
    building.addPath(dome, Offset.zero);
    for (final x in [-64.0, 64.0]) {
      building.addPath(
        Path()
          ..moveTo(x - 4, 0)
          ..lineTo(x - 4, -72)
          ..lineTo(x - 6, -72)
          ..lineTo(x - 6, -77)
          ..lineTo(x - 3, -77)
          ..lineTo(x - 3, -98)
          ..lineTo(x, -105)
          ..lineTo(x + 3, -98)
          ..lineTo(x + 3, -77)
          ..lineTo(x + 6, -77)
          ..lineTo(x + 6, -72)
          ..lineTo(x + 4, -72)
          ..lineTo(x + 4, 0)
          ..close(),
        Offset.zero,
      );
    }
    canvas.drawPath(building, _fill(color));
    canvas.drawPath(dome, _line(NurrDesign.gold.withValues(alpha: .36), .85));
    canvas.drawLine(
      const Offset(0, -88),
      const Offset(0, -98),
      _line(NurrDesign.gold.withValues(alpha: .8), 1),
    );
    canvas.drawCircle(const Offset(0, -100), 1.5, _fill(NurrDesign.gold));
    for (final x in [-33.0, -19.0, 19.0, 33.0]) {
      final window = _arch(Rect.fromLTWH(x - 3, -30, 6, 17));
      canvas.drawPath(
        window,
        _fill(NurrDesign.gold.withValues(alpha: windowLight)),
      );
    }
    canvas.drawPath(
      _arch(const Rect.fromLTWH(-9, -26, 18, 26)),
      _fill(Color.lerp(color, NurrDesign.ink, .35)!),
    );
    canvas.drawPath(
      _arch(const Rect.fromLTWH(-9, -26, 18, 26)),
      _line(NurrDesign.gold.withValues(alpha: .45), .8),
    );
    canvas.drawLine(
      const Offset(-52, -40),
      const Offset(52, -40),
      _line(NurrDesign.gold.withValues(alpha: .4), .75),
    );
    canvas.restore();
  }

  void _welcome(Canvas canvas) {
    _halo(canvas, const Offset(200, 130), 139);
    final frame = _arch(const Rect.fromLTWH(78, 15, 244, 220));
    canvas.drawShadow(
      frame,
      NurrDesign.ink.withValues(alpha: dark ? .3 : .13),
      9,
      true,
    );
    canvas.drawPath(
      frame,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark
              ? [
                  Color.lerp(NurrDesign.emerald, NurrDesign.ink, .5)!,
                  NurrDesign.emerald,
                ]
              : [
                  Color.lerp(NurrDesign.cream, NurrDesign.gold, .09)!,
                  Color.lerp(NurrDesign.cream, NurrDesign.gold, .23)!,
                ],
        ).createShader(const Rect.fromLTWH(78, 15, 244, 220)),
    );
    canvas.save();
    canvas.clipPath(frame);
    _halo(canvas, const Offset(245, 110), 104, strength: 1.4);
    _crescent(canvas, Offset(251, 80 + math.sin(phase) * 2), 23);
    for (var i = 0; i < 6; i++) {
      final x = 110 + i * 30.0;
      final y = 88 + math.sin(i * 2.1) * 28;
      canvas.drawCircle(
        Offset(x, y),
        i.isEven ? 1.1 : .65,
        _fill(
          NurrDesign.gold.withValues(
            alpha: .36 + .22 * (math.sin(phase + i) + 1) / 2,
          ),
        ),
      );
    }
    final distant = Path()
      ..moveTo(60, 208)
      ..cubicTo(130, 158, 185, 203, 238, 180)
      ..cubicTo(292, 159, 320, 188, 346, 180)
      ..lineTo(346, 248)
      ..lineTo(60, 248)
      ..close();
    canvas.drawPath(
      distant,
      _fill(NurrDesign.emerald.withValues(alpha: dark ? .7 : .11)),
    );
    _mosque(
      canvas,
      const Offset(127, 208),
      79,
      Color.lerp(surface, NurrDesign.emerald, dark ? .8 : .26)!,
      windowLight: .15,
    );
    _mosque(
      canvas,
      const Offset(239, 221),
      150,
      NurrDesign.emerald,
      windowLight: dark ? .85 : .58,
    );
    canvas.drawRect(
      const Rect.fromLTWH(70, 221, 260, 30),
      _fill(Color.lerp(NurrDesign.emerald, NurrDesign.ink, .16)!),
    );
    canvas.restore();
    canvas.drawPath(frame, _line(NurrDesign.gold.withValues(alpha: .66), 1.15));
    canvas.drawPath(
      _arch(const Rect.fromLTWH(69, 6, 262, 236)),
      _line(quietGold, .85),
    );
    for (var i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(72 - i * 13.0, 234 + i * 5.0, 256 + i * 26.0, 5),
          const Radius.circular(2),
        ),
        _fill(Color.lerp(surface, NurrDesign.gold, .10 + i * .025)!),
      );
    }
    _sparkles(canvas, opacity: .8);
  }

  void _quran(Canvas canvas) {
    _halo(canvas, const Offset(200, 122), 142, strength: 1.15);
    canvas.drawPath(
      _arch(const Rect.fromLTWH(102, 10, 196, 218)),
      _line(quietGold, 1),
    );
    canvas.drawOval(
      const Rect.fromLTWH(88, 231, 226, 15),
      _fill(NurrDesign.ink.withValues(alpha: dark ? .22 : .055)),
    );
    // Interlocking book stand, drawn behind the open volume.
    final stand = Path()
      ..moveTo(145, 237)
      ..lineTo(181, 177)
      ..lineTo(194, 182)
      ..lineTo(159, 241)
      ..close()
      ..moveTo(255, 237)
      ..lineTo(219, 177)
      ..lineTo(206, 182)
      ..lineTo(241, 241)
      ..close();
    canvas.drawPath(stand, _fill(NurrDesign.emerald));
    canvas.drawLine(
      const Offset(152, 237),
      const Offset(187, 183),
      _line(NurrDesign.gold.withValues(alpha: .72), 1),
    );
    canvas.drawLine(
      const Offset(248, 237),
      const Offset(213, 183),
      _line(NurrDesign.gold.withValues(alpha: .72), 1),
    );
    canvas.save();
    canvas.translate(200, 140 + math.sin(phase) * 2.4);
    canvas.rotate(math.sin(phase) * .008);
    canvas.translate(-200, -140);
    final cover = Path()
      ..moveTo(200, 92)
      ..cubicTo(159, 73, 119, 68, 77, 73)
      ..lineTo(64, 184)
      ..cubicTo(111, 181, 159, 195, 200, 217)
      ..cubicTo(241, 195, 289, 181, 336, 184)
      ..lineTo(323, 73)
      ..cubicTo(281, 68, 241, 73, 200, 92)
      ..close();
    canvas.drawShadow(cover, NurrDesign.ink.withValues(alpha: .22), 7, true);
    canvas.drawPath(cover, _fill(NurrDesign.emerald));
    canvas.drawPath(cover, _line(NurrDesign.gold, 1.5));
    for (final right in [false, true]) {
      canvas.save();
      if (right) {
        canvas.translate(400, 0);
        canvas.scale(-1, 1);
      }
      final page = Path()
        ..moveTo(198, 94)
        ..cubicTo(164, 76, 121, 68, 84, 72)
        ..lineTo(73, 178)
        ..cubicTo(116, 177, 162, 190, 198, 209)
        ..close();
      canvas.drawPath(
        page,
        Paint()
          ..shader = LinearGradient(
            colors: [
              NurrDesign.paper,
              NurrDesign.cream,
              Color.lerp(NurrDesign.cream, NurrDesign.gold, .18)!,
            ],
          ).createShader(const Rect.fromLTWH(73, 72, 125, 137)),
      );
      final inset = Path()
        ..moveTo(187, 101)
        ..cubicTo(157, 86, 126, 80, 95, 82)
        ..lineTo(87, 168)
        ..cubicTo(122, 171, 157, 180, 187, 194)
        ..close();
      canvas.drawPath(inset, _line(NurrDesign.gold.withValues(alpha: .43), .8));
      canvas.drawPath(
        Path()
          ..moveTo(74, 184)
          ..cubicTo(112, 184, 163, 198, 197, 214),
        _line(NurrDesign.cream.withValues(alpha: .7), 1.4),
      );
      final ornament = Path()
        ..moveTo(139, 115)
        ..lineTo(151, 136)
        ..lineTo(139, 153)
        ..lineTo(127, 133)
        ..close();
      canvas.drawPath(
        ornament,
        _line(NurrDesign.gold.withValues(alpha: .52), .9),
      );
      canvas.drawCircle(
        const Offset(139, 134),
        4.5,
        _line(NurrDesign.gold.withValues(alpha: .5), .8),
      );
      canvas.drawCircle(
        const Offset(139, 134),
        1.1,
        _fill(NurrDesign.gold.withValues(alpha: .65)),
      );
      canvas.restore();
    }
    canvas.drawPath(
      Path()
        ..moveTo(200, 96)
        ..quadraticBezierTo(196, 160, 200, 211),
      _line(NurrDesign.goldDark.withValues(alpha: .4), 1.3),
    );
    final ribbon = Path()
      ..moveTo(210, 190)
      ..lineTo(217, 191)
      ..lineTo(227, 222)
      ..lineTo(220, 218)
      ..lineTo(216, 226)
      ..close();
    canvas.drawPath(ribbon, _fill(NurrDesign.gold));
    canvas.restore();
    _sparkles(canvas);
  }

  Color _prayerColor(List<Color> colors) {
    final index = prayer.value.clamp(0.0, 4.0);
    final lower = index.floor();
    return Color.lerp(
      colors[lower],
      colors[math.min(lower + 1, 4)],
      index - lower,
    )!;
  }

  void _cloud(Canvas canvas, Offset center, double width, double opacity) {
    final path = Path()
      ..moveTo(center.dx - width / 2, center.dy)
      ..cubicTo(
        center.dx - width * .4,
        center.dy - 9,
        center.dx - width * .23,
        center.dy - 7,
        center.dx - width * .13,
        center.dy - 6,
      )
      ..cubicTo(
        center.dx,
        center.dy - 18,
        center.dx + width * .24,
        center.dy - 14,
        center.dx + width * .28,
        center.dy - 5,
      )
      ..quadraticBezierTo(
        center.dx + width * .44,
        center.dy - 8,
        center.dx + width / 2,
        center.dy,
      )
      ..close();
    canvas.drawPath(path, _fill(NurrDesign.paper.withValues(alpha: opacity)));
  }

  void _prayerSky(Canvas canvas) {
    final sky = RRect.fromRectAndRadius(
      const Rect.fromLTWH(13, 27, 374, 211),
      const Radius.circular(34),
    );
    final night = (prayer.value - 2).abs().clamp(0.0, 2.0) / 2;
    final top = _prayerColor([
      Color.lerp(NurrDesign.emerald, NurrDesign.ink, .24)!,
      Color.lerp(NurrDesign.cream, NurrDesign.gold, .11)!,
      NurrDesign.cream,
      Color.lerp(NurrDesign.cream, NurrDesign.gold, .26)!,
      Color.lerp(NurrDesign.emerald, NurrDesign.darkBackground, .58)!,
    ]);
    final bottom = _prayerColor([
      Color.lerp(NurrDesign.cream, NurrDesign.gold, .28)!,
      NurrDesign.paper,
      NurrDesign.paper,
      Color.lerp(NurrDesign.cream, NurrDesign.gold, .12)!,
      Color.lerp(NurrDesign.emerald, NurrDesign.ink, .18)!,
    ]);
    canvas.drawShadow(
      Path()..addRRect(sky),
      NurrDesign.ink.withValues(alpha: .12),
      7,
      true,
    );
    canvas.save();
    canvas.clipRRect(sky);
    canvas.drawRRect(
      sky,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            dark ? Color.lerp(top, NurrDesign.darkBackground, .2)! : top,
            bottom,
          ],
        ).createShader(sky.outerRect),
    );
    final sun = Offset(
      78 + prayer.value * 57,
      117 - math.sin(prayer.value / 4 * math.pi) * 53,
    );
    _halo(canvas, sun, 70, strength: .9);
    final daylight = (1 - (prayer.value - 2).abs() / 2).clamp(0.0, 1.0);
    canvas.drawCircle(
      sun,
      15,
      _fill(
        Color.lerp(
          NurrDesign.paper,
          NurrDesign.gold,
          .36,
        )!.withValues(alpha: daylight),
      ),
    );
    if (night > 0) _crescent(canvas, const Offset(312, 72), 15, opacity: night);
    for (var i = 0; i < 14; i++) {
      final x = 40.0 + (i * 67) % 326;
      final y = 44.0 + (i * 31) % 71;
      canvas.drawCircle(
        Offset(x, y),
        i % 3 == 0 ? 1.1 : .65,
        _fill(
          NurrDesign.paper.withValues(
            alpha: night * (.28 + .28 * (1 + math.sin(phase + i)) / 2),
          ),
        ),
      );
    }
    _cloud(
      canvas,
      Offset(102 + math.sin(phase) * 7, 92),
      89,
      .22 * (1 - night * .7),
    );
    _cloud(
      canvas,
      Offset(275 - math.sin(phase) * 5, 115),
      74,
      .3 * (1 - night * .7),
    );
    final hills = Path()
      ..moveTo(0, 190)
      ..cubicTo(105, 146, 119, 199, 209, 163)
      ..cubicTo(270, 139, 327, 177, 410, 162)
      ..lineTo(410, 248)
      ..lineTo(0, 248)
      ..close();
    canvas.drawPath(
      hills,
      _fill(NurrDesign.emerald.withValues(alpha: .14 + night * .2)),
    );
    _mosque(
      canvas,
      const Offset(94, 218),
      86,
      Color.lerp(bottom, NurrDesign.emerald, .37)!,
      windowLight: .2,
    );
    _mosque(
      canvas,
      const Offset(248, 225),
      168,
      NurrDesign.emerald,
      windowLight: .35 + night * .6,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, 232)
        ..quadraticBezierTo(170, 211, 400, 228)
        ..lineTo(400, 270)
        ..lineTo(0, 270)
        ..close(),
      _fill(Color.lerp(NurrDesign.emerald, NurrDesign.ink, .15)!),
    );
    canvas.restore();
    canvas.drawRRect(sky, _line(NurrDesign.gold.withValues(alpha: .36), 1));
    canvas.drawLine(
      const Offset(173, 250),
      const Offset(227, 250),
      _line(quietGold, 1),
    );
    _star(canvas, const Offset(200, 250), 3.5, .68);
  }

  void _location(Canvas canvas) {
    _halo(canvas, const Offset(208, 132), 140);
    canvas.drawPath(
      _arch(const Rect.fromLTWH(108, 9, 183, 208)),
      _line(quietGold, 1),
    );
    canvas.save();
    canvas.translate(200, 160);
    canvas.rotate(-.055);
    canvas.translate(-200, -160);
    final map = RRect.fromRectAndRadius(
      const Rect.fromLTWH(33, 76, 334, 164),
      const Radius.circular(26),
    );
    canvas.drawShadow(
      Path()..addRRect(map),
      NurrDesign.ink.withValues(alpha: .17),
      10,
      true,
    );
    canvas.drawRRect(map, _fill(surface));
    canvas.save();
    canvas.clipRRect(map);
    const blocks = [
      Rect.fromLTWH(43, 86, 67, 34),
      Rect.fromLTWH(125, 88, 58, 27),
      Rect.fromLTWH(211, 86, 77, 41),
      Rect.fromLTWH(305, 89, 62, 45),
      Rect.fromLTWH(57, 139, 49, 46),
      Rect.fromLTWH(143, 153, 65, 33),
      Rect.fromLTWH(258, 161, 83, 28),
      Rect.fromLTWH(48, 208, 73, 27),
      Rect.fromLTWH(151, 207, 49, 29),
      Rect.fromLTWH(223, 212, 99, 28),
    ];
    for (var i = 0; i < blocks.length; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(blocks[i], const Radius.circular(7)),
        _fill(
          (i % 3 == 0 ? NurrDesign.emerald : NurrDesign.gold).withValues(
            alpha: dark ? .15 : .065,
          ),
        ),
      );
    }
    final avenue = Path()
      ..moveTo(23, 127)
      ..cubicTo(133, 128, 162, 123, 213, 143)
      ..cubicTo(262, 162, 307, 137, 383, 149);
    canvas.drawPath(avenue, _line(NurrDesign.gold.withValues(alpha: .12), 11));
    final route = Path()
      ..moveTo(113, 203)
      ..cubicTo(110, 172, 175, 206, 202, 177)
      ..cubicTo(224, 151, 239, 148, 275, 151);
    canvas.drawPath(route, _line(NurrDesign.gold.withValues(alpha: .13), 8));
    final metric = route.computeMetrics().first;
    for (double distance = 0; distance < metric.length; distance += 10) {
      final tangent = metric.getTangentForOffset(distance);
      if (tangent != null) {
        canvas.drawCircle(
          tangent.position,
          1.65,
          _fill(NurrDesign.gold.withValues(alpha: .72)),
        );
      }
    }
    final pulse = metric.getTangentForOffset(
      metric.length * (reducedMotion ? .6 : animation.value),
    );
    if (pulse != null) {
      canvas.drawCircle(
        pulse.position,
        5,
        _fill(NurrDesign.gold.withValues(alpha: .18)),
      );
      canvas.drawCircle(pulse.position, 2.8, _fill(NurrDesign.gold));
    }
    canvas.drawCircle(const Offset(113, 203), 5, _fill(NurrDesign.emerald));
    canvas.drawCircle(const Offset(113, 203), 2.3, _fill(NurrDesign.paper));
    canvas.restore();
    canvas.drawRRect(map, _line(NurrDesign.gold.withValues(alpha: .24), 1));
    _mosque(
      canvas,
      const Offset(277, 150),
      88,
      NurrDesign.emerald,
      windowLight: .74,
    );
    canvas.restore();
    final bob = math.sin(phase) * 3;
    canvas.drawOval(
      const Rect.fromLTWH(109, 148, 38, 8),
      _fill(NurrDesign.ink.withValues(alpha: .065)),
    );
    final pin = Path()
      ..moveTo(128, 151 + bob)
      ..cubicTo(120, 138 + bob, 103, 119 + bob, 103, 102 + bob)
      ..cubicTo(103, 69 + bob, 153, 69 + bob, 153, 102 + bob)
      ..cubicTo(153, 119 + bob, 136, 138 + bob, 128, 151 + bob)
      ..close();
    canvas.drawShadow(pin, NurrDesign.goldDark.withValues(alpha: .2), 6, true);
    canvas.drawPath(
      pin,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [NurrDesign.gold, NurrDesign.goldDark],
        ).createShader(Rect.fromLTWH(103, 77 + bob, 50, 74)),
    );
    canvas.drawCircle(Offset(128, 102 + bob), 12.5, _fill(NurrDesign.paper));
    canvas.drawCircle(Offset(128, 102 + bob), 5, _fill(NurrDesign.emerald));
    _sparkles(canvas, opacity: .65);
  }

  void _ready(Canvas canvas) {
    final breath = (1 + math.sin(phase)) / 2;
    _halo(canvas, const Offset(200, 117), 136, strength: 1 + breath * .18);
    canvas.drawPath(
      _arch(const Rect.fromLTWH(99, 8, 202, 227)),
      _line(quietGold, .85),
    );
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        const Offset(200, 117),
        66 + i * 18.0 + breath * (i + 1),
        _line(
          NurrDesign.gold.withValues(alpha: (dark ? .16 : .12) - i * .025),
          .8,
        ),
      );
    }
    canvas.save();
    canvas.translate(200, 117 + math.sin(phase) * 1.6);
    canvas.rotate(-.18);
    _crescent(canvas, Offset.zero, 49);
    canvas.restore();
    _star(canvas, const Offset(218, 111), 10, .84);
    _star(canvas, const Offset(231, 87), 4, .57 + breath * .2);
    final path = Path()
      ..moveTo(94, 247)
      ..cubicTo(105, 214, 161, 233, 181, 213)
      ..quadraticBezierTo(201, 195, 200, 179);
    canvas.drawPath(path, _line(NurrDesign.gold.withValues(alpha: .09), 10));
    canvas.drawPath(path, _line(NurrDesign.gold.withValues(alpha: .34), .85));
    final metric = path.computeMetrics().first;
    for (var i = 0; i < 7; i++) {
      final position = metric
          .getTangentForOffset(metric.length * (i + .5) / 7)!
          .position;
      final opacity = .25 + .33 * (1 + math.sin(phase - i * .7)) / 2;
      canvas.drawCircle(
        position,
        2,
        _fill(NurrDesign.gold.withValues(alpha: opacity)),
      );
    }
    _sparkles(canvas);
  }

  @override
  bool shouldRepaint(covariant _ScenePainter oldDelegate) =>
      oldDelegate.dark != dark ||
      oldDelegate.animation != animation ||
      oldDelegate.scene != scene ||
      oldDelegate.prayer != prayer ||
      oldDelegate.reducedMotion != reducedMotion;
}
