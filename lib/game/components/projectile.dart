import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import '../flux_game.dart';

/// A slow energy bolt fired by ranged enemies (Sniper), targeting the
/// nearest satellite or, if there is none, the player core.
class Projectile extends PositionComponent with HasGameReference<FluxGame> {
  Projectile({
    required Vector2 position,
    required Vector2 direction,
    this.damage = 8,
    this.speed = 220,
    this.color = const Color(0xFFE93DFF),
  })  : direction = direction.normalized(),
        super(position: position, size: Vector2.all(14), anchor: Anchor.center);

  Vector2 direction;
  double speed;
  double damage;
  Color color;
  double life = 5;
  bool reflected = false;

  @override
  void update(double dt) {
    super.update(dt);
    life -= dt;
    if (life <= 0) {
      removeFromParent();
      return;
    }
    position += direction * speed * dt;

    // check hits against satellites
    for (final sat in List.of(game.orbitManager.satellites)) {
      if (sat.isDisabled) continue;
      if ((sat.position - position).length < sat.radius + 7) {
        if (game.runState.reflectProjectiles && !reflected) {
          reflected = true;
          direction = -direction;
          color = const Color(0xFF52FF7A);
          game.audio.sfx('Projectile_reflection_asset.mp3');
          return;
        }
        sat.takeDamage(damage);
        game.audio.sfx('energy_impact_asset.mp3', volume: 0.5);
        removeFromParent();
        return;
      }
    }
    if (game.orbitManager.satellites.isEmpty) {
      if ((game.player.position - position).length < game.player.radius + 7) {
        game.onCoreDamaged(damage);
        removeFromParent();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final center = size.toOffset() / 2;
    final glow = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, 10, glow);
    final core = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(center, 4, core);
  }
}
