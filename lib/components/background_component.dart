import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import '../game/bemenjump_game.dart';

// ============================================================
// BackgroundComponent — Castle interior
// 4b10: Custom background with layered castle atmosphere
// Layers (back → front):
//   1. Deep void fill
//   2. Stone brick walls (left & right)
//   3. Gothic arch windows showing moonlit exterior
//   4. Decorative pillar edges
//   5. Torch glow halos (matches TorchComponent positions)
//   6. Atmospheric dust particles
//   7. Elaborate floor detail
// ============================================================

class BackgroundComponent extends Component with HasGameReference<BemenJumpGame> {
  final Random _rand = Random(7);
  double _t = 0;

  // Dust motes drifting upward
  late final List<_Dust> _dust;

  // Torch glow positions (must match LevelManager torch placement)
  // Left wall (x≈108) and right wall (x≈292), every 130 units from y=540
  static const double _torchSpacingY = 130;
  static const double _firstTorchY = 540;
  static const int _torchCount = 28;

  @override
  Future<void> onLoad() async {
    _dust = List.generate(50, (i) => _Dust(
      x: _rand.nextDouble() * 400,
      y: _rand.nextDouble() * 4000 - 3200,
      size: _rand.nextDouble() * 1.4 + 0.4,
      vy: _rand.nextDouble() * 12 + 4,
      alpha: _rand.nextDouble() * 0.25 + 0.07,
      drift: _rand.nextDouble() * 0.8 - 0.4,
    ));
  }

  @override
  void update(double dt) {
    _t += dt;
    final camY = game.cam.viewfinder.position.y;
    for (final d in _dust) {
      d.y -= d.vy * dt;
      d.x += d.drift * dt;
      if (d.y < camY - 520) {
        d.y = camY + 420 + _rand.nextDouble() * 100;
        d.x = _rand.nextDouble() * 400;
      }
      if (d.x < 0 || d.x > 400) d.x = _rand.nextDouble() * 400;
    }
  }

  // ── helper ───────────────────────────────────────────────────
  void _r(Canvas c, Paint p, double x, double y, double w, double h) =>
      c.drawRect(Rect.fromLTWH(x, y, w, h), p);

  @override
  void render(Canvas canvas) {
    final camY = game.cam.viewfinder.position.y;

    _drawVoidFill(canvas, camY);
    _drawStoneWalls(canvas, camY);
    _drawArchWindows(canvas, camY);
    _drawPillarEdges(canvas, camY);
    _drawTorchGlow(canvas, camY);
    _drawDust(canvas);
    _drawFloorDetail(canvas, camY);
  }

  // ── 1. Base void fill ────────────────────────────────────────
  void _drawVoidFill(Canvas canvas, double camY) {
    final heightT = ((600 - camY) / 3200).clamp(0.0, 1.0);
    final top = Color.lerp(const Color(0xFF0d0d1e), const Color(0xFF060610), heightT)!;
    final bot = Color.lerp(const Color(0xFF130f22), const Color(0xFF08080e), heightT)!;
    final paint = Paint()
      ..shader = Gradient.linear(
        Offset(0, camY - 450),
        Offset(0, camY + 450),
        [top, bot],
      );
    _r(canvas, paint, -10, camY - 450, 420, 900);
  }

  // ── 2. Stone brick walls ─────────────────────────────────────
  void _drawStoneWalls(Canvas canvas, double camY) {
    _drawBrickSection(canvas, -10, camY - 460, 140, 920);  // left wall
    _drawBrickSection(canvas, 270, camY - 460, 140, 920);  // right wall
  }

  void _drawBrickSection(Canvas canvas, double wx, double wy, double ww, double wh) {
    final p = Paint();
    // Base wall tone
    p.color = const Color(0xFF181826);
    _r(canvas, p, wx, wy, ww, wh);

    const bH = 16.0;  // brick height (incl mortar)
    const bW = 26.0;  // brick width
    const mort = 2.0; // mortar thickness

    final rowStart = (wy / bH).floor() - 1;
    final rowEnd = ((wy + wh) / bH).ceil() + 1;

    for (int row = rowStart; row <= rowEnd; row++) {
      final ry = row * bH;
      final offset = (row % 2 == 0) ? 0.0 : bW * 0.5;

      final colStart = ((wx - offset) / bW).floor() - 1;
      final colEnd = ((wx + ww - offset) / bW).ceil() + 1;

      for (int col = colStart; col <= colEnd; col++) {
        final bx = col * bW + offset;
        if (bx + bW <= wx || bx >= wx + ww) continue;

        // Brick color variation
        final tone = (row * 5 + col * 7) % 4;
        final brickColor = const [
          Color(0xFF242434),
          Color(0xFF1e1e2e),
          Color(0xFF222232),
          Color(0xFF202030),
        ][tone];

        // Clamp brick to wall bounds
        final clampedX = bx.clamp(wx, wx + ww - 0.5);
        final clampedW = (bx + bW - mort - clampedX).clamp(0, wx + ww - clampedX);

        p.color = brickColor;
        _r(canvas, p, clampedX + mort, ry + mort, clampedW - mort, bH - mort * 2);

        // Brick highlight (top edge)
        p.color = const Color(0xFF2e2e40);
        _r(canvas, p, clampedX + mort, ry + mort, clampedW - mort, 1);

        // Occasional crack
        if ((row * 11 + col * 17) % 13 == 0) {
          p.color = const Color(0xFF111120);
          _r(canvas, p, clampedX + mort + 4, ry + mort + 5, 7, 1);
          _r(canvas, p, clampedX + mort + 8, ry + mort + 5, 1, 4);
        }
        // Occasional damp stain
        if ((row * 13 + col * 9) % 17 == 0) {
          p.color = const Color(0x22304040);
          _r(canvas, p, clampedX + mort + 2, ry + bH - mort - 4, 10, 4);
        }
      }
    }
  }

