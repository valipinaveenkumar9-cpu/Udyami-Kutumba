import 'package:flutter/material.dart';

class WaterFlow extends StatelessWidget {
  const WaterFlow({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: size.height * 0.22,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(
            height: size.height * 0.22,
            width: double.infinity,
            child: CustomPaint(
              painter: _WaterFlowPainter(
                color1: theme.colorScheme.primary, // Navy layer
                color2: theme.colorScheme.secondary, // Teal layer
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.03, // Adjust padding from bottom
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 32, height: 1, color: Theme.of(context).colorScheme.surface.withOpacity(0.2)),
                    const SizedBox(width: 12),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.shield, color: theme.colorScheme.primary, size: 28),
                        Icon(Icons.shield_outlined, color: theme.colorScheme.secondary, size: 28),
                        Icon(Icons.star, color: Theme.of(context).colorScheme.surface, size: 12),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Container(width: 32, height: 1, color: Theme.of(context).colorScheme.surface.withOpacity(0.2)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'EMPOWERING ENTERPRISES.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.surface, 
                    fontSize: 10, 
                    letterSpacing: 2.5, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'BUILDING A STRONG NATION.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.surface, 
                    fontSize: 9, 
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterFlowPainter extends CustomPainter {
  final Color color1;
  final Color color2;
  _WaterFlowPainter({required this.color1, required this.color2});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = color1
      ..style = PaintingStyle.fill;
      
    final paint2 = Paint()
      ..color = color2
      ..style = PaintingStyle.fill;

    // Helper to generate perfectly smooth, symmetrical waves
    Path generateWavePath(double yOffset) {
      Path path = Path();
      // Edge is higher up
      path.moveTo(0, size.height * 0.4 + yOffset); 
      
      // Left Trough to Smooth Center Hill
      path.cubicTo(
        size.width * 0.20, size.height * 0.80 + yOffset, // Shallow smooth trough
        size.width * 0.40, size.height * 0.35 + yOffset, // Approach center horizontally
        size.width * 0.50, size.height * 0.35 + yOffset, // Center peak (flat top)
      );
      
      // Center Hill to Right Trough
      path.cubicTo(
        size.width * 0.60, size.height * 0.35 + yOffset, // Leave center horizontally
        size.width * 0.80, size.height * 0.80 + yOffset, // Shallow smooth trough
        size.width, size.height * 0.40 + yOffset,        // Edge
      );
      
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      return path;
    }

    // --- Back Wave (Teal/Secondary Ribbon Edge) ---
    // Drawn first, slightly higher up
    canvas.drawPath(generateWavePath(0.0), paint2);

    // --- Front Wave (Navy/Primary Solid Base) ---
    // Drawn second, identical shape but shifted down to expose the teal border
    canvas.drawPath(generateWavePath(size.height * 0.05), paint1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
