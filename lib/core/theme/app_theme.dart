import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_palette.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light, AppPalette.light);
  static ThemeData get dark => _build(Brightness.dark, AppPalette.dark);

  static ThemeData _build(Brightness brightness, AppPalette palette) {
    final isLight = brightness == Brightness.light;
    final primary = isLight ? AppColors.forest : palette.highlight;
    final onPrimary = isLight ? Colors.white : AppColors.forestDeep;
    final secondary = isLight ? AppColors.clay : palette.accent;
    final onSecondary = isLight ? Colors.white : const Color(0xFF32150E);

    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.forest,
          brightness: brightness,
        ).copyWith(
          primary: primary,
          onPrimary: onPrimary,
          primaryContainer: palette.highlightSoft,
          onPrimaryContainer: isLight ? AppColors.forestDeep : palette.ink,
          secondary: secondary,
          onSecondary: onSecondary,
          secondaryContainer: palette.accentSoft,
          onSecondaryContainer: isLight ? AppColors.clayDeep : palette.ink,
          surface: palette.surface,
          onSurface: palette.ink,
          surfaceContainerHighest: palette.surfaceMuted,
          outline: palette.line,
          outlineVariant: palette.line,
          error: palette.danger,
          onError: Colors.white,
        );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Manrope',
      colorScheme: scheme,
    );

    final textTheme = base.textTheme
        .apply(bodyColor: palette.ink, displayColor: palette.ink)
        .copyWith(
          displayLarge: base.textTheme.displayLarge?.copyWith(
            fontFamily: 'Fraunces',
            fontWeight: FontWeight.w600,
            letterSpacing: -1.6,
            height: 1.02,
            color: palette.ink,
          ),
          displayMedium: base.textTheme.displayMedium?.copyWith(
            fontFamily: 'Fraunces',
            fontWeight: FontWeight.w600,
            letterSpacing: -1.2,
            height: 1.05,
            color: palette.ink,
          ),
          displaySmall: base.textTheme.displaySmall?.copyWith(
            fontFamily: 'Fraunces',
            fontWeight: FontWeight.w600,
            letterSpacing: -0.8,
            height: 1.1,
            color: palette.ink,
          ),
          headlineLarge: base.textTheme.headlineLarge?.copyWith(
            fontFamily: 'Fraunces',
            fontWeight: FontWeight.w600,
            letterSpacing: -0.6,
            height: 1.15,
            color: palette.ink,
          ),
          headlineMedium: base.textTheme.headlineMedium?.copyWith(
            fontFamily: 'Fraunces',
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            height: 1.2,
            color: palette.ink,
          ),
          headlineSmall: base.textTheme.headlineSmall?.copyWith(
            fontFamily: 'Fraunces',
            fontWeight: FontWeight.w600,
            height: 1.25,
            color: palette.ink,
          ),
          titleLarge: base.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: palette.ink,
          ),
          titleMedium: base.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: palette.ink,
          ),
          bodyLarge: base.textTheme.bodyLarge?.copyWith(
            height: 1.55,
            color: palette.ink,
          ),
          bodyMedium: base.textTheme.bodyMedium?.copyWith(
            height: 1.5,
            color: palette.ink,
          ),
          bodySmall: base.textTheme.bodySmall?.copyWith(
            height: 1.45,
            color: palette.muted,
          ),
          labelLarge: base.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        );

    return base.copyWith(
      scaffoldBackgroundColor: palette.canvas,
      textTheme: textTheme,
      extensions: [palette],
      canvasColor: palette.canvas,
      dividerColor: palette.line,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        foregroundColor: palette.ink,
        centerTitle: false,
        systemOverlayStyle: isLight
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: palette.line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 54),
          backgroundColor: primary,
          foregroundColor: onPrimary,
          disabledBackgroundColor: primary.withValues(alpha: 0.45),
          disabledForegroundColor: onPrimary.withValues(alpha: 0.8),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          foregroundColor: palette.ink,
          side: BorderSide(color: palette.line),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: palette.ink),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? palette.surface : palette.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: palette.muted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: palette.muted),
        floatingLabelStyle: textTheme.labelLarge?.copyWith(color: primary),
        prefixIconColor: palette.muted,
        suffixIconColor: palette.muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.danger, width: 1.6),
        ),
        errorStyle: textTheme.bodySmall?.copyWith(color: palette.danger),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isLight ? AppColors.ink : palette.surfaceMuted,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: palette.line),
        ),
        textStyle: textTheme.bodyMedium,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: palette.surfaceMuted,
        side: BorderSide(color: palette.line),
        labelStyle: textTheme.bodySmall?.copyWith(
          color: palette.ink,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: palette.line,
        circularTrackColor: palette.line,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
