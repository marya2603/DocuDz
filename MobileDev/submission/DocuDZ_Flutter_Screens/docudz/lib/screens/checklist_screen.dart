import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/checklist_tile.dart';
import '../widgets/chips.dart';
import '../widgets/common.dart';
import '../widgets/progress.dart';
import '../widgets/sheets.dart';
import 'cost_calculator_screen.dart';
import 'office_screen.dart';
import 'process_screen.dart';

/// S2. Interactive checklist for one service (F2 tick-off, F4 issuing office,
/// F7 last verified + report an error).
class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final service = state.catalog.service(serviceId);
    final done = state.doneCount(service);
    final total = service.documents.length;
    final remaining = total - done;

    return Scaffold(
      appBar: AppBar(
        title: Text(service.title.of(locale)),
        actions: [
          IconButton(
            key: const ValueKey('checklist.flag'),
            tooltip: l.reportError,
            icon: const Icon(Icons.flag_outlined),
            onPressed: () => showReportErrorSheet(context, service),
          ),
          const SizedBox(width: AppSpacing.xxs),
        ],
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(AppSpacing.page, AppSpacing.xxs, AppSpacing.page, AppSpacing.xl),
        children: [
          _ProgressHeader(key: const ValueKey('checklist.header'), service: service, done: done, total: total),
          const SizedBox(height: AppSpacing.sm),
          Row(
            key: const ValueKey('checklist.quick'),
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.format_list_numbered_rounded,
                  label: l.quickSteps,
                  onTap: () => _push(context, ProcessScreen(serviceId: serviceId)),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _QuickAction(
                  icon: Icons.calculate_outlined,
                  label: l.quickCosts,
                  onTap: () => _push(context, CostCalculatorScreen(serviceId: serviceId)),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _QuickAction(
                  icon: Icons.location_on_outlined,
                  label: l.quickOffice,
                  onTap: () => _push(context, OfficeScreen(serviceId: serviceId)),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (remaining == 0) ...[
            _AllSetBanner(key: const ValueKey('checklist.allset')),
            const SizedBox(height: AppSpacing.md),
          ],
          SectionHeader(
            title: l.requiredDocuments,
            trailing: StatusPill(
              icon: remaining == 0 ? Icons.check_circle_rounded : Icons.pending_outlined,
              label: l.remainingCount(remaining),
              foreground: remaining == 0 ? AppColors.onSuccessContainer : AppColors.secondary,
              background: remaining == 0 ? AppColors.successContainer : AppColors.secondaryContainer,
            ),
          ),
          for (final (i, d) in service.documents.indexed) ...[
            ChecklistTile(
              key: ValueKey('checklist.tile.$i'),
              document: d,
              ticked: state.isTicked(service.id, d.id),
              onToggle: () => state.toggle(service.id, d.id),
              onOpen: () => showDocumentSheet(context, service, d),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          const SizedBox(height: AppSpacing.md),
          _ReportCard(key: const ValueKey('checklist.report'), service: service),
          const SizedBox(height: AppSpacing.lg),
          const NotOfficialNotice(compact: true),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({super.key, required this.service, required this.done, required this.total});

  final Service service;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final t = Theme.of(context).textTheme;
    final value = total == 0 ? 0.0 : done / total;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 4),
      decoration: const BoxDecoration(
        borderRadius: AppRadius.xlAll,
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ServiceIconTile(service: service, size: 48, onDark: true),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.subtitle.of(locale), style: t.bodyMedium?.copyWith(color: AppColors.mintOnDark)),
                    Text(l.docsReadyOf(done, total), style: t.titleMedium?.copyWith(color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${(value * 100).round()}%',
                style: t.headlineMedium?.copyWith(color: Colors.white, fontFamily: AppFonts.latin),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DocuProgressBar(
            value: value,
            height: 10,
            color: AppColors.accent,
            trackColor: Colors.white.withValues(alpha: 0.18),
            semanticsLabel: l.docsReadyOf(done, total),
          ),
          const SizedBox(height: AppSpacing.md),
          VerifiedStamp(
            key: const ValueKey('checklist.verified'),
            date: service.lastVerified,
            long: true,
            onDark: true,
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.card,
        side: const BorderSide(color: AppColors.hairline),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        minimumSize: const Size(0, 52),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 6),
          Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _AllSetBanner extends StatelessWidget {
  const _AllSetBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.successContainer,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.celebration_outlined, color: AppColors.onSuccessContainer, size: 28),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.allSetTitle, style: t.titleMedium?.copyWith(color: AppColors.onSuccessContainer)),
                Text(l.allSetBody, style: t.bodyMedium?.copyWith(color: AppColors.onSuccessContainer)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({super.key, required this.service});

  final Service service;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.surfaceLow, borderRadius: AppRadius.lgAll),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.reportErrorHint, style: t.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => showReportErrorSheet(context, service),
            icon: const Icon(Icons.flag_outlined),
            label: Text(l.reportError),
            style: OutlinedButton.styleFrom(backgroundColor: AppColors.card),
          ),
        ],
      ),
    );
  }
}
