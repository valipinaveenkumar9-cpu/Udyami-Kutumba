import 'package:flutter/material.dart';

class IndiaSkyline extends StatelessWidget {
  final double opacity;
  const IndiaSkyline({super.key, this.opacity = 0.06});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned(
      bottom: size.height * 0.09, // Moved up to sit exactly above the water flow peak
      left: 0,
      right: 0,
      height: size.height * 0.25, // Increased height to provide huge sky space for mountains
      child: CustomPaint(
        painter: _IndiaSkylinePainter(
          color: Theme.of(context).colorScheme.secondary.withOpacity(opacity),
        ),
      ),
    );
  }
}

class _IndiaSkylinePainter extends CustomPainter {
  final Color color;
  _IndiaSkylinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Massive Mountains in the far background
    final mountainPaint = Paint()
      ..color = color.withAlpha((color.alpha * 0.25).toInt()) // Faint for atmospheric depth
      ..style = PaintingStyle.fill;
      
    Path mountainPath = Path();
    
    // 1. Left Mountain (0% to 40%)
    mountainPath.moveTo(0, size.height);
    mountainPath.lineTo(0, size.height * 0.4); // Start higher on the left edge
    mountainPath.quadraticBezierTo(
      size.width * 0.15, size.height * 0.1, // High peak
      size.width * 0.40, size.height // Ends and hides at 40% width
    );
    mountainPath.close(); // Complete left mountain shape
    
    // 2. Right Mountain (70% to 100%, taking up 30% of the screen width from the right)
    mountainPath.moveTo(size.width * 0.70, size.height); // Starts and hides at 70% width
    mountainPath.quadraticBezierTo(
      size.width * 0.85, size.height * 0.35, // Reduced mountain curve (lower peak)
      size.width, size.height * 0.55 // Ends mid-way up right edge
    );
    mountainPath.lineTo(size.width, size.height);
    mountainPath.close(); // Complete right mountain shape
    
    canvas.drawPath(mountainPath, mountainPaint);

    // 2. Setup Paints for Skyline Buildings
    final frontPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    final backPaint = Paint()
      ..color = color.withAlpha((color.alpha * 0.5).toInt())
      ..style = PaintingStyle.fill;

    // 3. Anchor and Scale Canvas for Buildings
    canvas.save();
    canvas.translate(0, size.height);
    // Scale vertically to 0.44 to restore the user's preferred short 0.10 height minus a 2% reduction
    canvas.scale(1.0, 0.44); 
    canvas.translate(0, -size.height);

    // Helper to draw filler generic buildings to make it a continuous skyline
    void addCityBlocks(Path path, double minH, double maxH, int count, List<int> pattern) {
      double step = 1.0 / count;
      for (int i = 0; i < count; i++) {
        double w = step * 0.85; 
        double h = minH + (pattern[i % pattern.length] / 10.0) * (maxH - minH);
        path.addRect(Rect.fromLTRB(
          size.width * (i * step), 
          size.height * h, 
          size.width * (i * step + w), 
          size.height
        ));
      }
    }

    // --- BACK LAYER ---
    Path backBase = Path();
    backBase.addRect(Rect.fromLTRB(0, size.height * 0.85, size.width, size.height));
    Path backBuildings = Path();

    // Generic city blocks for depth
    addCityBlocks(backBuildings, 0.4, 0.85, 50, [2, 5, 1, 8, 3, 6, 0, 4, 7]);

    // Hawa Mahal (Back Left)
    backBuildings.addPolygon([
      Offset(size.width * 0.05, size.height),
      Offset(size.width * 0.07, size.height * 0.4),
      Offset(size.width * 0.08, size.height * 0.4),
      Offset(size.width * 0.10, size.height * 0.1), // Peak
      Offset(size.width * 0.12, size.height * 0.4),
      Offset(size.width * 0.13, size.height * 0.4),
      Offset(size.width * 0.15, size.height),
    ], true);

    // Qutub Minar (Back Mid-Left, Tall)
    backBuildings.addPolygon([
      Offset(size.width * 0.22, size.height),
      Offset(size.width * 0.235, size.height * 0.05),
      Offset(size.width * 0.245, size.height * 0.05),
      Offset(size.width * 0.26, size.height),
    ], true);

    // Sanchi Stupa (Back Mid-Left)
    backBuildings.addOval(Rect.fromLTRB(size.width * 0.29, size.height * 0.4, size.width * 0.35, size.height * 0.9));

