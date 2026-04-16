import 'package:flutter/material.dart';
import '../game/bemenjump_game.dart';

class GameOver extends StatelessWidget {
  final BemenJumpGame game;
  const GameOver({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xBB000000),
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF12122a),
            border: Border.all(color: const Color(0xFFff5050), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GAME OVER',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFff5050),
                  letterSpacing: 4,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'HEIGHT: ${game.score}m',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFf0c040),
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  game.overlays.remove('game_over');
                  game.startGame();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFf0c040).withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(6),
                    color: const Color(0xFFf0c040).withOpacity(0.08),
                  ),
                  child: const Text(
                    'TRY AGAIN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFf0c040),
                      fontSize: 12,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => game.goToMainMenu(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF555555)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'MAIN MENU',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 12,
                      fontFamily: 'monospace',
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
