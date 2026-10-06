import 'package:flutter/material.dart';

class TopLeftBlob extends StatelessWidget {
  const TopLeftBlob({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).size.height * 0.3,
      child: CustomPaint(
        painter: _TopDecorationPainter(
          primary: Theme.of(context).colorScheme.primary,
          secondary: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}

class _TopDecorationPainter extends CustomPainter {
  final Color primary;
  final Color secondary;
  
  _TopDecorationPainter({required this.primary, required this.secondary});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Top Left Blob (Solid Primary/Navy)
    final blobPaint = Paint()
      ..color = primary
      ..style = PaintingStyle.fill;
      
    Path blobPath = Path();
    blobPath.lineTo(0, size.height * 0.6);
    blobPath.quadraticBezierTo(size.width * 0.15, size.height * 0.6, size.width * 0.2, size.height * 0.35);
    blobPath.quadraticBezierTo(size.width * 0.25, size.height * 0.1, size.width * 0.5, 0);
    blobPath.close();
    canvas.drawPath(blobPath, blobPaint);

    // 2. Top Left Thin Outline (Secondary/Teal overlap)
    final linePaint = Paint()
      ..color = secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
      
    Path linePath = Path();
    linePath.moveTo(0, size.height * 0.85);
    linePath.cubicTo(
      size.width * 0.15, size.height * 0.85,
      size.width * 0.10, size.height * 0.3,
      size.width * 0.3, 0
    );
    canvas.drawPath(linePath, linePaint);

    // 3. Top Right Halftone Dots (Secondary fade)
    final dotPaint = Paint()
      ..style = PaintingStyle.fill;
      
    double dotRadius = 3.0;
    double spacing = 18.0;
    
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        // Radial fade distance calculation
        double distance = (row * row) + (col * col).toDouble();
        if (distance < 45) {
          // Fade opacity out as it goes further left and down
          double alpha = 1.0 - (distance / 45);
          dotPaint.color = secondary.withAlpha((255 * 0.5 * alpha).toInt());
          
          // Shrink dots as they fade
          canvas.drawCircle(
            Offset(size.width - (col * spacing) - 15, (row * spacing) + 15),
            dotRadius * (alpha * 0.8 + 0.2), 
            dotPaint
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
