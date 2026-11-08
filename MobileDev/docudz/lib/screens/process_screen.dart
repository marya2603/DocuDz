import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/chips.dart';
import '../widgets/common.dart';
import '../widgets/step_tile.dart';

/// S4. Ordered procedure as a vertical timeline, with "avoid an extra trip"
/// tips (F5).
class ProcessScreen extends StatelessWidget {
  const ProcessScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final t = Theme.of(context).textTheme;
    final service = state.catalog.service(serviceId);

    return Scaffold(
      appBar: AppBar(title: Text(l.stepsTitle)),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(AppSpacing.page, AppSpacing.xxs, AppSpacing.page, AppSpacing.xl),
        children: [
          Card(
            key: const ValueKey('steps.header'),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ServiceIconTile(service: service, size: 48),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(service.title.of(locale), style: t.titleMedium),
                            Text(service.subtitle.of(locale), style: t.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      StatusPill(
                        icon: Icons.format_list_numbered_rounded,
                        label: l.stepsCount(service.steps.length),
                        foreground: AppColors.ink,
                        background: AppColors.surfaceLow,
                      ),
                      StatusPill(
                        icon: Icons.directions_walk_rounded,
                        label: l.visitsCount(service.estimatedVisits),
                        foreground: AppColors.ink,
                        background: AppColors.surfaceLow,
                      ),
                      VerifiedStamp(date: service.lastVerified),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final (i, step) in service.steps.indexed)
            StepTile(key: ValueKey('steps.tile.$i'), index: i, step: step, isLast: i == service.steps.length - 1),
          const SizedBox(height: AppSpacing.lg),
          const NotOfficialNotice(compact: true),
        ],
      ),
    );
  }
}
