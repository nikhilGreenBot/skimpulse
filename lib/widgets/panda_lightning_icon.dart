import 'package:flutter/material.dart';
import '../theme.dart';

class PandaLightningIcon extends StatelessWidget {
  final double size;
  final bool showShadow;
  final bool showBlueBackground;

  const PandaLightningIcon({
    super.key,
    required this.size,
    this.showShadow = true,
    this.showBlueBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _PandaIconPainter(
        showShadow: showShadow,
        showBlueBackground: showBlueBackground,
      ),
    );
  }
}

class _PandaIconPainter extends CustomPainter {
  final bool showShadow;
  final bool showBlueBackground;

  _PandaIconPainter({required this.showShadow, required this.showBlueBackground});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;

    // Background circle with subtle radial depth
    if (showBlueBackground) {
      final Rect bgRect = Rect.fromCircle(center: center, radius: radius);
      final Paint bgPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.2, -0.2),
          radius: 1.0,
          colors: [
            AppTheme.lightBlue,
            AppTheme.primaryBlue,
            AppTheme.darkBlue,
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(bgRect);
      canvas.drawCircle(center, radius, bgPaint);

      // Vignette for extra depth
      final Paint vignette = Paint()
        ..shader = RadialGradient(
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.12)],
          stops: const [0.75, 1.0],
        ).createShader(bgRect);
      canvas.drawCircle(center, radius, vignette);
    }

    // Lightning bolt behind face
    final double lightningSize = size.width * 0.44;
    final Rect lRect = Rect.fromCenter(
      center: center.translate(0, size.height * 0.02),
      width: lightningSize,
      height: lightningSize,
    );
    final Path bolt = _lightningPath(lRect);

    // Soft shadow for lightning
    final Paint boltShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
    canvas.save();
    canvas.translate(0, size.height * 0.02);
    canvas.drawPath(bolt, boltShadow);
    canvas.restore();

    final Paint boltPaint = Paint()
      ..color = AppTheme.primaryYellow
      ..style = PaintingStyle.fill;
    canvas.drawPath(bolt, boltPaint);

    // Panda face with radial highlight
    final double faceRadius = size.width * 0.34;
    final Rect faceRect = Rect.fromCircle(center: center, radius: faceRadius);
    final Paint facePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.2),
        radius: 1.0,
        colors: [Colors.white, const Color(0xFFF1F1F1)],
        stops: const [0.0, 1.0],
      ).createShader(faceRect);

    // Face shadow to add elevation
    if (showShadow) {
      final Paint faceShadow = Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.035);
      canvas.drawCircle(center.translate(0, size.height * 0.02), faceRadius, faceShadow);
    }
    canvas.drawCircle(center, faceRadius, facePaint);

    // Ears (top-left and top-right)
    final double earRadius = size.width * 0.11;
    final Offset earLeft = center + Offset(-faceRadius * 0.7, -faceRadius * 0.9);
    final Offset earRight = center + Offset(faceRadius * 0.7, -faceRadius * 0.9);
    final Paint earPaint = Paint()..color = Colors.black87;
    canvas.drawCircle(earLeft, earRadius, earPaint);
    canvas.drawCircle(earRight, earRadius, earPaint);

    // Eye patches
    final double patchRadius = faceRadius * 0.55;
    final Offset patchLeft = center + Offset(-faceRadius * 0.52, -faceRadius * 0.05);
    final Offset patchRight = center + Offset(faceRadius * 0.52, -faceRadius * 0.05);
    final Paint patchPaint = Paint()..color = const Color(0xFF2F2F2F);
    canvas.drawCircle(patchLeft, patchRadius * 0.55, patchPaint);
    canvas.drawCircle(patchRight, patchRadius * 0.55, patchPaint);

    // Eyes
    final Paint eyePaint = Paint()..color = Colors.black;
    final double eyeRadius = faceRadius * 0.16;
    canvas.drawCircle(patchLeft, eyeRadius, eyePaint);
    canvas.drawCircle(patchRight, eyeRadius, eyePaint);

    // Eye highlights
    final Paint glint = Paint()..color = Colors.white;
    final double glintRadius = eyeRadius * 0.35;
    canvas.drawCircle(patchLeft.translate(-eyeRadius * 0.25, -eyeRadius * 0.25), glintRadius, glint);
    canvas.drawCircle(patchRight.translate(-eyeRadius * 0.25, -eyeRadius * 0.25), glintRadius, glint);

    // Nose and mouth
    final Paint nosePaint = Paint()..color = Colors.black87;
    final double noseRadius = faceRadius * 0.08;
    final Offset noseCenter = center.translate(0, faceRadius * 0.2);
    canvas.drawCircle(noseCenter, noseRadius, nosePaint);
    final Paint mouthPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = size.width * 0.015
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(noseCenter.translate(0, noseRadius * 1.2), noseCenter.translate(0, noseRadius * 1.8), mouthPaint);

    // Subtle face outline
    final Paint outline = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.015;
    canvas.drawCircle(center, faceRadius, outline);
  }

  Path _lightningPath(Rect r) {
    final Path p = Path();
    p.moveTo(r.center.dx, r.top + r.height * 0.05);
    p.lineTo(r.left + r.width * 0.35, r.top + r.height * 0.25);
    p.lineTo(r.left + r.width * 0.45, r.top + r.height * 0.35);
    p.lineTo(r.left + r.width * 0.25, r.top + r.height * 0.55);
    p.lineTo(r.left + r.width * 0.4, r.top + r.height * 0.65);
    p.lineTo(r.left + r.width * 0.3, r.top + r.height * 0.85);
    p.lineTo(r.center.dx, r.top + r.height * 0.95);
    p.lineTo(r.left + r.width * 0.7, r.top + r.height * 0.85);
    p.lineTo(r.left + r.width * 0.6, r.top + r.height * 0.65);
    p.lineTo(r.left + r.width * 0.75, r.top + r.height * 0.55);
    p.lineTo(r.left + r.width * 0.55, r.top + r.height * 0.35);
    p.lineTo(r.left + r.width * 0.65, r.top + r.height * 0.25);
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(covariant _PandaIconPainter oldDelegate) {
    return oldDelegate.showShadow != showShadow || oldDelegate.showBlueBackground != showBlueBackground;
  }
}

