import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/chips.dart';
import '../widgets/common.dart';
import '../widgets/fee_rows.dart';

/// S3. Stamp & fee calculator (F3). Used as a tab (with a service picker) or
/// pushed from a checklist (fixed [serviceId]).
class CostCalculatorScreen extends StatelessWidget {
  const CostCalculatorScreen({super.key, this.serviceId});

  final String? serviceId;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final service = state.catalog.service(serviceId ?? state.costsServiceId);
    final official = service.fees.where((f) => f.isOfficial).toList();
    final other = service.fees.where((f) => !f.isOfficial).toList();

    return Scaffold(
      appBar: AppBar(title: Text(l.costsTitle)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.lg),
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.sm),
                  child: Text(l.costsSubtitle, style: t.bodyMedium),
                ),
                if (serviceId == null) ...[
                  ServiceSelector(
                    key: const ValueKey('costs.selector'),
                    services: state.catalog.services,
                    selectedId: service.id,
                    onSelected: state.selectCostsService,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.page),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FeesNote(key: const ValueKey('costs.note'), service: service),
                      const SizedBox(height: AppSpacing.md),
                      _FeeGroup(
                        key: const ValueKey('costs.official'),
                        icon: Icons.receipt_long_outlined,
                        title: l.sectionStampsFees,
                        fees: official,
                        subtotal: state.subtotal(service, official: true),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _FeeGroup(
                        key: const ValueKey('costs.other'),
                        icon: Icons.shopping_bag_outlined,
                        title: l.sectionOther,
                        fees: other,
                        subtotal: state.subtotal(service, official: false),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TipCallout(title: l.sheetTip, text: l.stampsTip),
                    ],
                  ),
                ),
              ],
            ),
          ),
          TotalBar(
            key: const ValueKey('costs.total'),
            total: state.total(service),
            official: state.subtotal(service, official: true),
            other: state.subtotal(service, official: false),
          ),
        ],
      ),
    );
  }
}

class _FeesNote extends StatelessWidget {
  const _FeesNote({super.key, required this.service});

  final Service service;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VerifiedStamp(date: service.lastVerified, long: true),
        const SizedBox(height: AppSpacing.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsetsDirectional.only(top: 1),
              child: Icon(Icons.info_outline_rounded, size: 18, color: AppColors.inkMuted),
            ),
            const SizedBox(width: 6),
            Expanded(child: Text(l.feesMayChange, style: t.bodyMedium)),
          ],
        ),
      ],
    );
  }
}

class _FeeGroup extends StatelessWidget {
  const _FeeGroup({super.key, required this.icon, required this.title, required this.fees, required this.subtotal});

  final IconData icon;
  final String title;
  final List<FeeItem> fees;
  final int subtotal;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxs),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(title, style: t.titleSmall?.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
          ),
          for (final (i, f) in fees.indexed) ...[
            if (i > 0) const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),
            FeeLineTile(fee: f),
          ],
          SubtotalRow(label: l.subtotal, amount: subtotal),
        ],
      ),
    );
  }
}
