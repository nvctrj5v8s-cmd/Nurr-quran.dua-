import 'package:flutter/material.dart';

import '../nurr_design.dart';

typedef OnboardingText = String Function(String de, String en, String ar);

Duration presentationDuration(BuildContext context, [int ms = 500]) =>
    MediaQuery.disableAnimationsOf(context)
    ? Duration.zero
    : Duration(milliseconds: ms);

class PresentationHeading extends StatelessWidget {
  const PresentationHeading({
    super.key,
    required this.dark,
    required this.eyebrow,
    required this.title,
    required this.description,
  });
  final bool dark;
  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        eyebrow,
        style: TextStyle(
          color: dark ? NurrDesign.gold : NurrDesign.goldDark,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.6,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        title,
        style: TextStyle(
          color: NurrDesign.text(dark),
          fontSize: 33,
          height: 1.13,
          letterSpacing: -.9,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 13),
      Text(
        description,
        style: TextStyle(
          color: NurrDesign.secondaryText(dark),
          fontSize: 15,
          height: 1.55,
        ),
      ),
    ],
  );
}

class PresentationSurface extends StatelessWidget {
  const PresentationSurface({
    super.key,
    required this.dark,
    required this.child,
    this.green = false,
    this.padding = const EdgeInsets.all(20),
  });
  final bool dark;
  final Widget child;
  final bool green;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: green ? NurrDesign.emerald : NurrDesign.surface(dark),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(
        color: NurrDesign.gold.withValues(alpha: green ? .36 : .18),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: dark ? .15 : .045),
          blurRadius: 26,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: child,
  );
}

class PresentationChip extends StatelessWidget {
  const PresentationChip({
    super.key,
    required this.label,
    required this.dark,
    this.icon,
    this.selected = false,
    this.onTap,
  });
  final String label;
  final bool dark;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ink = selected ? Colors.white : NurrDesign.text(dark);
    return Semantics(
      selected: selected,
      button: onTap != null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: presentationDuration(context, 300),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: selected ? NurrDesign.emerald : NurrDesign.surface(dark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? NurrDesign.gold
                    : NurrDesign.gold.withValues(alpha: .2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: selected
                        ? NurrDesign.gold
                        : (dark ? NurrDesign.gold : NurrDesign.emerald),
                    size: 17,
                  ),
                  const SizedBox(width: 7),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PresentationFeature extends StatelessWidget {
  const PresentationFeature({
    super.key,
    required this.dark,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });
  final bool dark;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: NurrDesign.gold.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: dark ? NurrDesign.gold : NurrDesign.emerald,
          size: 22,
        ),
      ),
      const SizedBox(width: 13),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: NurrDesign.text(dark),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                color: NurrDesign.secondaryText(dark),
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
      if (trailing != null) ...[const SizedBox(width: 8), trailing!],
    ],
  );
}

class PresentationPrimaryButton extends StatefulWidget {
  const PresentationPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.dark,
    this.busy = false,
    this.icon = Icons.arrow_forward_rounded,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool dark;
  final bool busy;
  final IconData icon;

  @override
  State<PresentationPrimaryButton> createState() =>
      _PresentationPrimaryButtonState();
}

class _PresentationPrimaryButtonState extends State<PresentationPrimaryButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) => AnimatedScale(
    scale: _pressed ? .98 : 1,
    duration: presentationDuration(context, 150),
    child: Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: FilledButton(
        onPressed: widget.busy ? null : widget.onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: widget.dark ? NurrDesign.gold : NurrDesign.emerald,
          foregroundColor: widget.dark ? NurrDesign.ink : Colors.white,
          disabledBackgroundColor: NurrDesign.gold.withValues(alpha: .24),
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(21),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 12),
            widget.busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(widget.icon, size: 20),
          ],
        ),
      ),
    ),
  );
}

/// An explicitly labelled example, not fabricated user activity.
class OnboardingWeekPreview extends StatelessWidget {
  const OnboardingWeekPreview({super.key, required this.dark, required this.t});
  final bool dark;
  final OnboardingText t;

  @override
  Widget build(BuildContext context) {
    final days = t(
      'M D M D F S S',
      'M T W T F S S',
      'ن ث ر خ ج س ح',
    ).split(' ');
    return PresentationSurface(
      dark: dark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t(
                    'Eine Seite. Jeden Tag.',
                    'One page. Every day.',
                    'صفحة كل يوم.',
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: NurrDesign.text(dark),
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.eco_outlined,
                color: dark ? NurrDesign.gold : NurrDesign.emerald,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            t(
              'So könnte deine Woche aussehen · Beispiel',
              'Your week could look like this · Example',
              'هكذا قد يبدو أسبوعك · مثال',
            ),
            style: TextStyle(
              color: NurrDesign.secondaryText(dark),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              7,
              (i) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: i < 4 ? 1 : .12),
                        duration: presentationDuration(context, 450 + i * 30),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) => SizedBox(
                          height: 52,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: 8 + 40 * value,
                              decoration: BoxDecoration(
                                color: i < 4
                                    ? (i == 3
                                          ? NurrDesign.gold
                                          : NurrDesign.emerald)
                                    : NurrDesign.gold.withValues(alpha: .14),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        days[i],
                        style: TextStyle(
                          fontSize: 11,
                          color: NurrDesign.secondaryText(dark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
