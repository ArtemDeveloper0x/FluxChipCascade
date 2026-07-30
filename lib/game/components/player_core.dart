import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import '../flux_game.dart';

/// The central energy core controlled by the player.
/// Renders with a pulsing double-glow, rotating energy ring, and a
/// red warning halo while invulnerable (after taking damage).
class PlayerCore extends PositionComponent with HasGameReference<FluxGame> {
  PlayerCore({required Vector2 position})
      : super(position: position, size: Vector2.all(64), anchor: Anchor.center);

  double radius = 30;
  double invulnTimer = 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (invulnTimer > 0) invulnTimer -= dt;
  }

  @override
  void render(Canvas canvas) {
    final t      = game.totalTime;
    final center = size / 2;             // Vector2
    final c      = Offset(center.x, center.y);

    // ── outer ambient glow ────────────────────────────────────────────────
    final pulse = 0.5 + 0.5 * sin(t * 2.8);
    final outerGlow = Paint()
      ..color = const Color(0xFF3DE8FF).withValues(alpha: 0.22 + 0.10 * pulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    canvas.drawCircle(c, radius * 2.0, outerGlow);

    // ── rotating energy ring ──────────────────────────────────────────────
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF3DE8FF).withValues(alpha: 0.28 + 0.14 * pulse);

    const ringR = 38.0;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(t * 0.9);
    const segments = 12;
    for (int i = 0; i < segments; i++) {
      if (i % 3 == 0) continue;
      final a0 = i * 2 * pi / segments;
      final a1 = a0 + 2 * pi / segments * 0.75;
      canvas.drawArc(
          Rect.fromCircle(center: Offset.zero, radius: ringR),
          a0, a1 - a0, false, ringPaint);
    }
    canvas.restore();

    // ── sprite ────────────────────────────────────────────────────────────
    final scalePop = 1.0 + 0.04 * sin(t * 3.1);
    final sprite   = game.sprites.mainSphere(7);
    final sz       = radius * 2 * scalePop;
    final origin   = center - Vector2(sz / 2, sz / 2);
    sprite.render(canvas, position: origin, size: Vector2(sz, sz));

    // inner glow on top of sprite
    final innerGlow = Paint()
      ..color = const Color(0xFF6FE9FF).withValues(alpha: 0.18 + 0.08 * pulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(c, radius * 0.8, innerGlow);

    // ── damage / invuln indicator ─────────────────────────────────────────
    if (invulnTimer > 0) {
      final frac  = (invulnTimer / 0.35).clamp(0.0, 1.0);
      final flash = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..color = const Color(0xFFFF3D5A).withValues(alpha: frac * 0.85);
      canvas.drawCircle(c, radius + 6, flash);
      // red core tint
      final tint = Paint()..color = const Color(0xFFFF3D5A).withValues(alpha: frac * 0.35);
      canvas.drawCircle(c, radius, tint);
    }
  }
}
