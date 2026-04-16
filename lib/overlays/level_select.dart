import 'package:flutter/material.dart';
import '../game/bemenjump_game.dart';

// ============================================================
// 4b12: Selector de Nivel (Level Select Screen)
// ============================================================

class LevelSelect extends StatelessWidget {
  final BemenJumpGame game;
  const LevelSelect({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xCC0a0a2a), Color(0xEE0a0a12)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'SELECT LEVEL',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFf0c040),
                letterSpacing: 4,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LevelCard(
                  level: 1,
                  name: 'THE CLIMB',
                  description: 'Wide platforms\nEasy spacing\n40 platforms',
                  color: const Color(0xFF50c080),
                  isSelected: game.currentLevel == 1,
                  onTap: () {
                    game.currentLevel = 1;
                    game.startGame();
                  },
                ),
                const SizedBox(width: 16),
                _LevelCard(
                  level: 2,
                  name: 'ICE TOWER',
                  description: 'Ice platforms\nTighter gaps\n55 platforms',
                  color: const Color(0xFF5080ff),
                  isSelected: game.currentLevel == 2,
                  onTap: () {
                    game.currentLevel = 2;
                    game.startGame();
                  },
                ),
                const SizedBox(width: 16),
                _LevelCard(
                  level: 3,
                  name: 'HELL PEAK',
                  description: 'Tiny platforms\nCrumbling floors\n70 platforms',
                  color: const Color(0xFFff5050),
                  isSelected: game.currentLevel == 3,
                  onTap: () {
                    game.currentLevel = 3;
                    game.startGame();
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                game.overlays.remove('level_select');
                game.overlays.add('main_menu');
              },
              child: const Text(
                '< BACK',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF888888),
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final String name;
  final String description;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.name,
    required this.description,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              'LV.$level',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: color,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 8,
                color: Color(0xFF888888),
                fontFamily: 'monospace',
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