    // Red Fort (Back Center, Wide)
    backBuildings.addRect(Rect.fromLTRB(size.width * 0.38, size.height * 0.5, size.width * 0.62, size.height));
    backBuildings.addRect(Rect.fromLTRB(size.width * 0.38, size.height * 0.35, size.width * 0.41, size.height * 0.5));
    backBuildings.addRect(Rect.fromLTRB(size.width * 0.59, size.height * 0.35, size.width * 0.62, size.height * 0.5));
    backBuildings.addOval(Rect.fromLTRB(size.width * 0.38, size.height * 0.25, size.width * 0.41, size.height * 0.45));
    backBuildings.addOval(Rect.fromLTRB(size.width * 0.59, size.height * 0.25, size.width * 0.62, size.height * 0.45));

    // Lotus Temple (Back Mid-Right)
    backBuildings.addPath(_createLotus(Rect.fromLTRB(size.width * 0.68, size.height * 0.3, size.width * 0.82, size.height)), Offset.zero);

    // Statue of Unity (Back Right, Tall)
    backBuildings.addRect(Rect.fromLTRB(size.width * 0.89, size.height * 0.1, size.width * 0.92, size.height));

    Path backLayer = Path.combine(PathOperation.union, backBase, backBuildings);
    canvas.drawPath(backLayer, backPaint);

    // --- FRONT LAYER ---
    Path frontBase = Path();
    frontBase.addRect(Rect.fromLTRB(0, size.height * 0.95, size.width, size.height));
    Path frontBuildings = Path();
    Path frontHoles = Path();

    // Generic city blocks for foreground baseline
    addCityBlocks(frontBuildings, 0.65, 0.95, 40, [5, 1, 6, 2, 8, 3, 0]);

    // Charminar (Front Left)
    frontBuildings.addRect(Rect.fromLTRB(size.width * 0.02, size.height * 0.6, size.width * 0.13, size.height));
    frontBuildings.addRect(Rect.fromLTRB(size.width * 0.01, size.height * 0.2, size.width * 0.03, size.height));
    frontBuildings.addRect(Rect.fromLTRB(size.width * 0.12, size.height * 0.2, size.width * 0.14, size.height));
    frontBuildings.addRect(Rect.fromLTRB(size.width * 0.04, size.height * 0.4, size.width * 0.05, size.height * 0.6));
    frontBuildings.addRect(Rect.fromLTRB(size.width * 0.10, size.height * 0.4, size.width * 0.11, size.height * 0.6));
    frontHoles.addRRect(RRect.fromRectAndRadius(Rect.fromLTRB(size.width * 0.05, size.height * 0.75, size.width * 0.10, size.height), Radius.circular(size.width * 0.02)));

    // India Gate (Front Mid-Left)
    frontBuildings.addRect(Rect.fromLTRB(size.width * 0.18, size.height * 0.5, size.width * 0.30, size.height));
    frontBuildings.addRect(Rect.fromLTRB(size.width * 0.21, size.height * 0.45, size.width * 0.27, size.height * 0.5));
    frontHoles.addRRect(RRect.fromRectAndRadius(Rect.fromLTRB(size.width * 0.21, size.height * 0.7, size.width * 0.27, size.height), Radius.circular(size.width * 0.02)));

    // Golden Temple (Front Mid)
    frontBuildings.addRect(Rect.fromLTRB(size.width * 0.32, size.height * 0.7, size.width * 0.42, size.height));
    frontBuildings.addPath(_createDome(Rect.fromLTRB(size.width * 0.34, size.height * 0.5, size.width * 0.40, size.height * 0.7)), Offset.zero);

    // Taj Mahal (Front Center)
    frontBuildings.addRect(Rect.fromLTRB(size.width * 0.48, size.height * 0.6, size.width * 0.62, size.height));
    frontBuildings.addRect(Rect.fromLTRB(size.width * 0.44, size.height * 0.25, size.width * 0.46, size.height));
    frontBuildings.addRect(Rect.fromLTRB(size.width * 0.64, size.height * 0.25, size.width * 0.66, size.height));
    frontBuildings.addPath(_createDome(Rect.fromLTRB(size.width * 0.51, size.height * 0.15, size.width * 0.59, size.height * 0.6)), Offset.zero);
    frontBuildings.addPath(_createDome(Rect.fromLTRB(size.width * 0.48, size.height * 0.4, size.width * 0.51, size.height * 0.6)), Offset.zero);
    frontBuildings.addPath(_createDome(Rect.fromLTRB(size.width * 0.59, size.height * 0.4, size.width * 0.62, size.height * 0.6)), Offset.zero);
    frontHoles.addRRect(RRect.fromRectAndRadius(Rect.fromLTRB(size.width * 0.53, size.height * 0.75, size.width * 0.57, size.height), Radius.circular(size.width * 0.015)));

