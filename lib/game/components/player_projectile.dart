import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import '../flux_game.dart';
import 'enemy_entity.dart';

/// A fast energy bolt fired automatically by the player's core Pulse Cannon.
/// It flies toward the nearest hostile (enemy or boss) and damages the first
/// one it touches. Upgrades can make it home in on targets, pierce through
/// several enemies, or arc chain-lightning on impact.
class PlayerProjectile extends PositionComponent
    with HasGameReference<FluxGame> {
  PlayerProjectile({
    required Vector2 position,
    required Vector2 direction,
    required this.damage,
    this.speed = 460,
    this.color = const Color(0xFF3DE8FF),
    this.homing = false,
    this.pierce = 0,
    this.chain = false,
  })  : direction = direction.normalized(),
        super(position: position, size: Vector2.all(14), anchor: Anchor.center);

  Vector2 direction;
  double speed;
  double damage;
  Color color;
  bool homing;
  int pierce;
  bool chain;
  double life = 2.4;

  final Set<int> _alreadyHit = {};

  @override
  void update(double dt) {
    super.update(dt);
    life -= dt;
    if (life <= 0) {
      removeFromParent();
      return;
    }

    if (homing) _steerTowardTarget(dt);
    position += direction * speed * dt;

    // Boss takes priority as a target.
    final boss = game.currentBoss;
    if (boss != null && !boss.dying) {
      if ((boss.position - position).length < boss.radius + 8) {
        boss.takeDamage(damage);
        if (chain) game.onProjectileChain(position.clone(), damage, null);
        _onImpact(null);
        return;
      }
    }

    for (final enemy in List.of(game.enemies)) {
      if (enemy.dying) continue;
      if (_alreadyHit.contains(identityHashCode(enemy))) continue;
      if ((enemy.position - position).length < enemy.radius + 8) {
        enemy.takeDamage(damage);
        if (chain) game.onProjectileChain(position.clone(), damage, enemy);
        _onImpact(enemy);
        return;
      }
    }
  }

  void _onImpact(EnemyEntity? enemy) {
    if (pierce > 0) {
      pierce--;
      if (enemy != null) _alreadyHit.add(identityHashCode(enemy));
      return; // keep flying through
    }
    removeFromParent();
  }

  void _steerTowardTarget(double dt) {
    Vector2? targetPos;
    final boss = game.currentBoss;
    if (boss != null && !boss.dying) {
      targetPos = boss.position;
    } else {
      double best = double.infinity;
      for (final e in game.enemies) {
        if (e.dying || _alreadyHit.contains(identityHashCode(e))) continue;
        final d = (e.position - position).length2;
        if (d < best) {
          best = d;
          targetPos = e.position;
        }
      }
    }
    if (targetPos == null) return;
    final desired = (targetPos - position).normalized();
    // Blend current heading toward the target for a smooth curve.
    direction = (direction + desired * (dt * 6)).normalized();
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
