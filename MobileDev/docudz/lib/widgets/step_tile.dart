import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// One step of the vertical timeline. The rail sits on the start side, so it
/// moves to the right edge in Arabic automatically.
class StepTile extends StatelessWidget {
  const StepTile({super.key, required this.index, required this.step, required this.isLast});

  final int index;
  final ProcessStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final t = Theme.of(context).textTheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: index == 0 ? AppColors.primary : AppColors.card,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: t.titleSmall?.copyWith(
                      color: index == 0 ? Colors.white : AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontFamily: AppFonts.latin,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                      color: AppColors.primary.withValues(alpha: 0.25),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(bottom: isLast ? 0 : AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.stepLabel(index + 1), style: t.labelMedium?.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 2),
                  Text(step.title.of(locale), style: t.titleMedium),
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 18, color: AppColors.inkMuted),
                      const SizedBox(width: AppSpacing.xxs),
                      Expanded(
                        child: Text(step.place.of(locale), style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(step.detail.of(locale), style: t.bodyMedium?.copyWith(color: AppColors.ink)),
                  if (step.tip != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    TipCallout(title: l.tipAvoidTrip, text: step.tip!.of(locale)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
