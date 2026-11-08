import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

/// The "Last verified" badge, styled as a rubber stamp (dashed outline).
/// It is the product's trust signal, so it appears on every checklist,
/// service card, calculator and office page.
class VerifiedStamp extends StatelessWidget {
  const VerifiedStamp({super.key, required this.date, this.long = false, this.onDark = false});

  final DateTime date;
  final bool long;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final label = long ? l.lastVerified(fmt.longDate(date)) : l.verifiedShort(fmt.shortDate(date));
    final fg = onDark ? Colors.white : AppColors.primary;
    final border = onDark ? AppColors.mintOnDark : AppColors.primary.withValues(alpha: 0.55);
    final bg = onDark ? Colors.white.withValues(alpha: 0.10) : AppColors.primaryContainer.withValues(alpha: 0.35);
    return CustomPaint(
      painter: _DashedBorderPainter(color: border, radius: AppRadius.sm),
      child: Container(
        decoration: BoxDecoration(color: bg, borderRadius: AppRadius.smAll),
        padding: const EdgeInsetsDirectional.fromSTEB(8, 5, 10, 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_outlined, size: 18, color: fg),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius((Offset.zero & size).deflate(0.75), Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const dash = 4.0, gap = 3.0;
    for (final PathMetric m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) => old.color != color || old.radius != radius;
}

/// Small rounded pill with an icon and a text label. Status is never conveyed
/// by colour alone: there is always an icon and a word.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
    this.border,
  });

  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 10, 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.all(Radius.circular(100)),
        border: border == null ? null : Border.all(color: border!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Offline ready" indicator shown on Home.
class OfflineChip extends StatelessWidget {
  const OfflineChip({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return StatusPill(
      icon: Icons.offline_pin_outlined,
      label: l.offlineReady,
      foreground: AppColors.onSuccessContainer,
      background: AppColors.successContainer,
    );
  }
}
