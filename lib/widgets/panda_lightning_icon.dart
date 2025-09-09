import 'package:flutter/material.dart';
import '../theme.dart';
import 'lightning_painter.dart';

class PandaLightningIcon extends StatelessWidget {
  final double size;
  final bool showShadow;

  const PandaLightningIcon({super.key, required this.size, this.showShadow = true});

  @override
  Widget build(BuildContext context) {
    final double faceSize = size * (80.0 / 120.0);
    final double earSize = size * (25.0 / 120.0);
    final double earTop = size * (5.0 / 120.0);
    final double earInset = size * (15.0 / 120.0);
    final double lightningSize = size * (40.0 / 120.0);
    final double blur = size * (20.0 / 120.0);
    final double yOffset = size * (10.0 / 120.0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: blur,
                  offset: Offset(0, yOffset),
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: faceSize,
            height: faceSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          Positioned(
            top: earTop,
            left: earInset,
            child: Container(
              width: earSize,
              height: earSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black87,
              ),
            ),
          ),
          Positioned(
            top: earTop,
            right: earInset,
            child: Container(
              width: earSize,
              height: earSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black87,
              ),
            ),
          ),
          CustomPaint(
            size: Size(lightningSize, lightningSize),
            painter: LightningPainter(),
          ),
        ],
      ),
    );
  }
}


