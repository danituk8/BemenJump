import 'package:flutter/material.dart';
import '../game/bemenjump_game.dart';

// ============================================================
// 4b12: Pantalla de Inicio (Main Menu)
// StatefulWidget para que setState() actualice la selección
// de personaje en tiempo real.
// ============================================================

class MainMenu extends StatefulWidget {
  final BemenJumpGame game;
  const MainMenu({super.key, required this.game});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  void _selectCharacter(CharacterType type) {
    setState(() => widget.game.selectedCharacter = type);
  }

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
            const SizedBox(height: 50),

            // Character selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CharacterOption(
                  type: CharacterType.eren,
                  name: 'EREN',
                  accentColor: const Color(0xFF8ab060),
                  isSelected: widget.game.selectedCharacter == CharacterType.eren,
                  onTap: () => _selectCharacter(CharacterType.eren),
                ),
                const SizedBox(width: 16),
                _CharacterOption(
                  type: CharacterType.beru,
                  name: 'BERU',
                  accentColor: const Color(0xFF7a7aff),
                  isSelected: widget.game.selectedCharacter == CharacterType.beru,
                  onTap: () => _selectCharacter(CharacterType.beru),
                ),
                const SizedBox(width: 16),
                _CharacterOption(
                  type: CharacterType.ai,
                  name: 'AI',
                  accentColor: const Color(0xFFed93b1),
                  isSelected: widget.game.selectedCharacter == CharacterType.ai,
                  onTap: () => _selectCharacter(CharacterType.ai),
                ),
              ],
            ),
            const SizedBox(height: 40),

            _MenuButton(
              label: 'PLAY',
              color: const Color(0xFFf0c040),
              onTap: () => widget.game.startGame(),
            ),
            const SizedBox(height: 12),
            _MenuButton(
              label: 'SELECT LEVEL',
              color: const Color(0xFF7a7aff),
              onTap: () {
                widget.game.overlays.remove('main_menu');
                widget.game.overlays.add('level_select');
              },
            ),
            const SizedBox(height: 12),
            _MenuButton(
              label: 'SETTINGS',
              color: const Color(0xFF888888),
              onTap: () {
                widget.game.overlays.remove('main_menu');
                widget.game.overlays.add('settings');
              },
            ),
            const SizedBox(height: 40),
            const Text(
              'Arrow Keys / WASD to move • Hold Space to charge jump',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF555555),
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Character option card with pixel-art preview ─────────────

