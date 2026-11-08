import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'chips.dart';

/// Static, network-free stand-in for a map: a few vector "streets" and a pin.
/// Costs nothing to render and makes clear that the real map opens elsewhere.
class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({super.key, this.height = 156});

  final double height;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _StreetsPainter())),
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 28),
              child: Icon(Icons.location_on_rounded, size: 44, color: AppColors.primary),
            ),
          ),
          PositionedDirectional(
            start: AppSpacing.sm,
            bottom: AppSpacing.sm,
            end: AppSpacing.sm,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: StatusPill(
                icon: Icons.cloud_off_rounded,
                label: l.mapOfflineCaption,
                foreground: AppColors.inkMuted,
                background: AppColors.card.withValues(alpha: 0.92),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreetsPainter extends CustomPainter {
  const _StreetsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFE9F1EE));
    final block = Paint()..color = const Color(0xFFDCE8E4);
    final w = size.width, h = size.height;
    for (final r in [
      Rect.fromLTWH(w * 0.05, h * 0.1, w * 0.22, h * 0.3),
      Rect.fromLTWH(w * 0.35, h * 0.08, w * 0.18, h * 0.22),
      Rect.fromLTWH(w * 0.62, h * 0.12, w * 0.3, h * 0.26),
      Rect.fromLTWH(w * 0.08, h * 0.58, w * 0.25, h * 0.34),
      Rect.fromLTWH(w * 0.66, h * 0.55, w * 0.26, h * 0.35),
    ]) {
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)), block);
    }
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, h * 0.48), Offset(w, h * 0.44), road);
    canvas.drawLine(Offset(w * 0.58, 0), Offset(w * 0.52, h), road);
    final minor = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.3, 0), Offset(w * 0.34, h), minor);
    canvas.drawLine(Offset(0, h * 0.2), Offset(w, h * 0.16), minor);
    canvas.drawLine(Offset(w * 0.8, 0), Offset(w * 0.86, h), minor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// "Open now · closes at 16:00" / "Closed today" indicator.
class OpenStatusPill extends StatelessWidget {
  const OpenStatusPill({super.key, required this.office, required this.now});

  final Office office;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final today = office.hours[now.weekday];
    switch (office.stateAt(now)) {
      case OpenState.openNow:
        return StatusPill(
          icon: Icons.schedule_rounded,
          label: '${l.openNow} · ${l.closesAt(today!.endLabel)}',
          foreground: AppColors.onSuccessContainer,
          background: AppColors.successContainer,
        );
      case OpenState.closedNow:
        final opensLater = today != null && now.hour * 60 + now.minute < today.start;
        return StatusPill(
          icon: Icons.schedule_rounded,
          label: opensLater ? '${l.closedNow} · ${l.opensAt(today.startLabel)}' : l.closedNow,
          foreground: AppColors.onWarningContainer,
          background: AppColors.warningContainer,
        );
      case OpenState.closedToday:
        return StatusPill(
          icon: Icons.event_busy_rounded,
          label: l.closedToday,
          foreground: AppColors.onErrorContainer,
          background: AppColors.errorContainer,
        );
    }
  }
}

/// Week table starting on Sunday (Algerian working week: Sunday to Thursday).
class OpeningHoursTable extends StatelessWidget {
  const OpeningHoursTable({super.key, required this.office, required this.now});

  final Office office;
  final DateTime now;

  static const _order = [
    DateTime.sunday,
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
    DateTime.saturday,
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final t = Theme.of(context).textTheme;
    return Column(
      children: [
        for (final day in _order)
          Builder(
            builder: (context) {
              final isToday = day == now.weekday;
              final range = office.hours[day];
              final style = (isToday ? t.titleSmall : t.bodyLarge)?.copyWith(
                color: range == null ? AppColors.inkMuted : AppColors.ink,
              );
              return Container(
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isToday ? AppColors.primaryContainer.withValues(alpha: 0.6) : null,
                  borderRadius: AppRadius.smAll,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(child: Text(fmt.weekday(day), style: style)),
                          if (isToday) ...[
                            const SizedBox(width: AppSpacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.all(Radius.circular(100)),
                              ),
                              child: Text(l.today, style: t.labelSmall?.copyWith(color: Colors.white)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      range == null ? l.closed : '${range.startLabel} – ${range.endLabel}',
                      style: style?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
