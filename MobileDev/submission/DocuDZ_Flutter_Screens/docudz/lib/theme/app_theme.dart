// DocuDZ design system: tokens + Material 3 theme.
//
// Identity: "calm paperwork". A warm paper background, deep teal ink for
// actions and trust, an apricot accent reserved for tips and highlights, and a
// dashed "rubber stamp" motif for the Last-verified badge. No flag colours, no
// emblems. Every text/background pair below meets WCAG AA (>= 4.5:1), see the
// contrast table in the design PDF.
import 'package:flutter/material.dart';

/// Colour tokens (light).
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF0E5F58); // Deep teal, 7.5:1 on white
  static const primaryDark = Color(0xFF0A4A44); // Header gradient end
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFCFEAE4); // Mint
  static const onPrimaryContainer = Color(0xFF00201D);
  static const mintOnDark = Color(0xFFBFE6DE); // Secondary text on teal

  static const secondary = Color(0xFF9A4A0B); // Apricot ink (text-safe)
  static const secondaryContainer = Color(0xFFFFE3CC);
  static const onSecondaryContainer = Color(0xFF3A1A00);
  static const accent = Color(0xFFF4A259); // Decorative apricot (logo tick)

  static const tertiary = Color(0xFF3442A0); // Indigo
  static const tertiaryContainer = Color(0xFFE2E5FA);

  // Neutrals: warm "paper" surfaces
  static const paper = Color(0xFFF7F5F0); // App background
  static const card = Color(0xFFFFFFFF);
  static const surfaceLow = Color(0xFFF2EFE8);
  static const surfaceMid = Color(0xFFECE8E0);
  static const surfaceHigh = Color(0xFFE6E1D8);
  static const ink = Color(0xFF1A2423); // 14.6:1 on paper
  static const inkMuted = Color(0xFF4E5C5A); // 6.4:1 on paper
  static const outline = Color(0xFF7A8784); // 3.7:1, for input borders
  static const hairline = Color(0xFFDDD7CC); // Decorative card borders

  // Status
  static const success = Color(0xFF1F7A3E);
  static const successContainer = Color(0xFFD6F0DC);
  static const onSuccessContainer = Color(0xFF14572B);
  static const warning = Color(0xFF8A5A00);
  static const warningContainer = Color(0xFFFFEBC2);
  static const onWarningContainer = Color(0xFF6B4500);
  static const error = Color(0xFFB3261E);
  static const errorContainer = Color(0xFFF9DEDC);
  static const onErrorContainer = Color(0xFF410E0B);
}

/// Per-service tint pairs (background, foreground). All >= 5.5:1.
enum ServiceTone {
  teal(Color(0xFFD5EEE8), Color(0xFF0E5F58)),
  indigo(Color(0xFFE2E5FA), Color(0xFF3442A0)),
  apricot(Color(0xFFFDE6CF), Color(0xFF94470C)),
  plum(Color(0xFFF0E2F2), Color(0xFF7A3B83));

  const ServiceTone(this.background, this.foreground);
  final Color background;
  final Color foreground;

  static ServiceTone fromName(String name) =>
      ServiceTone.values.firstWhere((t) => t.name == name, orElse: () => ServiceTone.teal);
}

/// 8-pt spacing grid (4 and 12 are allowed half-steps).
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;

  /// Horizontal page margin (Material 3 compact window).
  static const double page = 16;
}

/// Corner radii.
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double sheet = 28;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
}

/// Minimum interactive size (Material / WCAG target size).
const double kMinTouchTarget = 48;

/// Font families, bundled as assets (no runtime download).
abstract final class AppFonts {
  static const latin = 'PlusJakartaSans';
  static const arabic = 'IBMPlexSansArabic';
}

abstract final class AppTheme {
  static bool isArabic(Locale locale) => locale.languageCode == 'ar';

  /// Type scale. No text style below 14sp is used anywhere in the app.
  static TextTheme _textTheme({required bool arabic, required Color ink, required Color muted}) {
    // Arabic glyphs need more vertical room; Plex Arabic reads best a touch looser.
    final double k = arabic ? 1.12 : 1.0;
    TextStyle s(double size, FontWeight w, double height, {Color? color, double ls = 0}) => TextStyle(
      fontSize: size,
      fontWeight: w,
      height: height * k,
      letterSpacing: arabic ? 0 : ls,
      color: color ?? ink,
    );
    return TextTheme(
      displaySmall: s(32, FontWeight.w800, 1.2, ls: -0.6),
      headlineMedium: s(26, FontWeight.w800, 1.22, ls: -0.4),
      headlineSmall: s(22, FontWeight.w700, 1.27, ls: -0.2),
      titleLarge: s(20, FontWeight.w700, 1.3, ls: -0.1),
      titleMedium: s(16, FontWeight.w700, 1.35),
      titleSmall: s(15, FontWeight.w600, 1.35),
      bodyLarge: s(16, FontWeight.w400, 1.5),
      bodyMedium: s(14, FontWeight.w400, 1.45, color: muted),
      bodySmall: s(14, FontWeight.w400, 1.4, color: muted),
      labelLarge: s(15, FontWeight.w700, 1.3, ls: 0.1),
      labelMedium: s(14, FontWeight.w600, 1.3, ls: 0.1),
      labelSmall: s(14, FontWeight.w600, 1.3, ls: 0.2),
    );
  }