class _CharacterOption extends StatelessWidget {
  final CharacterType type;
  final String name;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _CharacterOption({
    required this.type,
    required this.name,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 84,
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
            color: isSelected ? accentColor : const Color(0xFF333333),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pixel-art sprite preview
            SizedBox(
              width: 48,
              height: 48,
              child: CustomPaint(
                painter: _CharacterPainter(type),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 9,
                color: isSelected ? accentColor : const Color(0xFF888888),
                fontFamily: 'monospace',
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pixel-art painter (replicates player.dart draw logic) ────

class _CharacterPainter extends CustomPainter {
  final CharacterType type;
  const _CharacterPainter(this.type);

  void _px(Canvas c, double x, double y, Color col) =>
      c.drawRect(Rect.fromLTWH(x, y, 1, 1), Paint()..color = col);

  void _rect(Canvas c, double x, double y, double w, double h, Color col) =>
      c.drawRect(Rect.fromLTWH(x, y, w, h), Paint()..color = col);

  @override
  void paint(Canvas canvas, Size size) {
    // Scale so 48×48 world pixels fit the widget size
    canvas.scale(size.width / 48, size.height / 48);
    switch (type) {
      case CharacterType.eren:
        _drawEren(canvas);
      case CharacterType.beru:
        _drawBeru(canvas);
      case CharacterType.ai:
        _drawAi(canvas);
    }
  }

  void _drawEren(Canvas c) {
    const sk = Color(0xFFc4956a);
    const hair = Color(0xFF5c3a1e);
    const hairD = Color(0xFF3a2010);
    const coat = Color(0xFF2d2d2d);
    const coatL = Color(0xFF3d3d3d);
    const coatD = Color(0xFF1a1a1a);
    const boot = Color(0xFF1a1a1a);
    const eye = Color(0xFF1a6a3a);
    const belt = Color(0xFF4a3020);
    const beltB = Color(0xFF6a5040);

    const bx = 18.0, by = 10.0;
    // Hair back
    _rect(c, bx - 1, by, 14, 4, hairD);
    _rect(c, bx + 10, by + 1, 4, 6, hairD);
    // Head
    _rect(c, bx + 1, by + 2, 10, 10, sk);
    _rect(c, bx + 2, by + 1, 8, 1, sk);
    // Hair front
    _rect(c, bx, by, 12, 3, hair);
    _rect(c, bx - 1, by + 1, 2, 6, hair);
    _rect(c, bx + 10, by + 1, 2, 4, hair);
    // Eyes
    _px(c, bx + 4, by + 5, eye); _px(c, bx + 5, by + 5, eye);
    _px(c, bx + 7, by + 5, eye); _px(c, bx + 8, by + 5, eye);
    // Mouth
    _px(c, bx + 5, by + 8, sk); _px(c, bx + 6, by + 8, sk);
    // Neck
    _rect(c, bx + 4, by + 11, 4, 2, sk);
    // Coat
    _rect(c, bx + 1, by + 12, 10, 10, coat);
    _rect(c, bx + 2, by + 12, 8, 10, coatL);
    // Belt
    _rect(c, bx + 1, by + 20, 10, 2, belt);
    _rect(c, bx + 5, by + 20, 2, 2, beltB);
    // Arms
    _rect(c, bx - 1, by + 13, 2, 8, coat);
    _rect(c, bx + 11, by + 13, 2, 8, coat);
    // Legs
    _rect(c, bx + 2, by + 22, 3, 7, coatD);
    _rect(c, bx + 7, by + 22, 3, 7, coatD);
    _rect(c, bx + 1, by + 27, 4, 3, boot);
    _rect(c, bx + 6, by + 27, 4, 3, boot);
  }

  void _drawBeru(Canvas c) {
    const body = Color(0xFF0a0a1a);
    const bodyL = Color(0xFF1a1a3a);
    const glow = Color(0xFF4a5aff);
    const glowD = Color(0xFF2a2a8a);
    const eye = Color(0xFF6a7aff);
    const eyeB = Color(0xFFaabbff);
    const claw = Color(0xFF1a1a2a);

    const bx = 16.0, by = 4.0;
    // Head
    _rect(c, bx + 4, by, 8, 3, body);
    _rect(c, bx + 3, by + 2, 10, 4, body);
    _rect(c, bx + 5, by + 1, 6, 1, bodyL);
    // Antennae
    _px(c, bx + 3, by - 2, glow); _px(c, bx + 12, by - 2, glow);
    // Eyes
    _px(c, bx + 5, by + 3, eye); _px(c, bx + 6, by + 3, eyeB);
    _px(c, bx + 9, by + 3, eye); _px(c, bx + 10, by + 3, eyeB);
    // Mandibles
    _px(c, bx + 4, by + 5, claw); _px(c, bx + 11, by + 5, claw);
    // Neck
    _rect(c, bx + 5, by + 6, 6, 2, body);
    // Torso
    _rect(c, bx + 3, by + 8, 10, 8, body);
    _rect(c, bx + 4, by + 9, 8, 6, bodyL);
    _px(c, bx + 7, by + 10, glow); _px(c, bx + 8, by + 10, glow);
    _px(c, bx + 5, by + 9, glow); _px(c, bx + 10, by + 9, glow);
    // Arms
    _rect(c, bx + 1, by + 9, 2, 6, body);
    _rect(c, bx + 13, by + 9, 2, 6, body);
    _px(c, bx + 1, by + 11, glowD); _px(c, bx + 14, by + 11, glowD);
    // Waist
    _rect(c, bx + 4, by + 16, 8, 2, body);
    _rect(c, bx + 5, by + 16, 6, 1, glowD);
    // Legs
    _rect(c, bx + 3, by + 18, 3, 9, body);
    _rect(c, bx + 10, by + 18, 3, 9, body);
    // Claws
    _rect(c, bx + 2, by + 26, 2, 1, claw);
    _rect(c, bx + 5, by + 26, 2, 1, claw);
    _rect(c, bx + 9, by + 26, 2, 1, claw);
    _rect(c, bx + 12, by + 26, 2, 1, claw);
  }

  void _drawAi(Canvas c) {
    const sk = Color(0xFFe8b888);
    const hair = Color(0xFF6030a0);
    const hairD = Color(0xFF401880);
    const hairL = Color(0xFF8050c0);
    const eyeC = Color(0xFF6030a0);
    const eyeW = Color(0xFFffffff);
    const eyeStar = Color(0xFFffee55);
    const blush = Color(0xFFff8899);
    const dressP = Color(0xFFff50a0);
    const dressL = Color(0xFFff80c0);
    const dressY = Color(0xFFffe040);
    const boot = Color(0xFFff3088);
    const bootL = Color(0xFFff60a8);
    const outline = Color(0xFF301050);
    const white = Color(0xFFffffff);
    const mic = Color(0xFFcccccc);
    const micH = Color(0xFFe0e0e0);

    const cx = 15.0, cy = 2.0;
    // Hair back
    _rect(c, cx + 1, cy + 10, 16, 22, hairD);
    _rect(c, cx + 2, cy + 12, 14, 20, hair);
    _rect(c, cx - 1, cy + 8, 4, 18, hairD);
    _rect(c, cx + 0, cy + 10, 3, 16, hair);
    _rect(c, cx + 14, cy + 10, 3, 20, hairD);
    // Head
    _rect(c, cx + 3, cy, 12, 1, outline);
    _rect(c, cx + 2, cy + 1, 14, 1, sk);
    _rect(c, cx + 2, cy + 2, 14, 14, sk);
    _rect(c, cx + 3, cy + 16, 12, 1, sk);
    // Hair front
    _rect(c, cx + 2, cy - 1, 14, 1, hair);
    _rect(c, cx + 1, cy, 16, 4, hair);
    _rect(c, cx + 2, cy + 3, 5, 2, hair);
    _rect(c, cx + 11, cy + 3, 5, 2, hair);
    _rect(c, cx + 8, cy + 1, 2, 2, hairL);
    _rect(c, cx + 1, cy + 5, 2, 10, hairD);
    _rect(c, cx + 15, cy + 5, 2, 10, hair);
    // Accessory
    _px(c, cx + 14, cy + 2, dressY); _px(c, cx + 15, cy + 1, dressY);
    // Eyes
    _rect(c, cx + 4, cy + 7, 4, 5, eyeW);
    _rect(c, cx + 4, cy + 7, 4, 1, outline);
    _rect(c, cx + 5, cy + 9, 2, 2, eyeC);
    _px(c, cx + 5, cy + 9, eyeStar);
    _rect(c, cx + 10, cy + 7, 4, 5, eyeW);
    _rect(c, cx + 10, cy + 7, 4, 1, outline);
    _rect(c, cx + 11, cy + 9, 2, 2, eyeC);
    _px(c, cx + 11, cy + 9, eyeStar);
    // Blush
    _px(c, cx + 3, cy + 11, blush); _px(c, cx + 4, cy + 11, blush);
    _px(c, cx + 13, cy + 11, blush); _px(c, cx + 14, cy + 11, blush);
    // Mouth
    _px(c, cx + 8, cy + 13, outline); _px(c, cx + 9, cy + 13, outline);
    // Body
    _rect(c, cx + 4, cy + 18, 10, 3, dressP);
    _rect(c, cx + 5, cy + 18, 8, 1, dressL);
    _rect(c, cx + 3, cy + 19, 12, 2, dressP);
    _px(c, cx + 8, cy + 18, dressY); _px(c, cx + 9, cy + 18, dressY);
    // Skirt
    _rect(c, cx + 2, cy + 21, 14, 5, dressP);
    _rect(c, cx + 1, cy + 23, 16, 3, dressP);
    _rect(c, cx + 1, cy + 25, 16, 1, white);
    // Arms
    _rect(c, cx + 2, cy + 19, 2, 4, sk);
    _rect(c, cx + 14, cy + 18, 2, 3, sk);
    // Mic
    _rect(c, cx + 15, cy + 15, 2, 3, mic);
    _rect(c, cx + 14, cy + 14, 4, 2, micH);
    // Legs
    _rect(c, cx + 5, cy + 26, 3, 2, sk);
    _rect(c, cx + 4, cy + 28, 4, 4, boot);
    _rect(c, cx + 4, cy + 28, 4, 1, bootL);
    _rect(c, cx + 10, cy + 26, 3, 2, sk);
    _rect(c, cx + 9, cy + 28, 4, 4, boot);
    _rect(c, cx + 9, cy + 28, 4, 1, bootL);
  }

  @override
  bool shouldRepaint(_CharacterPainter old) => old.type != type;
}

// ── Menu button ──────────────────────────────────────────────

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
          border: Border.all(color: color.withValues(alpha: 0.6)),
          borderRadius: BorderRadius.circular(6),
          color: color.withValues(alpha: 0.08),
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
