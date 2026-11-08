import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/brand.dart';
import '../widgets/common.dart';

/// S6. Settings & trust (F8): language, not-official notice, content freshness,
/// privacy, a deliberately low-key Premium teaser, and About.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final fmt = Fmt.of(context);
    final meta = state.catalog.meta;

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(AppSpacing.page, AppSpacing.xxs, AppSpacing.page, AppSpacing.xl),
        children: [
          SectionHeader(
            title: l.language,
            padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.xxs),
          ),
          Text(l.languageHint, style: t.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          Card(
            key: const ValueKey('settings.language'),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _LanguageTile(code: 'ar', native: 'العربية', description: l.langArDesc),
                const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),
                _LanguageTile(code: 'fr', native: 'Français', description: l.langFrDesc),
                const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),
                _LanguageTile(code: 'en', native: 'English', description: l.langEnDesc),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const NotOfficialNotice(key: ValueKey('settings.notice')),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: l.contentSection),
          Card(
            key: const ValueKey('settings.content'),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InfoRow(
                    icon: Icons.update_rounded,
                    label: l.lastContentUpdate,
                    value: fmt.longDate(meta.lastUpdate),
                    detail: '${l.contentVersion(meta.version)}${meta.illustrative ? '\n${l.sampleData}' : ''}',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.upToDate))),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l.checkForUpdates),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: l.trustSection),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: InfoRow(icon: Icons.lock_outline_rounded, label: l.privacyTitle, value: l.privacyBody),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _PremiumTeaser(key: const ValueKey('settings.premium')),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: l.about),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const BrandMark(size: 44),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Wordmark(fontSize: 18),
                            const SizedBox(width: AppSpacing.xs),
                            Flexible(child: Text(l.versionLabel(l.appVersion), style: t.bodyMedium)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(l.tagline, style: t.titleSmall?.copyWith(color: AppColors.primary)),
                        const SizedBox(height: 2),
                        Text(l.madeBy, style: t.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.code, required this.native, required this.description});

  final String code;
  final String native;
  final String description;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final t = Theme.of(context).textTheme;
    final selected = state.locale.languageCode == code;
    final isArabic = code == 'ar';
    return Semantics(
      selected: selected,
      button: true,
      inMutuallyExclusiveGroup: true,
      child: InkWell(
        onTap: () => state.setLocale(Locale(code)),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          color: selected ? AppColors.primaryContainer.withValues(alpha: 0.45) : null,
          padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.surfaceLow,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  isArabic ? 'ع' : code.toUpperCase(),
                  style: TextStyle(
                    fontFamily: isArabic ? AppFonts.arabic : AppFonts.latin,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: selected ? Colors.white : AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      native,
                      style: t.titleMedium?.copyWith(fontFamily: isArabic ? AppFonts.arabic : AppFonts.latin),
                    ),
                    Text(description, style: t.bodyMedium),
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
    );
  }
}

/// Premium is not in v1: shown as a quiet, outlined, non-interactive row.
class _PremiumTeaser extends StatelessWidget {
  const _PremiumTeaser({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.workspace_premium_outlined, color: AppColors.inkMuted),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xxs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(l.premiumTitle, style: t.titleSmall?.copyWith(color: AppColors.inkMuted)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLow,
                        borderRadius: const BorderRadius.all(Radius.circular(100)),
                        border: Border.all(color: AppColors.hairline),
                      ),
                      child: Text(l.comingLater, style: t.labelSmall?.copyWith(color: AppColors.inkMuted)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(l.premiumPrice(l.currency), style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(l.premiumFeatures, style: t.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
