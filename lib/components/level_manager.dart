import 'dart:math';
import 'package:flame/components.dart';
import 'platform_block.dart';
import 'castle_decor.dart';
import '../game/bemenjump_game.dart';

// ============================================================
// LevelManager — Procedural level generation
// 4b5: Platforms AND torches are generated procedurally.
//      Each level has different difficulty parameters.
//      TorchComponent objects are scattered on walls for atmosphere.
// 4b6: Arithmetic throughout (spacing, clamping, probabilities)
// ============================================================

class LevelManager extends Component with HasGameReference<BemenJumpGame> {
  final int level;
  final Random _rng = Random();

  late double platformMinW;
  late double platformMaxW;
  late double verticalSpacing;
  late double horizontalVariance;
  late int totalPlatforms;
  late double iceProbability;
  late double crumbleProbability;
  late double bounceProbability;

  LevelManager({required this.level});

  @override
  Future<void> onLoad() async {
    _configureDifficulty();
    _generatePlatforms();
    _generateTorches(); // 4b5: generate decorative torch elements
  }

  // ── Difficulty tuning ────────────────────────────────────────
  void _configureDifficulty() {
    switch (level) {
      case 1: // The Climb — generous platforms, warm castle
        platformMinW = 80;
        platformMaxW = 140;
        verticalSpacing = 55;
        horizontalVariance = 120;
        totalPlatforms = 40;
        iceProbability = 0.0;
        crumbleProbability = 0.05;
        bounceProbability = 0.06;
      case 2: // Ice Tower — wooden planks, tighter gaps
        platformMinW = 60;
        platformMaxW = 110;
        verticalSpacing = 65;
        horizontalVariance = 155;
        totalPlatforms = 55;
        iceProbability = 0.20;
        crumbleProbability = 0.12;
        bounceProbability = 0.10;
      case 3: // Hell Peak — JumpKing nightmare
        platformMinW = 40;
        platformMaxW = 80;
        verticalSpacing = 76;
        horizontalVariance = 185;
        totalPlatforms = 70;
        iceProbability = 0.25;
        crumbleProbability = 0.22;
        bounceProbability = 0.15;
      default:
        _configureDifficulty();
    }
  }

  // ── Platform generation ──────────────────────────────────────
  void _generatePlatforms() {
    // Ground (full-width stone floor)
    add(PlatformBlock(
      position: Vector2(0, 620),
      size: Vector2(400, 30),
      platformType: PlatformType.normal,
    ));

    // Safe starting platforms (no crumble/ice near the floor)
    add(PlatformBlock(
      position: Vector2(100, 560),
      size: Vector2(120, 14),
      platformType: PlatformType.normal,
    ));
    add(PlatformBlock(
      position: Vector2(220, 500),
      size: Vector2(100, 14),
      platformType: PlatformType.normal,
    ));

    // 4b5 & 4b6: Procedural generation
    double currentY = 440;
    double lastX = 200;

    for (int i = 0; i < totalPlatforms; i++) {
      // 4b6: Arithmetic — random width within difficulty range
      final width = platformMinW +
          _rng.nextDouble() * (platformMaxW - platformMinW);

      // 4b6: Horizontal position with variance
      final xOffset = (_rng.nextDouble() - 0.5) * horizontalVariance;
      final x = (lastX + xOffset).clamp(15.0, 400 - width - 15.0);

      // Platform type via weighted probability
      PlatformType type = PlatformType.normal;
      final roll = _rng.nextDouble();
      if (roll < bounceProbability) {
        type = PlatformType.bounce;
      } else if (roll < bounceProbability + crumbleProbability) {
        type = PlatformType.crumble;
      } else if (roll < bounceProbability + crumbleProbability + iceProbability) {
        type = PlatformType.ice;
      }

      // Final platform is always the golden goal
      if (i == totalPlatforms - 1) {
        type = PlatformType.goal;
      }

      add(PlatformBlock(
        position: Vector2(x, currentY),
        size: Vector2(width, 14),
        platformType: type,
      ));

      lastX = x + width / 2;

      // 4b6: Arithmetic spacing with slight randomness
      currentY -= verticalSpacing + (_rng.nextDouble() - 0.5) * 20;
    }
  }

  // ── Torch generation (4b5: element generation) ───────────────
  //
  // Torches are placed every ~130 units on alternating walls.
  // Positions must match BackgroundComponent._torchGlow positions
  // so the glow halo in the background lines up with the flame.
  //
  //   Left wall torches:  x ≈ 108, facingRight = true
  //   Right wall torches: x ≈ 292, facingRight = false
  // ─────────────────────────────────────────────────────────────
  void _generateTorches() {
    const firstY = 540.0;
    const spacingY = 130.0;
    const torchCount = 28;

    for (int i = 0; i < torchCount; i++) {
      final torchY = firstY - i * spacingY;
      final isLeft = i % 2 == 0;
      add(TorchComponent(
        position: Vector2(isLeft ? 108.0 : 292.0, torchY),
        facingRight: isLeft,
      ));
    }
  }
}
