import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

IconData serviceIconData(ServiceIcon icon) => switch (icon) {
  ServiceIcon.school => Icons.school_outlined,
  ServiceIcon.passport => Icons.flight_takeoff_rounded,
  ServiceIcon.car => Icons.directions_car_outlined,
  ServiceIcon.health => Icons.health_and_safety_outlined,
};

/// Service icon on its tinted rounded tile.
class ServiceIconTile extends StatelessWidget {
  const ServiceIconTile({super.key, required this.service, this.size = 48, this.onDark = false});

  final Service service;
  final double size;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: onDark ? Colors.white.withValues(alpha: 0.14) : service.tone.background,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(
        serviceIconData(service.icon),
        size: size * 0.52,
        color: onDark ? Colors.white : service.tone.foreground,
      ),
    );
  }
}

/// Section title with optional trailing widget.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing, this.padding});

  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
          ?trailing,
        ],
      ),
    );
  }
}

/// Apricot callout used for tips ("Tip to avoid an extra trip").
class TipCallout extends StatelessWidget {
  const TipCallout({super.key, required this.title, required this.text, this.icon = Icons.lightbulb_outline_rounded});

  final String title;
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(AppSpacing.sm, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
      decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: AppRadius.mdAll),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: AppColors.onSecondaryContainer),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: t.labelMedium?.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(text, style: t.bodyMedium?.copyWith(color: AppColors.onSecondaryContainer)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Not an official service" notice. [compact] is a one-line footer.
class NotOfficialNotice extends StatelessWidget {
  const NotOfficialNotice({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    if (compact) {
      return Semantics(
        container: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.inkMuted),
            const SizedBox(width: 6),
            Flexible(
              child: Text(l.notOfficialFooter, style: t.bodyMedium, textAlign: TextAlign.center),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warningContainer,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.onWarningContainer),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.notOfficialTitle, style: t.titleSmall?.copyWith(color: AppColors.onWarningContainer)),
                const SizedBox(height: AppSpacing.xxs),
                Text(l.notOfficialBody, style: t.bodyMedium?.copyWith(color: AppColors.onWarningContainer)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon + label + value row used in sheets and office cards.
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.icon, required this.label, required this.value, this.detail});

  final IconData icon;
  final String label;
  final String value;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(color: AppColors.surfaceLow, shape: BoxShape.circle),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: t.bodyMedium),
              const SizedBox(height: 2),
              Text(value, style: t.titleSmall),
              if (detail != null) ...[const SizedBox(height: AppSpacing.xxs), Text(detail!, style: t.bodyMedium)],
            ],
          ),
        ),
      ],
    );
  }
}

/// Horizontal chips to pick a service (Costs and Offices tabs).
class ServiceSelector extends StatelessWidget {
  const ServiceSelector({super.key, required this.services, required this.selectedId, required this.onSelected});

  final List<Service> services;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final t = Theme.of(context).textTheme;
    // Four equal segments: every service is always visible (no horizontal
    // scrolling or clipped chips, whatever the language).
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.page),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xxs),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: AppColors.hairline),
        ),
        child: Row(
          children: [
            for (final s in services)
              Expanded(
                child: Semantics(
                  selected: s.id == selectedId,
                  button: true,
                  inMutuallyExclusiveGroup: true,
                  child: _Segment(
                    service: s,
                    label: s.shortTitle.of(locale),
                    selected: s.id == selectedId,
                    onTap: () => onSelected(s.id),
                    style: t.labelMedium,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.service,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.style,
  });

  final Service service;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: AppSpacing.xs),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                serviceIconData(service.icon),
                size: 22,
                color: selected ? AppColors.onPrimary : service.tone.foreground,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: style?.copyWith(color: selected ? AppColors.onPrimary : AppColors.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Friendly empty state (e.g. search without results).
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
            child: Icon(icon, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: t.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),
          Text(body, style: t.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
