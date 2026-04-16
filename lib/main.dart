import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/bemenjump_game.dart';
import 'overlays/main_menu.dart';
import 'overlays/level_select.dart';
import 'overlays/settings_screen.dart';
import 'overlays/pause_menu.dart';
import 'overlays/game_over.dart';
import 'overlays/game_hud.dart';

// ============================================================
// BemenJump - Main Entry Point
// ============================================================
// 4b1: GameWidget is the bridge between Flutter and Flame.
//      It wraps our FlameGame and renders it as a Flutter widget.
//      The GameLoop is managed internally by FlameGame - it calls
//      update(dt) and render(canvas) every frame automatically.
//
// 4b8: loadingBuilder - shown while game assets load
//      backgroundBuilder - renders behind the game
//      overlayBuilderMap - maps overlay keys to Flutter widgets
// ============================================================

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BemenJumpApp());
}

class BemenJumpApp extends StatelessWidget {
  const BemenJumpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BemenJump',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0a0a12),
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late BemenJumpGame game;

  @override
  void initState() {
    super.initState();
    game = BemenJumpGame();
  }

  @override
  Widget build(BuildContext context) {
    // 4b1: GameWidget - wraps the Flame game and provides the GameLoop
    // 4b8: loadingBuilder, backgroundBuilder, overlayBuilderMap
    return Scaffold(
      body: GameWidget<BemenJumpGame>(
        game: game,

        // 4b8: loadingBuilder - displayed while assets are loading
        loadingBuilder: (context) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFFf0c040)),
              SizedBox(height: 20),
              Text(
                'Loading BemenJump...',
                style: TextStyle(
                  color: Color(0xFFf0c040),
                  fontSize: 18,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),

        // 4b8: backgroundBuilder - renders behind the game canvas
        backgroundBuilder: (context) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0a0a2a), // 4b10: Custom background color (dark blue-black)
                Color(0xFF1a0a30), // Purple tint
                Color(0xFF0a0a12), // Near black
              ],
            ),
          ),
        ),

        // 4b8: overlayBuilderMap - maps string keys to overlay widgets
        // 4b12: Main menu, level selector, settings screen
        overlayBuilderMap: {
          'main_menu': (context, game) => MainMenu(game: game),
          'level_select': (context, game) => LevelSelect(game: game),
          'settings': (context, game) => SettingsScreen(game: game),
          'pause_menu': (context, game) => PauseMenu(game: game),
          'game_over': (context, game) => GameOver(game: game),
          'hud': (context, game) => GameHud(game: game),
        },

        // Start with main menu overlay visible
        initialActiveOverlays: const ['main_menu'],
      ),
    );
  }
}
