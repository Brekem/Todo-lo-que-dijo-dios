import 'package:flutter/material.dart';

import '../config/edition.dart';
import 'app_palette.dart';

abstract final class AppTheme {
  static const serif = 'Cormorant';
  static const sans = 'Inter';

  static ThemeData light() => _build(Brightness.light, Edition.current.light);
  static ThemeData dark() => _build(Brightness.dark, Edition.current.dark);

  static ThemeData _build(Brightness brightness, AppPalette p) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? p.gold : p.blue,
      onPrimary: isDark ? p.onGold : const Color(0xFFFFFBF2),
      primaryContainer: isDark ? p.goldSoft : p.blueSoft,
      onPrimaryContainer: isDark ? p.ink : p.blue,
      secondary: p.gold,
      onSecondary: p.onGold,
      secondaryContainer: p.goldSoft,
      onSecondaryContainer: isDark ? p.ink : p.onGoldSoft,
      tertiary: p.blue,
      onTertiary: isDark ? const Color(0xFF0B1224) : Colors.white,
      tertiaryContainer: p.blueSoft,
      onTertiaryContainer: isDark ? p.ink : p.blue,
      error: p.crimson,
      onError: Colors.white,
      surface: p.background,
      onSurface: p.ink,
      onSurfaceVariant: p.warmGray,
      surfaceContainerLowest: p.background,
      surfaceContainerLow: p.parchment,
      surfaceContainer: p.parchment,
      surfaceContainerHigh: Color.alphaBlend(
        p.ink.withValues(alpha: 0.04),
        p.parchment,
      ),
      surfaceContainerHighest: Color.alphaBlend(
        p.ink.withValues(alpha: 0.07),
        p.parchment,
      ),
      outline: p.warmGray.withValues(alpha: 0.5),
      outlineVariant: p.warmGray.withValues(alpha: 0.18),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: p.ink,
      onInverseSurface: p.background,
      inversePrimary: isDark ? p.blue : p.gold,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      fontFamily: sans,
      scaffoldBackgroundColor: p.background,
      extensions: [p],
      splashFactory: InkSparkle.splashFactory,
    );

    final text = base.textTheme;
    TextStyle serifStyle(
      TextStyle? s, {
      double? size,
      FontWeight w = FontWeight.w500,
      double height = 1.2,
    }) => (s ?? const TextStyle()).copyWith(
      fontFamily: serif,
      fontSize: size,
      fontWeight: w,
      height: height,
      color: p.ink,
      letterSpacing: 0.2,
    );

    return base.copyWith(
      textTheme: text.copyWith(
        displayLarge: serifStyle(text.displayLarge, size: 52, height: 1.05),
        displayMedium: serifStyle(text.displayMedium, size: 42, height: 1.1),
        displaySmall: serifStyle(text.displaySmall, size: 34),
        headlineLarge: serifStyle(
          text.headlineLarge,
          size: 32,
          w: FontWeight.w600,
        ),
        headlineMedium: serifStyle(
          text.headlineMedium,
          size: 28,
          w: FontWeight.w600,
        ),
        headlineSmall: serifStyle(
          text.headlineSmall,
          size: 24,
          w: FontWeight.w600,
        ),
        titleLarge: serifStyle(text.titleLarge, size: 22, w: FontWeight.w600),
        titleMedium: text.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: p.ink,
          letterSpacing: 0.1,
        ),
        titleSmall: text.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: p.ink,
        ),
        bodyLarge: text.bodyLarge?.copyWith(
          fontSize: 17,
          height: 1.65,
          color: p.ink,
        ),
        bodyMedium: text.bodyMedium?.copyWith(
          fontSize: 15,
          height: 1.6,
          color: p.ink,
        ),
        bodySmall: text.bodySmall?.copyWith(height: 1.5, color: p.warmGray),
        labelLarge: text.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
        ),
        labelMedium: text.labelMedium?.copyWith(
          letterSpacing: 1.2,
          color: p.warmGray,
        ),
        labelSmall: text.labelSmall?.copyWith(
          letterSpacing: 1.4,
          color: p.warmGray,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: p.ink,
        titleTextStyle: serifStyle(null, size: 22, w: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: p.parchment,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: p.warmGray.withValues(alpha: 0.14)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.goldSoft,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontFamily: sans,
            fontSize: 11.5,
            fontWeight: s.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
            color: s.contains(WidgetState.selected) ? p.ink : p.warmGray,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? (isDark ? p.gold : p.blue)
                : p.warmGray,
          ),
        ),
      ),
      searchBarTheme: SearchBarThemeData(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(p.parchment),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        side: WidgetStatePropertyAll(
          BorderSide(color: p.warmGray.withValues(alpha: 0.18)),
        ),
        hintStyle: WidgetStatePropertyAll(
          TextStyle(color: p.warmGray, fontSize: 15),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 18),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.parchment,
        selectedColor: p.goldSoft,
        side: BorderSide(color: p.warmGray.withValues(alpha: 0.2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: TextStyle(fontFamily: sans, color: p.ink, fontSize: 13.5),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 54),
          padding: const EdgeInsets.symmetric(horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(
            fontFamily: sans,
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 50),
          foregroundColor: p.ink,
          side: BorderSide(color: p.gold.withValues(alpha: 0.7)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: p.warmGray.withValues(alpha: 0.15),
        space: 1,
      ),
      expansionTileTheme: ExpansionTileThemeData(
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: p.gold,
        collapsedIconColor: p.warmGray,
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.ink,
        contentTextStyle: TextStyle(color: p.background, fontFamily: sans),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
