import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'chips.dart';
import 'common.dart';

/// Opens the document detail bottom sheet (where to get it, copies, tip).
Future<void> showDocumentSheet(BuildContext context, Service service, DocumentItem document) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => DocumentSheet(service: service, document: document),
  );
}

class DocumentSheet extends StatelessWidget {
  const DocumentSheet({super.key, required this.service, required this.document});

  final Service service;
  final DocumentItem document;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final t = Theme.of(context).textTheme;
    final ticked = state.isTicked(service.id, document.id);
    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ServiceIconTile(service: service, size: 40),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(service.title.of(locale), style: t.bodyMedium)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(document.name.of(locale), style: t.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          ticked
              ? StatusPill(
                  icon: Icons.check_circle_rounded,
                  label: l.statusReady,
                  foreground: AppColors.onSuccessContainer,
                  background: AppColors.successContainer,
                )
              : StatusPill(
                  icon: Icons.radio_button_unchecked_rounded,
                  label: l.statusToGet,
                  foreground: AppColors.inkMuted,
                  background: AppColors.card,
                  border: AppColors.hairline,
                ),
          const SizedBox(height: AppSpacing.lg),
          InfoRow(
            icon: Icons.place_outlined,
            label: l.sheetWhere,
            value: document.issuedBy.of(locale),
            detail: document.where.of(locale),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(),
          ),
          InfoRow(icon: Icons.content_copy_rounded, label: l.sheetCopies, value: l.copies(document.copies)),
          if (document.tip != null) ...[
            const SizedBox(height: AppSpacing.lg),
            TipCallout(title: l.sheetTip, text: document.tip!.of(locale)),
          ],
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ticked
                ? OutlinedButton.icon(
                    onPressed: () {
                      state.setTicked(service.id, document.id, false);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.undo_rounded),
                    label: Text(l.markMissing),
                  )
                : FilledButton.icon(
                    onPressed: () {
                      state.setTicked(service.id, document.id, true);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: Text(l.markGathered),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Opens the "Report an error" sheet. Works offline: the report is queued.
Future<void> showReportErrorSheet(BuildContext context, Service service) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => ReportErrorSheet(service: service),
  );
}

enum ReportKind { missingDoc, wrongFee, wrongOffice, other }

class ReportErrorSheet extends StatefulWidget {
  const ReportErrorSheet({super.key, required this.service, this.initialKind = ReportKind.wrongFee});

  final Service service;
  final ReportKind initialKind;

  @override
  State<ReportErrorSheet> createState() => _ReportErrorSheetState();
}

class _ReportErrorSheetState extends State<ReportErrorSheet> {
  late ReportKind _kind = widget.initialKind;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final fmt = Fmt.of(context);
    final t = Theme.of(context).textTheme;
    final labels = {
      ReportKind.missingDoc: (Icons.description_outlined, l.reportMissingDoc),
      ReportKind.wrongFee: (Icons.payments_outlined, l.reportWrongFee),
      ReportKind.wrongOffice: (Icons.schedule_rounded, l.reportWrongOffice),
      ReportKind.other: (Icons.more_horiz_rounded, l.reportOther),
    };
    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: AppColors.errorContainer, shape: BoxShape.circle),
                child: const Icon(Icons.flag_outlined, color: AppColors.error),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(l.reportTitle, style: t.headlineSmall)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l.reportSubtitle(widget.service.title.of(locale), fmt.longDate(widget.service.lastVerified)),
            style: t.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l.reportWhat, style: t.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final kind in ReportKind.values)
                ChoiceChip(
                  selected: _kind == kind,
                  onSelected: (_) => setState(() => _kind = kind),
                  avatar: Icon(
                    _kind == kind ? Icons.check_rounded : labels[kind]!.$1,
                    size: 18,
                    color: _kind == kind ? AppColors.onPrimary : AppColors.primary,
                  ),
                  label: Text(labels[kind]!.$2),
                  labelStyle: t.labelMedium?.copyWith(color: _kind == kind ? AppColors.onPrimary : AppColors.ink),
                  side: BorderSide(color: _kind == kind ? AppColors.primary : AppColors.hairline),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.card,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(minLines: 3, maxLines: 5, decoration: InputDecoration(hintText: l.reportDetailsHint)),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.cloud_queue_rounded, size: 20, color: AppColors.inkMuted),
              const SizedBox(width: AppSpacing.xs),
              Expanded(child: Text(l.reportOfflineNote, style: t.bodyMedium)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                messenger.showSnackBar(SnackBar(content: Text(l.reportThanks)));
              },
              icon: const Icon(Icons.send_rounded),
              label: Text(l.reportSend),
            ),
          ),
        ],
      ),
    );
  }
}
