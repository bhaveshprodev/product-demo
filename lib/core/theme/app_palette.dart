import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic colours that are not part of Material's [ColorScheme].
///
/// Keeping them in a [ThemeExtension] lets every widget read colours from the
/// active theme instead of hard-coding light-mode values.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.canvas,
    required this.surface,
    required this.surfaceMuted,
    required this.ink,
    required this.muted,
    required this.line,
    required this.accent,
    required this.accentSoft,
    required this.highlight,
    required this.highlightSoft,
    required this.success,
    required this.danger,
  });

  final Color canvas;
  final Color surface;
  final Color surfaceMuted;
  final Color ink;
  final Color muted;
  final Color line;
  final Color accent;
  final Color accentSoft;
  final Color highlight;
  final Color highlightSoft;
  final Color success;
  final Color danger;

  static const light = AppPalette(
    canvas: AppColors.cream,
    surface: AppColors.paper,
    surfaceMuted: Color(0xFFF1EBE0),
    ink: AppColors.ink,
    muted: AppColors.muted,
    line: Color(0xFFE5DCCD),
    accent: AppColors.clay,
    accentSoft: Color(0xFFF7E4DC),
    highlight: AppColors.forest,
    highlightSoft: Color(0xFFE1EDE6),
    success: AppColors.success,
    danger: AppColors.danger,
  );

  static const dark = AppPalette(
    canvas: Color(0xFF0D1411),
    surface: Color(0xFF151F1A),
    surfaceMuted: Color(0xFF1C2822),
    ink: Color(0xFFF1F4EF),
    muted: Color(0xFFA3B1A9),
    line: Color(0xFF2A3831),
    accent: Color(0xFFE68A70),
    accentSoft: Color(0xFF3A2621),
    highlight: Color(0xFFA8D5C0),
    highlightSoft: Color(0xFF1B322A),
    success: Color(0xFF79C6A2),
    danger: Color(0xFFF09380),
  );

  @override
  AppPalette copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceMuted,
    Color? ink,
    Color? muted,
    Color? line,
    Color? accent,
    Color? accentSoft,
    Color? highlight,
    Color? highlightSoft,
    Color? success,
    Color? danger,
  }) {
    return AppPalette(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      line: line ?? this.line,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      highlight: highlight ?? this.highlight,
      highlightSoft: highlightSoft ?? this.highlightSoft,
      success: success ?? this.success,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      line: Color.lerp(line, other.line, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      highlightSoft: Color.lerp(highlightSoft, other.highlightSoft, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

extension AppPaletteX on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
