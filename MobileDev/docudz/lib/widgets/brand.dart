import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// DocuDZ logo mark: a document with a folded corner and an apricot tick, on a
/// teal tile. Pure vector (CustomPaint): zero image assets, crisp at any size,
/// and deliberately free of flags, stars, crescents or official emblems.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 40, this.onDark = false});

  final double size;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'DocuDZ',
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _BrandMarkPainter(onDark: onDark)),
      ),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  _BrandMarkPainter({required this.onDark});

  final bool onDark;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    // Tile
    final tile = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(s * 0.28));
    canvas.drawRRect(tile, Paint()..color = onDark ? Colors.white : AppColors.primary);

    // Document sheet with folded top-right corner
    final l = s * 0.27, t = s * 0.2, r = s * 0.73, b = s * 0.8, fold = s * 0.14, rad = s * 0.06;
    final sheet = Path()
      ..moveTo(l + rad, t)
      ..lineTo(r - fold, t)
      ..lineTo(r, t + fold)
      ..lineTo(r, b - rad)
      ..quadraticBezierTo(r, b, r - rad, b)
      ..lineTo(l + rad, b)
      ..quadraticBezierTo(l, b, l, b - rad)
      ..lineTo(l, t + rad)
      ..quadraticBezierTo(l, t, l + rad, t)
      ..close();
    canvas.drawPath(sheet, Paint()..color = onDark ? AppColors.primary : Colors.white);

    // Fold
    final foldPath = Path()
      ..moveTo(r - fold, t)
      ..lineTo(r - fold, t + fold)
      ..lineTo(r, t + fold)
      ..close();
    canvas.drawPath(foldPath, Paint()..color = onDark ? AppColors.primaryDark : AppColors.primaryContainer);

    // Two text lines
    final line = Paint()
      ..color = onDark ? AppColors.mintOnDark : AppColors.hairline
      ..strokeWidth = s * 0.045
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(l + s * 0.08, t + s * 0.16), Offset(r - fold - s * 0.04, t + s * 0.16), line);
    canvas.drawLine(Offset(l + s * 0.08, t + s * 0.27), Offset(r - s * 0.08, t + s * 0.27), line);

    // Tick
    final tick = Path()
      ..moveTo(l + s * 0.09, b - s * 0.2)
      ..lineTo(l + s * 0.19, b - s * 0.1)
      ..lineTo(r - s * 0.07, b - s * 0.3);
    canvas.drawPath(
      tick,
      Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.085
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _BrandMarkPainter old) => old.onDark != onDark;
}

/// "DocuDZ" wordmark. Always Latin script and left-to-right, in every locale.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.fontSize = 20, this.onDark = false});

  final double fontSize;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontFamily: AppFonts.latin,
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.4,
      height: 1.1,
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Docu',
            style: base.copyWith(color: onDark ? Colors.white : AppColors.ink),
          ),
          TextSpan(
            text: 'DZ',
            style: base.copyWith(color: onDark ? AppColors.accent : AppColors.primary),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    );
  }
}
