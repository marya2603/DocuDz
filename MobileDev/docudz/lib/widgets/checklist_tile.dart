import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'chips.dart';

/// One required document. The checkbox toggles it; tapping the tile opens the
/// detail sheet. Ticked state = filled box + tinted tile + "Ready" pill, so the
/// state is readable without relying on colour.
class ChecklistTile extends StatelessWidget {
  const ChecklistTile({
    super.key,
    required this.document,
    required this.ticked,
    required this.onToggle,
    required this.onOpen,
  });

  final DocumentItem document;
  final bool ticked;
  final VoidCallback onToggle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final t = Theme.of(context).textTheme;
    final name = document.name.of(locale);
    final status = ticked ? l.statusReady : l.statusToGet;
    return Material(
      color: ticked ? AppColors.primaryContainer.withValues(alpha: 0.45) : AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgAll,
        side: BorderSide(color: ticked ? AppColors.primary.withValues(alpha: 0.35) : AppColors.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(AppSpacing.xxs, AppSpacing.sm, AppSpacing.xs, AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: l.checkboxSemantics(name, status),
                child: SizedBox(
                  width: kMinTouchTarget,
                  height: kMinTouchTarget,
                  child: Checkbox(value: ticked, onChanged: (_) => onToggle()),
                ),
              ),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(top: AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: t.titleSmall),
                      const SizedBox(height: AppSpacing.xxs),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsetsDirectional.only(top: 1),
                            child: Icon(Icons.place_outlined, size: 18, color: AppColors.inkMuted),
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Expanded(child: Text(l.issuedBy(document.issuedBy.of(locale)), style: t.bodyMedium)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
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
                          StatusPill(
                            icon: Icons.content_copy_rounded,
                            label: l.copies(document.copies),
                            foreground: AppColors.ink,
                            background: AppColors.surfaceLow,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xxs),
              const SizedBox(
                width: 32,
                height: kMinTouchTarget,
                child: Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
