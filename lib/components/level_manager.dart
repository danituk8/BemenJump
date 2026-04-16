import 'dart:math';
import 'package:flame/components.dart';
import 'platform_block.dart';
import '../game/bemenjump_game.dart';

// ============================================================
// LevelManager - Procedural Level Generation
// ============================================================
// 4b5: This component handles GENERATION of game elements.
//      Platforms are procedurally generated based on level
//      parameters. Each level has different difficulty settings
//      that control platform spacing, size, and types.
//
// 4b6: Arithmetic is used extensively here:
//      - Random number generation for platform positions
//      - Mathematical formulas for spacing and difficulty curves
//      - Clamping values within valid ranges
// ============================================================

class LevelManager extends Component with HasGameRef<BemenJumpGame> {
  final int level;
  final Random _random = Random();
  
  // Level parameters
  late double platformMinWidth;
  late double platformMaxWidth;
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
  }

  // 4b6: Arithmetic - difficulty scaling formulas
  void _configureDifficulty() {
    switch (level) {
      case 1: // Easy - wide platforms, close together
        platformMinWidth = 80;
        platformMaxWidth = 140;
        verticalSpacing = 55;
        horizontalVariance = 120;
        totalPlatforms = 40;
        iceProbability = 0.0;
        crumbleProbability = 0.0;
        bounceProbability = 0.05;
        break;
      case 2: // Medium
        platformMinWidth = 60;
        platformMaxWidth = 110;
        verticalSpacing = 65;
        horizontalVariance = 150;
        totalPlatforms = 55;
        iceProbability = 0.15;
        crumbleProbability = 0.1;
        bounceProbability = 0.1;
        break;
      case 3: // Hard - JumpKing difficulty!
        platformMinWidth = 40;
        platformMaxWidth = 80;
        verticalSpacing = 75;
        horizontalVariance = 180;
        totalPlatforms = 70;
        iceProbability = 0.25;
        crumbleProbability = 0.2;
        bounceProbability = 0.15;
        break;
      default:
        _configureDifficulty();
    }
  }

  // 4b5: Procedural generation of platforms
  void _generatePlatforms() {
    // Ground platform (always exists)
    add(PlatformBlock(
      position: Vector2(0, 620),
      size: Vector2(400, 30),
      platformType: PlatformType.normal,
    ));
    
    // Starting platforms (easier)
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

    // 4b5 & 4b6: Generate platforms procedurally using arithmetic
    double currentY = 440;
    double lastX = 200;
    
    for (int i = 0; i < totalPlatforms; i++) {
      // 4b6: Arithmetic - calculate platform properties
      final width = platformMinWidth + 
          _random.nextDouble() * (platformMaxWidth - platformMinWidth);
      
      // Horizontal position with variance
      final xOffset = (_random.nextDouble() - 0.5) * horizontalVariance;
      double x = (lastX + xOffset).clamp(10, 400 - width - 10);
      
      // Determine platform type based on probabilities
      PlatformType type = PlatformType.normal;
      final roll = _random.nextDouble();
      if (roll < iceProbability) {
        type = PlatformType.ice;
      } else if (roll < iceProbability + crumbleProbability) {
        type = PlatformType.crumble;
      } else if (roll < iceProbability + crumbleProbability + bounceProbability) {
        type = PlatformType.bounce;
      }
      
      // Last platform is the goal
      if (i == totalPlatforms - 1) {
        type = PlatformType.goal;
        x = 150; // Center the goal
      }
      
      add(PlatformBlock(
        position: Vector2(x, currentY),
        size: Vector2(width, 14),
        platformType: type,
      ));
      
      lastX = x + width / 2;
      
      // 4b6: Arithmetic - spacing with slight randomness
      currentY -= verticalSpacing + (_random.nextDouble() - 0.5) * 20;
    }
  }
}
