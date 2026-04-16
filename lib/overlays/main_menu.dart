import 'package:flutter/material.dart';
import '../game/bemenjump_game.dart';

// ============================================================
// 4b12: Pantalla de Inicio (Main Menu)
// ============================================================

class MainMenu extends StatelessWidget {
  final BemenJumpGame game;
  const MainMenu({super.key, required this.game});

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
            // Title
            const Text(
              'BEMEN',
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w900,
                color: Color(0xFFf0c040),
                letterSpacing: 8,
                shadows: [
                  Shadow(color: Color(0xAAf0c040), blurRadius: 30),
                  Shadow(color: Color(0x44ff8800), blurRadius: 60),
                ],
              ),
            ),
            const Text(
              'JUMP',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 12,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'A JumpKing-style platformer',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF888888),
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 60),
            
            // Character selector preview
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CharacterOption(
                  name: 'EREN',
                  color: const Color(0xFF8ab060),
                  isSelected: game.selectedCharacter == CharacterType.eren,
                  onTap: () => game.selectedCharacter = CharacterType.eren,
                ),
                const SizedBox(width: 16),
                _CharacterOption(
                  name: 'BERU',
                  color: const Color(0xFF7a7aff),
                  isSelected: game.selectedCharacter == CharacterType.beru,
                  onTap: () => game.selectedCharacter = CharacterType.beru,
                ),
                const SizedBox(width: 16),
                _CharacterOption(
                  name: 'AI',
                  color: const Color(0xFFed93b1),
                  isSelected: game.selectedCharacter == CharacterType.ai,
                  onTap: () => game.selectedCharacter = CharacterType.ai,
                ),
              ],
            ),
            const SizedBox(height: 40),
            
            // Play button
            _MenuButton(
              label: 'PLAY',
              color: const Color(0xFFf0c040),
              onTap: () => game.startGame(),
            ),
            const SizedBox(height: 12),
            _MenuButton(
              label: 'SELECT LEVEL',
              color: const Color(0xFF7a7aff),
              onTap: () {
                game.overlays.remove('main_menu');
                game.overlays.add('level_select');
              },
            ),
            const SizedBox(height: 12),
            _MenuButton(
              label: 'SETTINGS',
              color: const Color(0xFF888888),
              onTap: () {
                game.overlays.remove('main_menu');
                game.overlays.add('settings');
              },
            ),
            const SizedBox(height: 40),
            const Text(
              'Arrow Keys / WASD to move • Space to jump\nHold Space to charge jump • ESC to pause',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF555555),
                fontFamily: 'monospace',
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacterOption extends StatelessWidget {
  final String name;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _CharacterOption({
    required this.name,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 90,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : const Color(0xFF333333),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.person, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? color : const Color(0xFF888888),
                fontFamily: 'monospace',
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  
  const _MenuButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.6)),
          borderRadius: BorderRadius.circular(6),
          color: color.withOpacity(0.08),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
      ),
    );
  }
}
