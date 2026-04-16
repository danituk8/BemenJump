import 'dart:async';
import 'package:flutter/material.dart';
import '../game/bemenjump_game.dart';

class GameHud extends StatefulWidget {
  final BemenJumpGame game;
  const GameHud({super.key, required this.game});

  @override
  State<GameHud> createState() => _GameHudState();
}

class _GameHudState extends State<GameHud> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Refresh HUD 20 times per second to show live score/state
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        '${widget.game.score}m',
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
                // Level
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xCC0a0a12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: Text(
                    'LV.${widget.game.currentLevel}',
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
                  onTap: () => widget.game.pauseGame(),
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
            // Charge bar (shown while charging jump)
            if (widget.game.isGameActive)
              _ChargeBar(game: widget.game),
          ],
        ),
      ),
    );
  }
}

class _ChargeBar extends StatelessWidget {
  final BemenJumpGame game;
  const _ChargeBar({required this.game});

  @override
  Widget build(BuildContext context) {
    // Access player charge safely
    if (!game.isGameActive) return const SizedBox.shrink();
    try {
      final charge = game.player.chargeAmount;
      final isCharging = game.player.isCharging;
      if (!isCharging) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Center(
          child: Container(
            width: 100,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a2a),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: charge.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(const Color(0xFF50c080), const Color(0xFFff5050), charge)!,
                      const Color(0xFFf0c040),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}
