import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import '../game/bemenjump_game.dart';

// ============================================================
// BackgroundComponent
// ============================================================
// 4b10: Custom background colors and rendering
//       The background changes color based on altitude,
//       creating a sense of height progression.
//
// 4b3: position and size define where this renders
//      This component is always visible (visibility = true)
// ============================================================

class BackgroundComponent extends Component with HasGameReference<BemenJumpGame> {
  
  // Star positions for parallax effect
  final List<_Star> _stars = [];
  final Random _random = Random(42); // Fixed seed for consistent stars

  @override
  Future<void> onLoad() async {
    // 4b5: Generate star elements procedurally
    for (int i = 0; i < 200; i++) {
      _stars.add(_Star(
        x: _random.nextDouble() * 400,
        y: _random.nextDouble() * 4000 - 3000,
        size: _random.nextDouble() * 2 + 0.5,
        brightness: _random.nextDouble() * 0.5 + 0.3,
        parallaxFactor: _random.nextDouble() * 0.3 + 0.7,
      ));
    }
  }

  @override
  void render(Canvas canvas) {
    final cameraY = game.cam.viewfinder.position.y;
    
    // 4b10: Background gradient that changes with height
    // Lower = dark blue/purple, Higher = dark space black
    final heightProgress = ((600 - cameraY) / 3000).clamp(0.0, 1.0);
    
    // Interpolate colors based on height
    final topColor = Color.lerp(
      const Color(0xFF0a0a2a), // Low: dark blue
      const Color(0xFF050510), // High: near black (space)
      heightProgress,
    )!;
    final bottomColor = Color.lerp(
      const Color(0xFF1a0a30), // Low: dark purple
      const Color(0xFF0a0a1a), // High: very dark
      heightProgress,
    )!;
    
    // Draw gradient background
    final rect = Rect.fromLTWH(-200, cameraY - 400, 800, 800);
    final gradient = Paint()
      ..shader = Gradient.linear(
        Offset(0, rect.top),
        Offset(0, rect.bottom),
        [topColor, bottomColor],
      );
    canvas.drawRect(rect, gradient);
    
    // Draw stars with parallax
    for (final star in _stars) {
      final starY = star.y + cameraY * (1 - star.parallaxFactor);
      // Only draw visible stars
      if (starY > cameraY - 500 && starY < cameraY + 500) {
        final twinkle = (sin((cameraY + star.x) * 0.01) * 0.3 + 0.7).clamp(0.0, 1.0);
        final paint = Paint()
          ..color = Color.fromRGBO(
            255, 255, 255,
            star.brightness * twinkle,
          );
        canvas.drawRect(
          Rect.fromLTWH(star.x, starY, star.size, star.size),
          paint,
        );
      }
    }
    
    // Walls on the sides
    final wallPaint = Paint()..color = const Color(0xFF1a1a3a);
    canvas.drawRect(Rect.fromLTWH(-10, cameraY - 400, 15, 800), wallPaint);
    canvas.drawRect(Rect.fromLTWH(395, cameraY - 400, 15, 800), wallPaint);
    
    // Wall detail
    final detailPaint = Paint()..color = const Color(0xFF2a2a5a);
    for (double y = ((cameraY - 400) / 30).floorToDouble() * 30; 
         y < cameraY + 400; y += 30) {
      canvas.drawRect(Rect.fromLTWH(-8, y, 2, 2), detailPaint);
      canvas.drawRect(Rect.fromLTWH(397, y, 2, 2), detailPaint);
    }
  }
}

class _Star {
  final double x, y, size, brightness, parallaxFactor;
  _Star({
    required this.x, required this.y, required this.size,
    required this.brightness, required this.parallaxFactor,
  });
}
