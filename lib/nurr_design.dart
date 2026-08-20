import 'package:flutter/material.dart';

abstract final class NurrDesign {
  static final ValueNotifier<bool> darkMode = ValueNotifier<bool>(false);
  static const gold = Color(0xFFC79A3B);
  static const goldDark = Color(0xFF8E6823);
  static const emerald = Color(0xFF174C43);
  static const cream = Color(0xFFF8F4EA);
  static const paper = Color(0xFFFFFDF8);
  static const ink = Color(0xFF24211C);
  static const muted = Color(0xFF746E63);
  static const darkBackground = Color(0xFF0F0F0F);
  static const darkSurface = Color(0xFF191919);
  static const darkMuted = Color(0xFFB8B1A5);

  static Color background(bool dark) => dark ? darkBackground : cream;
  static Color surface(bool dark) => dark ? darkSurface : paper;
  static Color text(bool dark) => dark ? Colors.white : ink;
  static Color secondaryText(bool dark) => dark ? darkMuted : muted;

  static BoxDecoration card({Color color = paper}) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: gold.withValues(alpha: 0.18)),
    boxShadow: const [
      BoxShadow(color: Color(0x12000000), blurRadius: 22, offset: Offset(0, 8)),
    ],
  );
}
