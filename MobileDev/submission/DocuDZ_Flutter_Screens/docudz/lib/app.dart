import 'package:flutter/material.dart';

import 'l10n/gen/app_localizations.dart';
import 'screens/home_shell.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

class DocuDzApp extends StatelessWidget {
  const DocuDzApp({super.key, required this.state, this.home, this.navigatorKey});

  final AppState state;

  /// Overridable start screen (onboarding on first launch, a given screen in
  /// screenshot tests).
  final Widget? home;
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: Builder(
        builder: (context) {
          final locale = AppScope.of(context).locale;
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (c) => AppLocalizations.of(c).appName,
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.light(locale),
            darkTheme: AppTheme.dark(locale),
            // v1 ships the light theme; the dark scheme is defined and ready.
            themeMode: ThemeMode.light,
            // Language switch is instant: no theme cross-fade on low-end phones.
            themeAnimationDuration: Duration.zero,
            builder: (context, child) => _PhoneWidthOnWideScreens(child: child!),
            home: home ?? const HomeShell(),
          );
        },
      ),
    );
  }
}

/// DocuDZ is a phone app. When it runs in a wide window (Chrome, desktop,
/// tablet landscape) the layout is kept at phone width and centred instead of
/// stretching cards across the screen. Phones are unaffected.
class _PhoneWidthOnWideScreens extends StatelessWidget {
  const _PhoneWidthOnWideScreens({required this.child});

  final Widget child;

  static const double _breakpoint = 600;
  static const double _maxWidth = 480;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    if (mq.size.width <= _breakpoint) return child;
    return ColoredBox(
      color: AppColors.surfaceHigh,
      child: Center(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            border: BorderDirectional(
              start: BorderSide(color: AppColors.hairline),
              end: BorderSide(color: AppColors.hairline),
            ),
          ),
          child: SizedBox(
            width: _maxWidth,
            child: ClipRect(
              child: MediaQuery(
                data: mq.copyWith(size: Size(_maxWidth, mq.size.height)),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
