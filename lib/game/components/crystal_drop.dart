import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import '../flux_game.dart';

class CrystalDrop extends PositionComponent with HasGameReference<FluxGame> {
  CrystalDrop({required Vector2 position, required this.value})
      : spriteIndex = value % 27,
        super(position: position, size: Vector2.all(28), anchor: Anchor.center);

  final int value;
  final int spriteIndex;
  double life = 8;

  @override
  void update(double dt) {
    super.update(dt);
    life -= dt;
    if (life <= 0) {
      removeFromParent();
      return;
    }
    final toPlayer = game.player.position - position;
    final dist = toPlayer.length;
    final attractRadius = 130 * game.runState.attractRadiusMult;
    if (dist < attractRadius && dist > 1) {
      position += toPlayer.normalized() * (280 * dt);
    }
    if (dist < 24) {
      game.onCollectCrystal(value);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final center = size.toOffset() / 2;
    final glow = Paint()
      ..color = const Color(0xFFFFD84D).withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, 16, glow);
    final sprite = game.sprites.crystal(spriteIndex);
    final drawSize = Vector2.all(24);
    sprite.render(canvas, position: center.toVector2() - drawSize / 2, size: drawSize);
  }
}