  // ── 3. Gothic arch windows ───────────────────────────────────
  void _drawArchWindows(Canvas canvas, double camY) {
    // One window every 380 units, alternating sides
    const spacing = 380.0;
    const startY = 400.0; // first window

    final startIdx = ((camY - startY - 600) / spacing).floor();
    for (int i = startIdx; i <= startIdx + 6; i++) {
      final wy = startY - i * spacing;
      if (wy < camY - 500 || wy > camY + 500) continue;
      final isLeft = i % 2 == 0;
      _drawGothicWindow(canvas, isLeft, wy, camY);
    }
  }

  void _drawGothicWindow(Canvas canvas, bool isLeft, double wy, double camY) {
    final p = Paint();
    final wx = isLeft ? 5.0 : 275.0;
    const ww = 86.0; // window outer width
    const wh = 110.0; // window outer height

    // Stone surround
    p.color = const Color(0xFF20202e);
    _r(canvas, p, wx, wy - wh, ww, wh + 8);

    // Gothic pointed arch opening (approx with stacked rects)
    final archSteps = [
      // (xInset, yAboveBase, width) — approximate a pointed arch
      (0.0, 0.0, 68.0),
      (0.0, 8.0, 68.0),
      (2.0, 18.0, 64.0),
      (5.0, 28.0, 58.0),
      (9.0, 38.0, 50.0),
      (14.0, 46.0, 40.0),
      (19.0, 53.0, 30.0),
      (24.0, 59.0, 20.0),
      (28.0, 64.0, 12.0),
      (31.0, 68.0, 6.0),
      (33.0, 71.0, 2.0),
    ];

    // Interior sky colour (moonlit night)
    final heightT = ((600 - wy) / 3000).clamp(0.0, 1.0);
    final skyColor = Color.lerp(const Color(0xFF12123a), const Color(0xFF080820), heightT)!;

    // Fill the rectangular base of the opening
    p.color = skyColor;
    _r(canvas, p, wx + 9, wy - 70, 68, 70);

    // Fill each arch step with sky
    for (final step in archSteps) {
      final (xIn, yAbove, sw) = step;
      p.color = skyColor;
      _r(canvas, p, wx + 9 + xIn, wy - 70 - yAbove - 8, sw, 10);
    }

    // Stars through the window
    final sr = Random(wy.toInt() + (isLeft ? 0 : 100));
    p.color = const Color(0xFFffffff);
    for (int s = 0; s < 10; s++) {
      final sx = wx + 9 + sr.nextDouble() * 68;
      final sy = wy - 70 - sr.nextDouble() * 60;
      final sz = sr.nextDouble() * 1.5 + 0.5;
      // Twinkle
      final twinkle = (sin(_t * (sr.nextDouble() * 3 + 1) + sx) * 0.4 + 0.6).clamp(0.2, 1.0);
      p.color = Color.fromRGBO(255, 255, 255, twinkle * (0.6 + sr.nextDouble() * 0.4));
      _r(canvas, p, sx, sy, sz, sz);
    }

    // Moon glow (soft blue-white tint)
    p.color = const Color(0x18b8d8f0);
    _r(canvas, p, wx + 9, wy - 70, 68, 70);

    // Window sill (stone ledge at bottom)
    p.color = const Color(0xFF333346);
    _r(canvas, p, wx + 5, wy + 4, 76, 6);
    p.color = const Color(0xFF3e3e54);
    _r(canvas, p, wx + 5, wy + 4, 76, 2); // sill highlight
    p.color = const Color(0xFF28283a);
    _r(canvas, p, wx + 5, wy + 9, 76, 2); // sill shadow

    // Arch frame stones (vertical sides)
    p.color = const Color(0xFF2c2c3e);
    _r(canvas, p, wx + 5, wy - 70, 4, 74);  // left jamb
    _r(canvas, p, wx + 77, wy - 70, 4, 74); // right jamb
    p.color = const Color(0xFF363650);
    _r(canvas, p, wx + 5, wy - 70, 1, 74);  // jamb highlight

    // Moonlight shaft (faint diagonal glow through window)
    final shaftX = isLeft ? wx + 50.0 : wx + 10.0;
    p.color = const Color(0x08c0d8f0);
    _r(canvas, p, shaftX, wy - 70, 16, 200);
  }