    // Mysore Palace (Front Mid-Right)
    frontBuildings.addRect(Rect.fromLTRB(size.width * 0.68, size.height * 0.65, size.width * 0.78, size.height));
    frontBuildings.addPath(_createDome(Rect.fromLTRB(size.width * 0.71, size.height * 0.3, size.width * 0.75, size.height * 0.65)), Offset.zero);
    frontBuildings.addPath(_createDome(Rect.fromLTRB(size.width * 0.68, size.height * 0.5, size.width * 0.70, size.height * 0.65)), Offset.zero);
    frontBuildings.addPath(_createDome(Rect.fromLTRB(size.width * 0.76, size.height * 0.5, size.width * 0.78, size.height * 0.65)), Offset.zero);

    // Konark Sun Temple (Front Right)
    frontBuildings.addPolygon([
      Offset(size.width * 0.80, size.height),
      Offset(size.width * 0.81, size.height * 0.8),
      Offset(size.width * 0.805, size.height * 0.8),
      Offset(size.width * 0.82, size.height * 0.6),
      Offset(size.width * 0.815, size.height * 0.6),
      Offset(size.width * 0.84, size.height * 0.3),
      Offset(size.width * 0.865, size.height * 0.6),
      Offset(size.width * 0.86, size.height * 0.6),
      Offset(size.width * 0.875, size.height * 0.8),
      Offset(size.width * 0.87, size.height * 0.8),
      Offset(size.width * 0.88, size.height),
    ], true);

    // Gateway of India (Front Far-Right)
    frontBuildings.addRect(Rect.fromLTRB(size.width * 0.90, size.height * 0.5, size.width * 0.98, size.height));
    frontBuildings.addRect(Rect.fromLTRB(size.width * 0.90, size.height * 0.4, size.width * 0.91, size.height * 0.5));
    frontBuildings.addRect(Rect.fromLTRB(size.width * 0.925, size.height * 0.4, size.width * 0.935, size.height * 0.5));
    frontBuildings.addRect(Rect.fromLTRB(size.width * 0.945, size.height * 0.4, size.width * 0.955, size.height * 0.5));
    frontBuildings.addRect(Rect.fromLTRB(size.width * 0.97, size.height * 0.4, size.width * 0.98, size.height * 0.5));
    frontHoles.addRRect(RRect.fromRectAndRadius(Rect.fromLTRB(size.width * 0.92, size.height * 0.65, size.width * 0.96, size.height), Radius.circular(size.width * 0.02)));

    Path frontSkyline = Path.combine(PathOperation.union, frontBase, frontBuildings);
    Path finalFront = Path.combine(PathOperation.difference, frontSkyline, frontHoles);
    canvas.drawPath(finalFront, frontPaint);
    
    // 4. Restore Canvas Scale
    canvas.restore();
  }

  Path _createDome(Rect rect) {
    Path path = Path();
    path.moveTo(rect.left, rect.bottom);
    // Left side of bulbous dome
    path.cubicTo(
      rect.left - rect.width * 0.2, rect.top + rect.height * 0.3, 
      rect.center.dx, rect.top, 
      rect.center.dx, rect.top
    );
    // Right side of bulbous dome
    path.cubicTo(
      rect.center.dx, rect.top, 
      rect.right + rect.width * 0.2, rect.top + rect.height * 0.3, 
      rect.right, rect.bottom
    );
    path.close();
    return path;
  }
  
  Path _createLotus(Rect rect) {
    Path path = Path();
    // Outer petals
    path.moveTo(rect.left, rect.bottom);
    path.quadraticBezierTo(rect.center.dx, rect.top, rect.right, rect.bottom);
    // Inner taller petal
    path.moveTo(rect.left + rect.width * 0.25, rect.bottom);
    path.quadraticBezierTo(rect.center.dx, rect.top - rect.height * 0.2, rect.right - rect.width * 0.25, rect.bottom);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
