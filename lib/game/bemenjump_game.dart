import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/player.dart';
import '../components/platform_block.dart';
import '../components/level_manager.dart';
import '../components/background_component.dart';
import '../components/particle_manager.dart';

// ============================================================
// BemenJumpGame - Main Game Class
// ============================================================
// 4b1: This extends FlameGame which contains the GameLoop.
//      The GameLoop continuously calls:
//        - update(dt): game logic, physics, input (4b2)
//        - render(canvas): drawing sprites, shapes (4b2)
//      FlameGame manages the component tree - all game objects
//      are Components added to this tree.
//
// 4b2: RENDER - Called every frame to draw the game.
//      FlameGame iterates all components and calls their
//      render(Canvas) method. The Canvas is provided by
//      GameWidget. Components draw themselves using
//      SpriteComponent.render, shapes, etc.
//
//      UPDATE - Called every frame with delta time (dt).
//      This is where game logic happens: physics, collision
//      detection, input processing, state changes. Each
//      component's update(dt) is called by the game loop.
// ============================================================

enum CharacterType { eren, beru, ai }

class BemenJumpGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  
  // Game state
  CharacterType selectedCharacter = CharacterType.eren;
  int currentLevel = 1;
  int maxLevel = 3;
  double highestY = 0;
  int score = 0;
  bool isGameActive = false;
  double gameSpeed = 1.0;
  
  // Settings (4b12: settings screen values)
  double musicVolume = 0.7;
  double sfxVolume = 0.8;
  bool showParticles = true;
  
  // References to key components
  late Player player;
  late LevelManager levelManager;
  late BackgroundComponent backgroundComponent;
  late ParticleManager particleManager;
  
  // Camera follows player vertically
  late final CameraComponent cam;
  late final World gameWorld;

  @override
  Color backgroundColor() => const Color(0xFF0a0a12); // 4b10: Custom bg color

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Create the game world
    gameWorld = World();
    cam = CameraComponent(world: gameWorld);
    cam.viewfinder.anchor = Anchor.center;
    
    addAll([gameWorld, cam]);
    
    // Don't start gameplay yet - wait for menu
  }

  // Start a new game with selected character and level
  void startGame() {
    // Clear previous game objects
    gameWorld.removeAll(gameWorld.children);
    
    // 4b10: Background component with custom colors
    backgroundComponent = BackgroundComponent();
    gameWorld.add(backgroundComponent);
    
    // 4b5: Level generation - platforms are procedurally generated
    levelManager = LevelManager(level: currentLevel);
    gameWorld.add(levelManager);
    
    // 4b4: Player uses SpriteComponent with Animation
    player = Player(
      characterType: selectedCharacter,
      position: Vector2(200, 600),
    );
    gameWorld.add(player);
    
    // 4b5: Particle generation for visual effects
    if (showParticles) {
      particleManager = ParticleManager();
      gameWorld.add(particleManager);
    }
    
    // Reset state
    highestY = 600;
    score = 0;
    isGameActive = true;
    
    // Show HUD, hide menus
    overlays.remove('main_menu');
    overlays.remove('level_select');
    overlays.remove('settings');
    overlays.remove('game_over');
    overlays.add('hud');
    
    // Resume if paused
    resumeEngine();
  }

  // 4b11: Pause the game
  void pauseGame() {
    if (isGameActive) {
      // 4b11: pauseEngine() stops the GameLoop (update + render stop)
      pauseEngine();
      overlays.add('pause_menu');
    }
  }

  // 4b11: Resume the game
  void resumeGame() {
    overlays.remove('pause_menu');
    resumeEngine();
  }

  // Return to main menu
  void goToMainMenu() {
    isGameActive = false;
    overlays.remove('hud');
    overlays.remove('pause_menu');
    overlays.remove('game_over');
    overlays.add('main_menu');
    resumeEngine();
  }

  // Called when player falls too far
  void gameOver() {
    isGameActive = false;
    pauseEngine();
    overlays.add('game_over');
  }

  // Called when player reaches the top
  void levelComplete() {
    isGameActive = false;
    score += 1000;
    if (currentLevel < maxLevel) {
      currentLevel++;
    }
    pauseEngine();
    overlays.add('game_over'); // Reuse as win screen
  }

  // 4b2: update - called every frame by the GameLoop
  @override
  void update(double dt) {
    if (!isGameActive) return;
    super.update(dt);
    
    // Camera follows player upward (JumpKing style - only moves up)
    final playerY = player.position.y;
    if (playerY < highestY) {
      highestY = playerY;
      score = ((600 - highestY) / 10).toInt().clamp(0, 99999);
    }
    
    // Smooth camera follow
    cam.viewfinder.position = Vector2(
      200, // Fixed X center
      player.position.y - 100, // Follow player Y with offset
    );
    
    // Check if player fell below the start
    if (player.position.y > 700) {
      gameOver();
    }
  }

  // 4b2: render is handled by FlameGame automatically
  // Each component's render() is called by the game loop.
  // We override here only if we need custom rendering on top.
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // FlameGame calls render on all children components
    // SpriteComponents render their sprites
    // ShapeComponents render their shapes
  }

  // Handle keyboard for pause (4b11)
  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent && 
        event.logicalKey == LogicalKeyboardKey.escape) {
      if (overlays.isActive('pause_menu')) {
        resumeGame();
      } else if (isGameActive) {
        pauseGame();
      }
      return KeyEventResult.handled;
    }
    return super.onKeyEvent(event, keysPressed);
  }
}