  // ── 4. Pillar edges ──────────────────────────────────────────
  void _drawPillarEdges(Canvas canvas, double camY) {
    final p = Paint();
    const leftX = 128.0, rightX = 270.0;
    const pw = 12.0;

    for (final px in [leftX, rightX]) {
      // Pillar body
      p.color = const Color(0xFF28283a);
      _r(canvas, p, px, camY - 460, pw, 920);
      // Highlight edge
      p.color = const Color(0xFF34344a);
      _r(canvas, p, px, camY - 460, 2, 920);
      // Shadow edge
      p.color = const Color(0xFF1c1c2c);
      _r(canvas, p, px + pw - 2, camY - 460, 2, 920);

      // Capital rings every 150 units
      final capStart = ((camY - 460) / 150).floor();
      for (int c = capStart; c <= capStart + 8; c++) {
        final cy = c * 150.0;
        p.color = const Color(0xFF383850);
        _r(canvas, p, px - 5, cy - 5, pw + 10, 5);
        _r(canvas, p, px - 5, cy, pw + 10, 2);
        p.color = const Color(0xFF454560);
        _r(canvas, p, px - 5, cy - 5, pw + 10, 1); // ring highlight
        p.color = const Color(0xFF202030);
        _r(canvas, p, px - 5, cy + 2, pw + 10, 1); // ring shadow
      }
    }
  }

  // ── 5. Torch glow halos ──────────────────────────────────────
  void _drawTorchGlow(Canvas canvas, double camY) {
    final p = Paint();
    for (int i = 0; i < _torchCount; i++) {
      final torchY = _firstTorchY - i * _torchSpacingY;
      if (torchY < camY - 480 || torchY > camY + 480) continue;

      final isLeft = i % 2 == 0;
      final torchX = isLeft ? 108.0 : 292.0;

      // The glow pulses to match the TorchComponent flicker
      final pulse = (0.82 + sin(_t * 5.1 + i * 2.3) * 0.12 + sin(_t * 13.7 + i) * 0.06)
          .clamp(0.55, 1.0);
      final radius = 72.0 * pulse;

      p.shader = Gradient.radial(
        Offset(torchX, torchY),
        radius,
        [
          Color.fromRGBO(255, 145, 25, 0.18 * pulse),
          Color.fromRGBO(255, 95, 15, 0.07 * pulse),
          Color.fromRGBO(255, 55, 0, 0.02 * pulse),
          const Color(0x00000000),
        ],
        [0.0, 0.45, 0.75, 1.0],
      );
      canvas.drawCircle(Offset(torchX, torchY), radius, p);
    }
    p.shader = null;
  }

  // ── 6. Dust particles ────────────────────────────────────────
  void _drawDust(Canvas canvas) {
    final p = Paint();
    for (final d in _dust) {
      p.color = Color.fromRGBO(210, 210, 240, d.alpha);
      _r(canvas, p, d.x, d.y, d.size, d.size);
    }
  }

  // ── 7. Floor detail ──────────────────────────────────────────
  void _drawFloorDetail(Canvas canvas, double camY) {
    const floorY = 620.0;
    if (camY < floorY - 480 || camY > floorY + 480) return;
    final p = Paint();

    // Elaborate stone floor
    p.color = const Color(0xFF1e1e2e);
    _r(canvas, p, -10, floorY + 10, 420, 30);

    // Floor tile pattern
    for (double tx = -10; tx < 410; tx += 36) {
      final tone = ((tx / 36).floor() % 2 == 0) ? 0xFF222235 : 0xFF1e1e30;
      p.color = Color(tone);
      _r(canvas, p, tx + 1, floorY + 10, 34, 16);
      p.color = const Color(0xFF2a2a40);
      _r(canvas, p, tx + 1, floorY + 10, 34, 1); // tile highlight
      p.color = const Color(0xFF181828);
      _r(canvas, p, tx + 1, floorY + 25, 34, 1); // tile shadow
    }

    // Carved baseboard along walls
    p.color = const Color(0xFF2a2a3e);
    _r(canvas, p, -10, floorY, 140, 12);
    _r(canvas, p, 270, floorY, 140, 12);
    p.color = const Color(0xFF363650);
    _r(canvas, p, -10, floorY, 140, 2);
    _r(canvas, p, 270, floorY, 140, 2);
  }
}

class _Dust {
  double x, y, size, vy, alpha, drift;
  _Dust({
    required this.x, required this.y, required this.size,
    required this.vy, required this.alpha, required this.drift,
  });
}
