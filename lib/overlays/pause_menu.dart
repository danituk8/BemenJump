import 'package:flutter/material.dart';
import '../game/bemenjump_game.dart';

// ============================================================
// 4b11: Pause Menu
// The game is paused using game.pauseEngine() which stops the
// GameLoop from calling update() and render(). This overlay
// is shown on top of the frozen game state.
// resumeEngine() restarts the loop when unpaused.
// ============================================================

class PauseMenu extends StatelessWidget {
  final BemenJumpGame game;
  const PauseMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xBB000000),
      child: Center(
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF12122a),
            border: Border.all(color: const Color(0xFFf0c040), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PAUSED',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFf0c040),
                  letterSpacing: 6,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Score: ${game.score}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF888888),
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 30),
              _PauseButton(
                label: 'RESUME',
                color: const Color(0xFF50c080),
                onTap: () {
                  // 4b11: Resume - calls resumeEngine()
                  game.resumeGame();
                },
              ),
              const SizedBox(height: 10),
              _PauseButton(
                label: 'RESTART',
                color: const Color(0xFFf0c040),
                onTap: () {
                  game.overlays.remove('pause_menu');
                  game.startGame();
                },
              ),
              const SizedBox(height: 10),
              _PauseButton(
                label: 'MAIN MENU',
                color: const Color(0xFF888888),
                onTap: () => game.goToMainMenu(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Press ESC to resume',
                style: TextStyle(
                  fontSize: 8,
                  color: Color(0xFF555555),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PauseButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  
  const _PauseButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(6),
          color: color.withOpacity(0.08),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
