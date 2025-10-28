import 'package:flutter/material.dart';

class CrocodileIcon extends StatelessWidget {
  final double size;
  final bool showShadow;

  const CrocodileIcon({
    super.key,
    required this.size,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.asset(
          'assets/images/1746059802366.jpg',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(size / 2),
              ),
              child: Icon(
                Icons.image_not_supported,
                size: size * 0.5,
                color: Colors.grey[600],
              ),
            );
          },
        ),
      ),
    );
  }
}

