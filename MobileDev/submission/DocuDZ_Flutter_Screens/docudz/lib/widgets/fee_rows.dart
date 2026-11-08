import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

const _tabular = [FontFeature.tabularFigures()];

/// One priced line of the calculator: optional checkbox, label, where to pay,
/// optional quantity stepper, and the line amount aligned to the end edge.
class FeeLineTile extends StatelessWidget {
  const FeeLineTile({super.key, required this.fee});

  final FeeItem fee;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final locale = Localizations.localeOf(context);
    final t = Theme.of(context).textTheme;
    final enabled = state.enabledOf(fee);
    final qty = state.qtyOf(fee);
    final line = state.lineTotal(fee);
    final muted = !enabled;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fee.optional) ...[
            SizedBox(
              width: kMinTouchTarget,
              height: kMinTouchTarget,
              child: Checkbox(
                value: enabled,
                onChanged: (v) => state.setEnabled(fee, v ?? false),
                semanticLabel: fee.label.of(locale),
              ),
            ),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(top: fee.optional ? AppSpacing.sm : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fee.label.of(locale),
                    style: t.titleSmall?.copyWith(color: muted ? AppColors.inkMuted : AppColors.ink),
                  ),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      children: [
                        if (fee.optional)
                          TextSpan(
                            text: '${l.optional} · ',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.secondary),
                          ),
                        if (fee.note != null) TextSpan(text: fee.note!.of(locale)),
                      ],
                    ),
                    style: t.bodyMedium,
                  ),
                  if (fee.adjustable) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        _StepperButton(
                          icon: Icons.remove_rounded,
                          tooltip: l.decrease,
                          onPressed: qty > 0 ? () => state.setQty(fee, qty - 1) : null,
                        ),
                        SizedBox(
                          width: 36,
                          child: Text(
                            '$qty',
                            textAlign: TextAlign.center,
                            style: t.titleMedium?.copyWith(fontFeatures: _tabular, fontFamily: AppFonts.latin),
                          ),
                        ),
                        _StepperButton(
                          icon: Icons.add_rounded,
                          tooltip: l.increase,
                          onPressed: () => state.setQty(fee, qty + 1),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            '× ${fmt.money(fee.amount)}',
                            style: t.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Padding(
            padding: EdgeInsetsDirectional.only(top: fee.optional ? AppSpacing.sm : 0),
            child: fee.amount == 0
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 18, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(l.free, style: t.titleSmall?.copyWith(color: AppColors.success)),
                    ],
                  )
                : Text(
                    // An unticked option shows what it *would* add, in muted ink.
                    muted ? fmt.plusMoney(fee.amount * qty) : fmt.money(line),
                    style: t.titleSmall?.copyWith(
                      fontFeatures: _tabular,
                      color: muted ? AppColors.inkMuted : AppColors.ink,
                      fontWeight: muted ? FontWeight.w500 : null,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        minimumSize: const Size(kMinTouchTarget, kMinTouchTarget),
        side: const BorderSide(color: AppColors.hairline),
        foregroundColor: AppColors.primary,
      ),
    );
  }
}

/// Subtotal footer of a fee group.
class SubtotalRow extends StatelessWidget {
  const SubtotalRow({super.key, required this.label, required this.amount});

  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final fmt = Fmt.of(context);
    return Container(
      color: AppColors.surfaceLow,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: t.titleSmall?.copyWith(color: AppColors.inkMuted)),
          ),
          Text(fmt.money(amount), style: t.titleMedium?.copyWith(fontFeatures: _tabular)),
        ],
      ),
    );
  }
}

/// Sticky TOTAL bar at the bottom of the calculator.
class TotalBar extends StatelessWidget {
  const TotalBar({super.key, required this.total, required this.official, required this.other});

  final int total;
  final int official;
  final int other;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final fmt = Fmt.of(context);
    return Semantics(
      container: true,
      liveRegion: true,
      label: '${l.totalToBring}: ${fmt.money(total)}',
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.page + 4,
          AppSpacing.md,
          AppSpacing.page + 4,
          AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l.totalToBring, style: t.titleSmall?.copyWith(color: AppColors.mintOnDark)),
                  const SizedBox(height: 2),
                  Text(
                    '${fmt.money(official)} + ${fmt.money(other)}',
                    style: t.bodyMedium?.copyWith(color: AppColors.mintOnDark, fontFeatures: _tabular),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: AppRadius.mdAll),
              child: Text(
                fmt.money(total),
                style: t.headlineMedium?.copyWith(color: Colors.white, fontFeatures: _tabular),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
