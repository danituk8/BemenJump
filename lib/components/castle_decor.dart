import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';

// ============================================================
// CastleDecor — animated wall torch
// 4b4: Uses time-based animation (equivalent of AnimationGroup
//      but driven by a manual timer + discrete frame switch)
// 4b5: Torches are generated/placed procedurally by LevelManager
// ============================================================

class TorchComponent extends PositionComponent {
  /// true = torch on left wall (bracket points RIGHT into play area)
  /// false = torch on right wall (bracket points LEFT)
  final bool facingRight;
  double _t = 0;

  TorchComponent({required Vector2 position, this.facingRight = true})
      : super(position: position, anchor: Anchor.center);

  @override
  void update(double dt) => _t += dt;

  // ── helpers ──────────────────────────────────────────────────
  void _r(Canvas c, Paint p, double x, double y, double w, double h) =>
      c.drawRect(Rect.fromLTWH(x, y, w, h), p);

  @override
  void render(Canvas canvas) {
    // Flicker intensity (two sine waves → organic feel)
    final flicker =
        (0.82 + sin(_t * 5.1) * 0.12 + sin(_t * 13.7) * 0.06).clamp(0.55, 1.0);
    final frame = (_t * 9).floor() % 4; // 9 fps, 4 frames

    if (!facingRight) {
      // Mirror canvas for right-wall torches
      canvas.save();
      canvas.scale(-1, 1);
    }
    _drawTorch(canvas, frame, flicker);
    if (!facingRight) canvas.restore();
  }

  void _drawTorch(Canvas canvas, int frame, double f) {
    final p = Paint();

    // ── 1. Radial glow halo (drawn first, under everything) ──
    const glowCenter = Offset(14, -10);
    p.shader = Gradient.radial(
      glowCenter,
      70,
      [
        Color.fromRGBO(255, 145, 25, 0.30 * f),
        Color.fromRGBO(255, 95, 15, 0.12 * f),
        Color.fromRGBO(255, 55, 0, 0.04 * f),
        const Color(0x00000000),
      ],
      [0.0, 0.42, 0.72, 1.0],
    );
    canvas.drawCircle(glowCenter, 70, p);
    p.shader = null;

    // ── 2. Wall anchor block ─────────────────────────────────
    p.color = const Color(0xFF282836);
    _r(canvas, p, -14, 4, 8, 16); // anchor body
    p.color = const Color(0xFF383848);
    _r(canvas, p, -14, 4, 2, 16); // left highlight
    p.color = const Color(0xFF1e1e2c);
    _r(canvas, p, -8, 4, 2, 16);  // right shadow

    // ── 3. Horizontal bracket arm ────────────────────────────
    p.color = const Color(0xFF484858);
    _r(canvas, p, -8, 7, 26, 4);
    p.color = const Color(0xFF585870);
    _r(canvas, p, -8, 7, 26, 1); // top highlight
    p.color = const Color(0xFF28283a);
    _r(canvas, p, -8, 10, 26, 1); // bottom shadow

    // ── 4. Torch cup / holder ────────────────────────────────
    p.color = const Color(0xFF545464);
    _r(canvas, p, 8, 2, 14, 8);  // cup body
    _r(canvas, p, 6, 4, 18, 6);  // cup flange (wider)
    p.color = const Color(0xFF646474);
    _r(canvas, p, 6, 4, 18, 1);  // flange top highlight
    p.color = const Color(0xFF343444);
    _r(canvas, p, 6, 9, 18, 2);  // cup shadow
    // ember glow inside cup
    p.color = Color.fromRGBO(200, 80, 10, 0.6 * f);
    _r(canvas, p, 10, 3, 8, 5);

    // ── 5. Animated flame ────────────────────────────────────
    _drawFlame(canvas, p, 15, 3, frame, f);
  }

  void _drawFlame(Canvas c, Paint p, double cx, double by, int fr, double f) {
    // Layer 0 — hot core (white/yellow), always same shape
    p.color = Color.fromRGBO(255, 252, 210, f);
    _r(c, p, cx - 2, by - 1, 6, 4);

    // Layer 1 — main flame body (orange), varies per frame
    p.color = Color.fromRGBO(255, 158, 28, f);
    switch (fr) {
      case 0:
        _r(c, p, cx - 3, by - 7, 8, 7);
        _r(c, p, cx - 2, by - 12, 6, 6);
      case 1: // lean left, tall
        _r(c, p, cx - 4, by - 8, 8, 8);
        _r(c, p, cx - 3, by - 13, 6, 6);
      case 2: // squash
        _r(c, p, cx - 3, by - 6, 8, 6);
        _r(c, p, cx - 2, by - 10, 6, 5);
      case 3: // lean right
        _r(c, p, cx - 2, by - 7, 8, 7);
        _r(c, p, cx - 1, by - 12, 6, 6);
    }

    // Layer 2 — tip (light yellow)
    p.color = Color.fromRGBO(255, 228, 95, f * 0.88);
    switch (fr) {
      case 0: _r(c, p, cx - 1, by - 17, 4, 6);
      case 1: _r(c, p, cx - 2, by - 19, 4, 7);
      case 2: _r(c, p, cx - 1, by - 14, 4, 5);
      case 3: _r(c, p, cx, by - 17, 4, 6);
    }

    // Layer 3 — dark orange outer body
    p.color = Color.fromRGBO(220, 80, 10, f * 0.7);
    switch (fr) {
      case 0:
        _r(c, p, cx - 4, by - 6, 2, 5);
        _r(c, p, cx + 4, by - 6, 2, 5);
      case 1:
        _r(c, p, cx - 5, by - 7, 2, 6);
        _r(c, p, cx + 3, by - 5, 2, 5);
      case 2:
        _r(c, p, cx - 4, by - 5, 2, 4);
        _r(c, p, cx + 3, by - 5, 2, 4);
      case 3:
        _r(c, p, cx - 3, by - 6, 2, 5);
        _r(c, p, cx + 4, by - 6, 2, 5);
    }

    // Sparks — 1×1 pixels that pop on odd frames
    if (fr == 1 || fr == 3) {
      p.color = Color.fromRGBO(255, 215, 70, 0.75 * f);
      final si = (_t * 15).floor() % 4;
      final sparks = [
        (cx + 5.0, by - 19.0),
        (cx - 4.0, by - 15.0),
        (cx + 7.0, by - 11.0),
        (cx - 5.0, by - 22.0),
      ];
      _r(c, p, sparks[si].$1, sparks[si].$2, 1, 1);
    }
  }
}
