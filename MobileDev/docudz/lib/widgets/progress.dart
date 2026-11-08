import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Rounded linear progress bar. Static (no implicit animation) to stay cheap
/// on low-end GPUs; direction-aware so it fills from the right in Arabic.
class DocuProgressBar extends StatelessWidget {
  const DocuProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.color = AppColors.primary,
    this.trackColor = AppColors.surfaceHigh,
    this.semanticsLabel,
  });

  final double value;
  final double height;
  final Color color;
  final Color trackColor;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return Semantics(
      label: semanticsLabel,
      value: '${(v * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: SizedBox(
          height: height,
          child: Stack(
            children: [
              Positioned.fill(child: ColoredBox(color: trackColor)),
              FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: v,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(height)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact ring showing "done/total" in its centre.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.done,
    required this.total,
    this.size = 56,
    this.color = AppColors.primary,
    this.semanticsLabel,
  });

  final int done;
  final int total;
  final double size;
  final Color color;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final value = total == 0 ? 0.0 : done / total;
    final complete = total > 0 && done == total;
    return Semantics(
      label: semanticsLabel,
      excludeSemantics: semanticsLabel != null,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(
            value: value,
            color: color,
            // Progress travels counter-clockwise in right-to-left layouts.
            mirrored: Directionality.of(context) == TextDirection.rtl,
          ),
          child: Center(
            child: complete
                ? Icon(Icons.check_rounded, color: color, size: size * 0.45)
                : Text(
                    '$done/$total',
                    textDirection: TextDirection.ltr,
                    style: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(fontWeight: FontWeight.w800, color: AppColors.ink, fontFamily: AppFonts.latin),
                  ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.color, required this.mirrored});

  final double value;
  final Color color;
  final bool mirrored;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 5.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = AppColors.surfaceHigh
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    if (value > 0) {
      if (mirrored) {
        canvas.translate(size.width, 0);
        canvas.scale(-1, 1);
      }
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * value,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value || old.color != color || old.mirrored != mirrored;
}
