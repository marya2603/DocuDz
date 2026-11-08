import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import '../widgets/common.dart';
import 'home_shell.dart';

/// First launch: pick a language (applies instantly, including RTL).
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.xxl),
                    const Center(child: BrandMark(size: 76)),
                    const SizedBox(height: AppSpacing.md),
                    const Center(child: Wordmark(fontSize: 34)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l.tagline,
                      textAlign: TextAlign.center,
                      style: t.titleMedium?.copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(l.onboardingTitle, style: t.headlineSmall),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(l.onboardingBody, style: t.bodyMedium),
                    const SizedBox(height: AppSpacing.md),
                    for (final (code, native, sub) in const [
                      ('ar', 'العربية', 'Arabic · Arabe'),
                      ('fr', 'Français', 'French · فرنسية'),
                      ('en', 'English', 'Anglais · إنجليزية'),
                    ]) ...[
                      _LanguageOption(
                        code: code,
                        native: native,
                        sub: sub,
                        selected: state.locale.languageCode == code,
                        onTap: () => state.setLocale(Locale(code)),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    for (final (icon, text) in [
                      (Icons.checklist_rounded, l.onbFeat1),
                      (Icons.calculate_outlined, l.onbFeat2),
                      (Icons.location_on_outlined, l.onbFeat3),
                    ])
                      Padding(
                        padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon, size: 20, color: AppColors.primary),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(child: Text(text, style: t.bodyLarge)),
                          ],
                        ),
                      ),
                    const Spacer(),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: () =>
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute<void>(builder: (_) => const HomeShell())),
                      child: Text(l.continueButton),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const NotOfficialNotice(compact: true),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.code,
    required this.native,
    required this.sub,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final String native;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final isArabic = code == 'ar';
    return Semantics(
      selected: selected,
      button: true,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: selected ? AppColors.primaryContainer.withValues(alpha: 0.5) : AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(color: selected ? AppColors.primary : AppColors.hairline, width: selected ? 2 : 1),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        native,
                        style: t.titleLarge?.copyWith(fontFamily: isArabic ? AppFonts.arabic : AppFonts.latin),
                      ),
                      Text(sub, style: t.bodyMedium),
                    ],
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: selected ? AppColors.primary : AppColors.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
