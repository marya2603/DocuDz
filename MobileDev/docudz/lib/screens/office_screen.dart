import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/chips.dart';
import '../widgets/common.dart';
import '../widgets/office_widgets.dart';
import '../widgets/sheets.dart';

/// S5. Office information per wilaya (F6): address, opening days, open-now
/// status, offline map placeholder and an "Open in Maps" hand-off.
class OfficeScreen extends StatelessWidget {
  const OfficeScreen({super.key, this.serviceId});

  final String? serviceId;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final t = Theme.of(context).textTheme;
    final service = state.catalog.service(serviceId ?? state.officesServiceId);
    final office = service.officeIn(state.wilayaCode)!;
    final now = state.now();

    return Scaffold(
      appBar: AppBar(title: Text(l.officeTitle)),
      body: ListView(
        padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.xl),
        children: [
          if (serviceId == null) ...[
            ServiceSelector(
              key: const ValueKey('office.selector'),
              services: state.catalog.services,
              selectedId: service.id,
              onSelected: state.selectOfficesService,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Static label above the field: a floating label would shrink
                // below the 14sp minimum.
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: AppSpacing.xxs, bottom: AppSpacing.xxs),
                  child: Text(l.wilaya, style: t.labelMedium?.copyWith(color: AppColors.inkMuted)),
                ),
                DropdownButtonFormField<String>(
                  key: const ValueKey('office.wilaya'),
                  initialValue: state.wilayaCode,
                  isExpanded: true,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.map_outlined)),
                  borderRadius: AppRadius.lgAll,
                  items: [
                    for (final w in state.catalog.wilayas)
                      DropdownMenuItem(
                        value: w.code,
                        child: Text('${w.code} · ${w.name.of(locale)}', style: t.bodyLarge),
                      ),
                  ],
                  onChanged: (v) {
                    if (v != null) state.selectWilaya(v);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Card(
                  key: const ValueKey('office.card'),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const MapPlaceholder(key: ValueKey('office.map')),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.officeKind.of(locale),
                              style: t.labelMedium?.copyWith(color: AppColors.primary),
                            ),
                            const SizedBox(height: 2),
                            Text(office.name.of(locale), style: t.titleLarge),
                            const SizedBox(height: AppSpacing.xs),
                            OpenStatusPill(key: const ValueKey('office.status'), office: office, now: now),
                            const SizedBox(height: AppSpacing.md),
                            InfoRow(icon: Icons.place_outlined, label: l.address, value: office.address.of(locale)),
                            const SizedBox(height: AppSpacing.md),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                key: const ValueKey('office.maps'),
                                onPressed: () =>
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.mapsSnack))),
                                icon: const Icon(Icons.directions_rounded),
                                label: Text(l.openInMaps),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Card(
                  key: const ValueKey('office.hours'),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            AppSpacing.xxs,
                            AppSpacing.xxs,
                            AppSpacing.xxs,
                            AppSpacing.xs,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.schedule_rounded, size: 20, color: AppColors.primary),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(child: Text(l.openingHours, style: t.titleSmall)),
                            ],
                          ),
                        ),
                        OpeningHoursTable(office: office, now: now),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [Flexible(child: VerifiedStamp(date: service.lastVerified, long: true))],
                ),
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () => showReportErrorSheet(context, service),
                    icon: const Icon(Icons.flag_outlined),
                    label: Text(l.reportError),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
