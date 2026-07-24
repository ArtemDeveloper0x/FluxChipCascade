import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import '../flux_game.dart';

/// A collectible sphere scattered on the map. Touching it with the core
/// converts it into a new orbital satellite.
class NeutralSphere extends PositionComponent with HasGameReference<FluxGame> {
  NeutralSphere({required Vector2 position, required this.spriteIndex})
      : super(position: position, size: Vector2.all(36), anchor: Anchor.center);

  final int spriteIndex;
  double radius = 16;
  double _age = 0;   // used for bob + spawn fade-in
  bool _collected = false;

  @override
  void update(double dt) {
    super.update(dt);
    if (_collected) return;
    _age += dt;

    final toPlayer = game.player.position - position;
    final dist = toPlayer.length;
    final attractRadius = 110.0 * game.runState.attractRadiusMult;

    if (dist < attractRadius && dist > 1) {
      // Quadratic ease-in: gentle tug at edge, magnetic snap near centre
      final t = 1.0 - (dist / attractRadius).clamp(0.0, 1.0);
      final pullSpeed = 90.0 + 480.0 * t * t;
      position += toPlayer.normalized() * pullSpeed * dt;
    }

    if (dist < game.player.radius + radius) {
      _collected = true;
      game.onCollectSphere(this);
    }
  }

  @override
  void render(Canvas canvas) {
    final center = size.toOffset() / 2;

    // spawn fade-in over first 0.4 s
    final alpha = (_age / 0.4).clamp(0.0, 1.0);

    // gentle bob
    final bob = sin(_age * 2.2) * 2.4;

    canvas.save();
    canvas.translate(0, bob);
    canvas.saveLayer(null, Paint()..color = Color.fromRGBO(255, 255, 255, alpha));

    final glow = Paint()
      ..color = const Color(0xFF9BFFEA).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, radius * 1.4, glow);

    final sprite = game.sprites.neutralSphere(spriteIndex);
    final drawSize = Vector2.all(radius * 2);
    sprite.render(canvas, position: center.toVector2() - drawSize / 2, size: drawSize);

    canvas.restore(); // restores the layer
    canvas.restore(); // restores the translate
  }
}