  static ThemeData light(Locale locale) {
    final bool arabic = isArabic(locale);
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: Color(0xFF0B1450),
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.paper,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.inkMuted,
      surfaceContainerLowest: AppColors.card,
      surfaceContainerLow: AppColors.surfaceLow,
      surfaceContainer: AppColors.surfaceMid,
      surfaceContainerHigh: AppColors.surfaceHigh,
      surfaceContainerHighest: Color(0xFFDFD9CE),
      outline: AppColors.outline,
      outlineVariant: AppColors.hairline,
      inverseSurface: Color(0xFF2A3534),
      onInverseSurface: Color(0xFFF1EFEA),
      inversePrimary: Color(0xFF8ED3C8),
      shadow: Colors.black,
      scrim: Colors.black,
      surfaceTint: Colors.transparent,
    );
    return _build(scheme, arabic);
  }

  /// Optional dark theme (same structure, not part of the v1 screenshots).
  static ThemeData dark(Locale locale) {
    final bool arabic = isArabic(locale);
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF8ED3C8),
      onPrimary: Color(0xFF00201D),
      primaryContainer: Color(0xFF0E5F58),
      onPrimaryContainer: Color(0xFFCFEAE4),
      secondary: Color(0xFFFFB77C),
      onSecondary: Color(0xFF3A1A00),
      secondaryContainer: Color(0xFF6E3500),
      onSecondaryContainer: Color(0xFFFFE3CC),
      tertiary: Color(0xFFBCC3FF),
      onTertiary: Color(0xFF0B1450),
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      surface: Color(0xFF121817),
      onSurface: Color(0xFFE3E8E6),
      onSurfaceVariant: Color(0xFFB9C6C3),
      surfaceContainerLowest: Color(0xFF0D1211),
      surfaceContainerLow: Color(0xFF1A2120),
      surfaceContainer: Color(0xFF1E2524),
      surfaceContainerHigh: Color(0xFF283030),
      surfaceContainerHighest: Color(0xFF333B3A),
      outline: Color(0xFF8A9693),
      outlineVariant: Color(0xFF3F4947),
      surfaceTint: Colors.transparent,
    );
    return _build(scheme, arabic);
  }

  static ThemeData _build(ColorScheme scheme, bool arabic) {
    final textTheme = _textTheme(arabic: arabic, ink: scheme.onSurface, muted: scheme.onSurfaceVariant);
    final family = arabic ? AppFonts.arabic : AppFonts.latin;
    final fallback = [arabic ? AppFonts.latin : AppFonts.arabic];
    const buttonShape = RoundedRectangleBorder(borderRadius: AppRadius.mdAll);
    const buttonSize = Size(64, 52);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: family,
      fontFamilyFallback: fallback,
      textTheme: textTheme.apply(fontFamily: family, fontFamilyFallback: fallback),
      scaffoldBackgroundColor: scheme.surface,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: InkRipple.splashFactory, // cheaper than InkSparkle on low-end GPUs
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontFamily: family),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: textTheme.labelLarge?.copyWith(fontFamily: family),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.outline),
          textStyle: textTheme.labelLarge?.copyWith(fontFamily: family),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: buttonShape,
          textStyle: textTheme.labelLarge?.copyWith(fontFamily: family),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsetsDirectional.fromSTEB(AppSpacing.md, 14, AppSpacing.md, 14),
        hintStyle: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant, fontFamily: family),
        border: OutlineInputBorder(
          borderRadius: AppRadius.lgAll,
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgAll,
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgAll,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        elevation: 0,
        backgroundColor: scheme.surfaceContainerLowest,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: family,
            fontFamilyFallback: fallback,
            fontSize: 14,
            height: 1.2,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(size: 24, color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant);
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        selectedColor: scheme.primary,
        secondarySelectedColor: scheme.primary,
        labelStyle: textTheme.labelMedium?.copyWith(fontFamily: family),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(color: scheme.onPrimary, fontFamily: family),
        side: BorderSide(color: scheme.outlineVariant),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
        checkmarkColor: scheme.onPrimary,
        showCheckmark: false,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
        side: BorderSide(color: scheme.outline, width: 2),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? scheme.primary : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(scheme.onPrimary),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? scheme.primary : scheme.outline,
        ),
      ),
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? Colors.transparent : scheme.outline,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        modalBackgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: true,
        dragHandleColor: scheme.outlineVariant,
        dragHandleSize: const Size(40, 4),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: scheme.onInverseSurface, fontFamily: family),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
      listTileTheme: ListTileThemeData(
        minVerticalPadding: AppSpacing.sm,
        contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.md),
        titleTextStyle: textTheme.titleSmall?.copyWith(fontFamily: family),
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(fontFamily: family),
        iconColor: scheme.onSurfaceVariant,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHigh,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          // Light, GPU-friendly transition for 2 GB devices.
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
