import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

// ============================================================
// PlatformBlock Component
// ============================================================
// 4b3: position - world coordinates of the platform
//      size - width and height of the platform
//      visibility - inherits from Component, can be toggled
//
// 4b6: Uses RectangleHitbox (Shape) for collision detection
//      This is a geometric Rectangle shape that the physics
//      system uses to detect overlaps with the player.
// ============================================================

enum PlatformType { normal, ice, crumble, bounce, goal }

class PlatformBlock extends PositionComponent with CollisionCallbacks {
  final PlatformType platformType;
  final Color color;
  
  PlatformBlock({
    required Vector2 position,
    required Vector2 size,
    this.platformType = PlatformType.normal,
    this.color = const Color(0xFF3a3a5a),
  }) : super(
    position: position,
    size: size,
    anchor: Anchor.topLeft,
  );

  @override
  Future<void> onLoad() async {
    // 4b6: RectangleHitbox - a Rectangle Shape for collision
    add(RectangleHitbox());
  }

  // 4b2: render - draws the platform each frame
  @override
  void render(Canvas canvas) {
    final paint = Paint();
    
    switch (platformType) {
      case PlatformType.normal:
        // Stone platform
        paint.color = const Color(0xFF4a4a6a);
        canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
        // Top highlight
        paint.color = const Color(0xFF5a5a8a);
        canvas.drawRect(Rect.fromLTWH(0, 0, size.x, 3), paint);
        // Pixel details
        paint.color = const Color(0xFF3a3a5a);
        for (double x = 4; x < size.x - 4; x += 12) {
          canvas.drawRect(Rect.fromLTWH(x, 4, 2, 2), paint);
        }
        break;
        
      case PlatformType.ice:
        paint.color = const Color(0xFF80c0e0);
        canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
        paint.color = const Color(0xFFa0e0ff);
        canvas.drawRect(Rect.fromLTWH(0, 0, size.x, 2), paint);
        // Ice shine
        paint.color = const Color(0xFFffffff).withOpacity(0.3);
        canvas.drawRect(Rect.fromLTWH(4, 2, 8, 2), paint);
        break;
        
      case PlatformType.crumble:
        paint.color = const Color(0xFF8a6a4a);
        canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
        // Cracks
        paint.color = const Color(0xFF6a4a2a);
        canvas.drawRect(Rect.fromLTWH(size.x * 0.3, 0, 2, size.y), paint);
        canvas.drawRect(Rect.fromLTWH(size.x * 0.7, 2, 2, size.y - 2), paint);
        break;
        
      case PlatformType.bounce:
        paint.color = const Color(0xFF50c050);
        canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
        paint.color = const Color(0xFF70e070);
        canvas.drawRect(Rect.fromLTWH(0, 0, size.x, 3), paint);
        // Spring coil detail
        paint.color = const Color(0xFF40a040);
        for (double x = 6; x < size.x - 6; x += 8) {
          canvas.drawRect(Rect.fromLTWH(x, size.y - 4, 4, 2), paint);
        }
        break;
        
      case PlatformType.goal:
        // Golden goal platform
        paint.color = const Color(0xFFf0c040);
        canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
        paint.color = const Color(0xFFffe070);
        canvas.drawRect(Rect.fromLTWH(0, 0, size.x, 3), paint);
        // Star details
        paint.color = const Color(0xFFffa020);
        for (double x = 8; x < size.x - 8; x += 16) {
          canvas.drawRect(Rect.fromLTWH(x, 4, 4, 4), paint);
        }
        break;
    }
    
    // Side borders for all
    paint.color = const Color(0xFF2a2a4a);
    canvas.drawRect(Rect.fromLTWH(0, 0, 2, size.y), paint);
    canvas.drawRect(Rect.fromLTWH(size.x - 2, 0, 2, size.y), paint);
  }
}
