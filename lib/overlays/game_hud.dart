import 'package:flutter/material.dart';
import '../game/bemenjump_game.dart';

class GameHud extends StatelessWidget {
  final BemenJumpGame game;
  const GameHud({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar: score + pause button
            Row(
              children: [
                // Score
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xCC0a0a12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_upward, color: Color(0xFFf0c040), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${game.score}m',
                        style: const TextStyle(
                          color: Color(0xFFf0c040),
                          fontSize: 14,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Level indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xCC0a0a12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: Text(
                    'LV.${game.currentLevel}',
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const Spacer(),
                // Pause button (4b11)
                GestureDetector(
                  onTap: () => game.pauseGame(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xCC0a0a12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF333333)),
                    ),
                    child: const Icon(
                      Icons.pause,
                      color: Color(0xFFaaaaaa),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
