import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import '../flux_game.dart';

/// A fast energy bolt fired automatically by the player's core Pulse Cannon.
/// It flies toward the nearest hostile (enemy or boss) and damages the first
/// one it touches. This is the player's reliable ranged damage source, making
/// kiting enemies and bosses actually killable.
class PlayerProjectile extends PositionComponent
    with HasGameReference<FluxGame> {
  PlayerProjectile({
    required Vector2 position,
    required Vector2 direction,
    required this.damage,
    this.speed = 460,
    this.color = const Color(0xFF3DE8FF),
  })  : direction = direction.normalized(),
        super(position: position, size: Vector2.all(14), anchor: Anchor.center);

  Vector2 direction;
  double speed;
  double damage;
  Color color;
  double life = 2.4;

  @override
  void update(double dt) {
    super.update(dt);
    life -= dt;
    if (life <= 0) {
      removeFromParent();
      return;
    }
    position += direction * speed * dt;

    // Boss takes priority as a target.
    final boss = game.currentBoss;
    if (boss != null && !boss.dying) {
      if ((boss.position - position).length < boss.radius + 8) {
        boss.takeDamage(damage);
        removeFromParent();
        return;
      }
    }

    for (final enemy in List.of(game.enemies)) {
      if (enemy.dying) continue;
      if ((enemy.position - position).length < enemy.radius + 8) {
        enemy.takeDamage(damage);
        removeFromParent();
        return;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final center = size.toOffset() / 2;
    // Cheap two-circle glow (no MaskFilter.blur) — projectiles are numerous, so
    // avoid the expensive blur that was tanking the frame rate.
    final glow = Paint()..color = color.withValues(alpha: 0.35);
    canvas.drawCircle(center, 8, glow);
    final mid = Paint()..color = color.withValues(alpha: 0.8);
    canvas.drawCircle(center, 5, mid);
    final coreP = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(center, 3, coreP);
  }
}
