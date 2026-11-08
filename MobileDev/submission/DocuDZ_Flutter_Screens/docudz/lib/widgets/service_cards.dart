import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'chips.dart';
import 'common.dart';
import 'progress.dart';

/// Service entry on Home: icon, title, subtitle, Last-verified stamp and a
/// done/total ring.
class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service, required this.onTap});

  final Service service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final t = Theme.of(context).textTheme;
    final done = state.doneCount(service);
    final total = service.documents.length;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              ServiceIconTile(service: service, size: 52),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.title.of(locale), style: t.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(
                      service.subtitle.of(locale),
                      style: t.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    VerifiedStamp(date: service.lastVerified),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ProgressRing(
                done: done,
                total: total,
                color: service.tone.foreground,
                semanticsLabel: l.docsReadyOf(done, total),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Teal hero card: "Continue where you left off".
class ContinueCard extends StatelessWidget {
  const ContinueCard({super.key, required this.service, required this.onContinue});

  final Service service;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final t = Theme.of(context).textTheme;
    final done = state.doneCount(service);
    final total = service.documents.length;
    final next = state.nextMissing(service);
    return Container(
      decoration: const BoxDecoration(
        borderRadius: AppRadius.xlAll,
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md + 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ServiceIconTile(service: service, size: 44, onDark: true),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.title.of(locale), style: t.titleMedium?.copyWith(color: Colors.white)),
                    Text(l.docsReadyOf(done, total), style: t.bodyMedium?.copyWith(color: AppColors.mintOnDark)),
                  ],
                ),
              ),
              Text(
                '${(state.progress(service) * 100).round()}%',
                style: t.headlineSmall?.copyWith(color: Colors.white, fontFamily: AppFonts.latin),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DocuProgressBar(
            value: state.progress(service),
            color: AppColors.accent,
            trackColor: Colors.white.withValues(alpha: 0.18),
            semanticsLabel: l.docsReadyOf(done, total),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  next == null ? l.allSetTitle : l.nextDocument(next.name.of(locale)),
                  style: t.titleSmall?.copyWith(color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton.icon(
                onPressed: onContinue,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(48, 48),
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 12, 0),
                ),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                label: Text(l.continueAction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
