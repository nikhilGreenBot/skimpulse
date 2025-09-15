import 'package:flutter/material.dart';
import '../theme.dart';

class LightningPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryYellow
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.05);
    path.lineTo(size.width * 0.35, size.height * 0.25);
    path.lineTo(size.width * 0.45, size.height * 0.35);
    path.lineTo(size.width * 0.25, size.height * 0.55);
    path.lineTo(size.width * 0.4, size.height * 0.65);
    path.lineTo(size.width * 0.3, size.height * 0.85);
    path.lineTo(size.width * 0.5, size.height * 0.95);
    path.lineTo(size.width * 0.7, size.height * 0.85);
    path.lineTo(size.width * 0.6, size.height * 0.65);
    path.lineTo(size.width * 0.75, size.height * 0.55);
    path.lineTo(size.width * 0.55, size.height * 0.35);
    path.lineTo(size.width * 0.65, size.height * 0.25);
    path.lineTo(size.width * 0.5, size.height * 0.05);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


