import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import '../game/bemenjump_game.dart';

// ============================================================
// ParticleManager - Visual Effect Particles
// ============================================================
// 4b5: This demonstrates element GENERATION at runtime.
//      Particles are generated dynamically when the player
//      lands, jumps, or reaches milestones. Each particle
//      has position, velocity, lifetime, and color.
//
// 4b6: Uses Arithmetic for particle physics:
//      - Velocity calculations with randomness
//      - Lifetime decay
//      - Position updates using velocity * dt
// ============================================================

class _Particle {
  double x, y, vx, vy, life, maxLife, size;
  Color color;
  
  _Particle({
    required this.x, required this.y,
    required this.vx, required this.vy,
    required this.life, required this.color,
    this.size = 2,
  }) : maxLife = life;
}

class ParticleManager extends Component with HasGameReference<BemenJumpGame> {
  final List<_Particle> _particles = [];
  final Random _random = Random();

  // 4b5: Generate landing particles
  void spawnLandingParticles(double x, double y) {
    for (int i = 0; i < 8; i++) {
      _particles.add(_Particle(
        x: x + _random.nextDouble() * 20 - 10,
        y: y,
        vx: (_random.nextDouble() - 0.5) * 100,
        vy: -_random.nextDouble() * 80 - 20,
        life: _random.nextDouble() * 0.4 + 0.2,
        color: const Color(0xFF6a6a8a),
        size: _random.nextDouble() * 2 + 1,
      ));
    }
  }

  // 4b5: Generate jump charge particles
  void spawnChargeParticles(double x, double y, double charge) {
    final count = (charge * 5).toInt().clamp(1, 5);
    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * 3.14159 * 2;
      final speed = _random.nextDouble() * 30 + 10;
      _particles.add(_Particle(
        x: x + _random.nextDouble() * 10 - 5,
        y: y - 10,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 20,
        life: 0.3,
        color: Color.lerp(
          const Color(0xFFf0c040),
          const Color(0xFFff5050),
          charge,
        )!,
        size: 1.5,
      ));
    }
  }

  // 4b5: Generate goal celebration particles
  void spawnCelebration(double x, double y) {
    for (int i = 0; i < 30; i++) {
      final angle = _random.nextDouble() * 3.14159 * 2;
      final speed = _random.nextDouble() * 150 + 50;
      final colors = [
        const Color(0xFFf0c040),
        const Color(0xFFff50a0),
        const Color(0xFF50c0ff),
        const Color(0xFF50ff80),
      ];
      _particles.add(_Particle(
        x: x,
        y: y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        life: _random.nextDouble() * 1.0 + 0.5,
        color: colors[_random.nextInt(colors.length)],
        size: _random.nextDouble() * 3 + 1,
      ));
    }
  }

  // 4b2 & 4b6: Update with physics arithmetic
  @override
  void update(double dt) {
    super.update(dt);
    
    for (final p in _particles) {
      // 4b6: Arithmetic - position = position + velocity * time
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += 200 * dt; // gravity on particles
      p.life -= dt;
    }
    
    // Remove dead particles
    _particles.removeWhere((p) => p.life <= 0);
  }

  // 4b2: Render particles
  @override
  void render(Canvas canvas) {
    for (final p in _particles) {
      final alpha = (p.life / p.maxLife).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withOpacity(alpha);
      canvas.drawRect(
        Rect.fromLTWH(p.x, p.y, p.size, p.size),
        paint,
      );
    }
  }
}
