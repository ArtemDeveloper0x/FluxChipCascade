import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import '../flux_game.dart';

/// One orbital satellite: simultaneously a weapon, a shield and a chunk of
/// the player's health pool.
class Satellite extends PositionComponent with HasGameReference<FluxGame> {
  Satellite({
    required this.ring,
    required this.colorIndex,
    required this.maxHp,
  })  : hp = maxHp,
        super(size: Vector2.all(40), anchor: Anchor.center);

  int ring;
  double orbitAngle = 0; // current absolute orbit angle (radians)
  double angleOffset = 0; // assigned slot within the ring
  final int colorIndex;
  double maxHp;
  double hp;
  double radius = 18;
  bool infected = false;
  double infectionTimer = 0;
  double disabledTimer = 0; // Prism Titan ability
  double hitFlash = 0;

  // spawn pop: grows from 0 → 1 over 0.35 s using elastic ease-out
  double _spawnAge = 0.0;
  static const double _spawnDur = 0.35;

  double get _spawnScale {
    if (_spawnAge >= _spawnDur) return 1.0;
    final t = _spawnAge / _spawnDur;
    // elastic ease-out: overshoot a bit then settle at 1
    return 1.0 + 0.25 * sin(t * pi * 1.5) * (1.0 - t);
  }

  bool get isInfected => infected;
  bool get isDisabled => disabledTimer > 0;

  void takeDamage(double amount) {
    if (amount <= 0) return;
    hp -= amount;
    hitFlash = 0.15;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_spawnAge < _spawnDur) _spawnAge += dt;
    if (hitFlash > 0) hitFlash -= dt;
    if (disabledTimer > 0) disabledTimer -= dt;
    if (infected) {
      infectionTimer -= dt;
    }
  }

  @override
  void render(Canvas canvas) {
    final s = _spawnScale;
    final center = size.toOffset() / 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(s, s);
    canvas.translate(-center.dx, -center.dy);

    Color glowColor = const Color(0xFF3DE8FF);
    if (infected) {
      glowColor = const Color(0xFF52FF7A);
    } else if (isDisabled) {
      glowColor = const Color(0xFF666666);
    }
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(center, radius * 1.6, glowPaint);

    final sprite = game.sprites.mainSphere(colorIndex);
    final drawSize = Vector2.all(radius * 2);
    sprite.render(canvas, position: center.toVector2() - drawSize / 2, size: drawSize);

    if (isDisabled) {
      final overlay = Paint()..color = const Color(0xAA111111);
      canvas.drawCircle(center, radius, overlay);
    }
    if (infected) {
      final overlay = Paint()..color = const Color(0x5552FF7A);
      canvas.drawCircle(center, radius * 1.1, overlay);
    }
    if (hitFlash > 0) {
      final flash = Paint()..color = Color(0xFFFFFFFF).withValues(alpha: (hitFlash / 0.15).clamp(0, 1) * 0.7);
      canvas.drawCircle(center, radius, flash);
    }

    canvas.restore();

    // hp arc
    if (hp < maxHp) {
      final pct = (hp / maxHp).clamp(0.0, 1.0);
      final arcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFFEAF3FF).withValues(alpha: 0.85);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius + 5),
        -1.5708,
        6.2832 * pct,
        false,
        arcPaint,
      );
    }
  }
}
