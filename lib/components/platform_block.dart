import 'dart:math';
import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

// ============================================================
// PlatformBlock — Castle-themed platform rendering
// 4b3: position and size from PositionComponent
// 4b6: RectangleHitbox = geometric Shape for collision
//
// Types (castle theme):
//   normal   → Carved stone blocks with mortar
//   ice      → Wooden bridge planks with iron nails
//   crumble  → Crumbling stone — ragged edges, cracks
//   bounce   → Magic rune circle — glowing purple
//   goal     → Royal golden shrine with sparkles
// ============================================================

enum PlatformType { normal, ice, crumble, bounce, goal }

class PlatformBlock extends PositionComponent with CollisionCallbacks {
  final PlatformType platformType;
  final Color color; // kept for compatibility, not used directly

  PlatformBlock({
    required Vector2 position,
    required Vector2 size,
    this.platformType = PlatformType.normal,
    this.color = const Color(0xFF3a3a5a),
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  void _r(Canvas c, Paint p, double x, double y, double w, double h) =>
      c.drawRect(Rect.fromLTWH(x, y, w, h), p);

  // 4b2: render — draws the platform each frame
  @override
  void render(Canvas canvas) {
    switch (platformType) {
      case PlatformType.normal:
        _renderStoneBrick(canvas);
      case PlatformType.ice:
        _renderWoodenPlanks(canvas);
      case PlatformType.crumble:
        _renderCrumblingStone(canvas);
      case PlatformType.bounce:
        _renderMagicRune(canvas);
      case PlatformType.goal:
        _renderRoyalShrine(canvas);
    }
  }

  // ── Castle stone brick ───────────────────────────────────────
  void _renderStoneBrick(Canvas canvas) {
    final p = Paint();
    final w = size.x, h = size.y;

    // Base body
    p.color = const Color(0xFF3e3e52);
    _r(canvas, p, 0, 0, w, h);

    // Top coping stone (lighter surface)
    p.color = const Color(0xFF5a5a72);
    _r(canvas, p, 0, 0, w, 3);
    // Coping highlight
    p.color = const Color(0xFF6a6a84);
    _r(canvas, p, 1, 0, w - 2, 1);

    // Brick mortar pattern (horizontal)
    p.color = const Color(0xFF28283a);
    _r(canvas, p, 0, 7, w, 1);

    // Vertical mortar lines — row 1 (y 3-7)
    const brickW = 22.0;
    p.color = const Color(0xFF28283a);
    for (double bx = brickW; bx < w - 2; bx += brickW) {
      _r(canvas, p, bx, 3, 1, 4);
    }
    // Vertical mortar lines — row 2 (y 8-12), offset by half
    for (double bx = brickW * 0.5; bx < w - 2; bx += brickW) {
      _r(canvas, p, bx, 8, 1, 4);
    }

    // Stone texture variation — slightly different tones per "stone"
    p.color = const Color(0xFF424258);
    for (double bx = 2; bx < w - 2; bx += brickW) {
      if (((bx / brickW).floor() % 3) == 1) {
        _r(canvas, p, bx + 1, 3, brickW - 3, 4);
      }
    }

    // Bottom shadow
    p.color = const Color(0xFF242436);
    _r(canvas, p, 0, h - 3, w, 3);
    p.color = const Color(0xFF1c1c2c);
    _r(canvas, p, 0, h - 1, w, 1);

    // Side borders
    p.color = const Color(0xFF2e2e42);
    _r(canvas, p, 0, 0, 2, h);
    _r(canvas, p, w - 2, 0, 2, h);
  }

  // ── Wooden bridge planks ─────────────────────────────────────
  void _renderWoodenPlanks(Canvas canvas) {
    final p = Paint();
    final w = size.x, h = size.y;

    // Top edge (light wood tone)
    p.color = const Color(0xFFa87848);
    _r(canvas, p, 0, 0, w, 2);
    p.color = const Color(0xFFc09060);
    _r(canvas, p, 1, 0, w - 2, 1); // highlight

    // Plank 1 (y 2–6)
    p.color = const Color(0xFF8a6038);
    _r(canvas, p, 0, 2, w, 4);
    // Wood grain lines
    p.color = const Color(0xFF7a5028);
    for (double gx = 8; gx < w - 4; gx += 14) {
      _r(canvas, p, gx, 3, 6, 1);
    }

    // Plank gap
    p.color = const Color(0xFF301808);
    _r(canvas, p, 0, 6, w, 1);

    // Plank 2 (y 7–11)
    p.color = const Color(0xFF7a5430);
    _r(canvas, p, 0, 7, w, 4);
    // Wood grain (offset)
    p.color = const Color(0xFF6a4420);
    for (double gx = 4; gx < w - 4; gx += 14) {
      _r(canvas, p, gx, 8, 8, 1);
    }

    // Bottom shadow
    p.color = const Color(0xFF4a2e10);
    _r(canvas, p, 0, 11, w, h - 11);
    p.color = const Color(0xFF3a1e08);
    _r(canvas, p, 0, h - 1, w, 1);

    // Iron nail heads at plank junctions
    p.color = const Color(0xFF808090);
    for (double nx = 12; nx < w - 6; nx += 20) {
      _r(canvas, p, nx, 4, 2, 2); // top row nails
      _r(canvas, p, nx + 10, 8, 2, 2); // bottom row nails (offset)
    }
    p.color = const Color(0xFF606070);
    for (double nx = 12; nx < w - 6; nx += 20) {
      _r(canvas, p, nx + 1, 5, 1, 1); // nail shadow
    }

    // Side borders (dark wood)
    p.color = const Color(0xFF5a3818);
    _r(canvas, p, 0, 0, 2, h);
    _r(canvas, p, w - 2, 0, 2, h);
  }

  // ── Crumbling stone ──────────────────────────────────────────
  void _renderCrumblingStone(Canvas canvas) {
    final p = Paint();
    final w = size.x, h = size.y;

    // Start with regular stone
    _renderStoneBrick(canvas);

    // Overlay cracks
    p.color = const Color(0xFF1a1a28);
    // Main crack diagonal
    _r(canvas, p, w * 0.3, 0, 1, h - 3);
    _r(canvas, p, w * 0.3 + 1, 4, 1, h - 7);
    _r(canvas, p, w * 0.3 - 1, 8, 2, 1);
    // Second crack
    _r(canvas, p, w * 0.65, 2, 1, h - 4);
    _r(canvas, p, w * 0.65 + 1, 6, 1, 3);

    // Crumbled chunks at bottom — irregular holes
    p.color = const Color(0xFF161622);
    final chunks = [
      (0.08, 1.0), (0.22, 2.0), (0.45, 1.5), (0.60, 2.0),
      (0.75, 1.5), (0.88, 2.5), (0.15, 1.5), (0.52, 1.0),
    ];
    for (final (xFrac, chunkW) in chunks) {
      _r(canvas, p, w * xFrac, h - 3, chunkW, 3);
    }

    // Dust/debris at very bottom
    p.color = const Color(0xFF2a2a3a);
    for (double dx = 4; dx < w - 4; dx += 7) {
      if ((dx / 7).floor() % 3 != 0) {
        _r(canvas, p, dx, h - 1, 2, 1);
      }
    }
  }

  // ── Magic rune circle ────────────────────────────────────────
  void _renderMagicRune(Canvas canvas) {
    final p = Paint();
    final w = size.x, h = size.y;

    // Stone base
    _renderStoneBrick(canvas);

    // Time-based pulse animation (4b6 arithmetic: sin wave)
    final t = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final pulse = (sin(t * 2.2 + position.x * 0.05) * 0.3 + 0.7).clamp(0.4, 1.0);
    final pulse2 = (sin(t * 3.1 + position.y * 0.03) * 0.25 + 0.75).clamp(0.5, 1.0);

    // Glowing rune circle on top surface
    final cx = w / 2, cy = h / 2 - 1;
    final r1 = (w * 0.32).clamp(8.0, 28.0);
    final r2 = (w * 0.22).clamp(5.0, 18.0);

    // Outer glow ring
    p.shader = Gradient.radial(
      Offset(cx, cy),
      r1 + 10,
      [
        Color.fromRGBO(120, 60, 220, 0.0),
        Color.fromRGBO(140, 80, 240, 0.22 * pulse),
        Color.fromRGBO(180, 100, 255, 0.40 * pulse),
        Color.fromRGBO(200, 120, 255, 0.20 * pulse),
        Color.fromRGBO(220, 140, 255, 0.0),
      ],
      [0.0, 0.4, 0.65, 0.85, 1.0],
    );
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: (r1 + 10) * 2, height: h * 1.1), p);
    p.shader = null;

    // Circle outline (drawn as thick border approximation with nested ovals)
    p.color = Color.fromRGBO(160, 90, 240, 0.8 * pulse);
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 1.5;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, 2), width: r1 * 2, height: 4), p);
    p.style = PaintingStyle.fill;

    // Inner rune marks (simplified as small lit rectangles)
    p.color = Color.fromRGBO(200, 150, 255, 0.75 * pulse2);
    // Four rune marks around the circle
    final marks = [
      (cx - r2, 1.0),
      (cx + r2 - 2, 1.0),
      (cx - 1, 1.0),
      (cx + r2 * 0.6, 2.0),
    ];
    for (final (mx, my) in marks) {
      _r(canvas, p, mx, my, 2, 2);
    }

    // Center gem glow
    p.color = Color.fromRGBO(230, 180, 255, 0.9 * pulse);
    _r(canvas, p, cx - 1, 1, 3, 2);
  }

  // ── Royal golden shrine ──────────────────────────────────────
  void _renderRoyalShrine(Canvas canvas) {
    final p = Paint();
    final w = size.x, h = size.y;
    final t = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final pulse = (sin(t * 2.8) * 0.2 + 0.8).clamp(0.6, 1.0);

    // Golden base
    p.color = const Color(0xFFa07820);
    _r(canvas, p, 0, 0, w, h);

    // Gold highlights (multiple tones for richness)
    p.color = const Color(0xFFc89830);
    _r(canvas, p, 0, 0, w, 3); // top bright gold
    p.color = const Color(0xFFe0b840);
    _r(canvas, p, 1, 0, w - 2, 1); // top highlight
    p.color = const Color(0xFFb08828);
    _r(canvas, p, 0, 3, w, 4); // mid gold
    p.color = const Color(0xFF987018);
    _r(canvas, p, 0, 7, w, 4); // lower gold
    p.color = const Color(0xFF705010);
    _r(canvas, p, 0, h - 3, w, 3); // bottom shadow

    // Ornate gold edge patterns
    p.color = const Color(0xFFd0a030);
    for (double ox = 4; ox < w - 4; ox += 14) {
      _r(canvas, p, ox, 3, 6, 2);
    }
    // Gem insets
    p.color = const Color(0xFF4040c0);
    for (double ox = 10; ox < w - 6; ox += 28) {
      _r(canvas, p, ox, 4, 3, 3);
    }
    p.color = const Color(0xFF6060e0);
    for (double ox = 10; ox < w - 6; ox += 28) {
      _r(canvas, p, ox, 4, 1, 1); // gem highlight
    }

    // Side borders (dark gold)
    p.color = const Color(0xFF806010);
    _r(canvas, p, 0, 0, 2, h);
    _r(canvas, p, w - 2, 0, 2, h);

    // Animated golden glow (4b6: arithmetic pulse)
    p.shader = Gradient.radial(
      Offset(w / 2, 0),
      w * 0.7,
      [
        Color.fromRGBO(255, 220, 80, 0.25 * pulse),
        Color.fromRGBO(255, 180, 40, 0.08 * pulse),
        const Color(0x00000000),
      ],
      [0.0, 0.6, 1.0],
    );
    _r(canvas, p, 0, -8, w, h + 8);
    p.shader = null;

    // Sparkle particles (time-based, 4b5: dynamic generation)
    p.color = Color.fromRGBO(255, 240, 160, 0.9 * pulse);
    final sparkCount = 6;
    for (int i = 0; i < sparkCount; i++) {
      final angle = t * 1.5 + i * (pi * 2 / sparkCount);
      final r = w * 0.3 + sin(t * 3 + i) * w * 0.1;
      final sx = w / 2 + cos(angle) * r;
      final sy = h / 2 + sin(angle) * r * 0.3;
      if (sx >= 0 && sx < w && sy >= -4 && sy < h) {
        _r(canvas, p, sx, sy, 2, 2);
      }
    }
    // Static star sparkles
    p.color = Color.fromRGBO(255, 255, 220, 0.85 * pulse);
    final starPositions = [w * 0.2, w * 0.5, w * 0.8];
    for (final sx in starPositions) {
      final sy = 1.0 + sin(t * 4 + sx) * 1.5;
      _r(canvas, p, sx - 1, sy, 3, 1); // horizontal
      _r(canvas, p, sx, sy - 1, 1, 3); // vertical
    }
  }
}
