import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import '../flux_game.dart';

/// Improved multi-ring burst.  Three concentric rings expand at different
/// speeds, each with its own opacity curve, giving a punchy layered feel.
class FxBurst extends PositionComponent with HasGameReference<FluxGame> {
  FxBurst({
    required Vector2 position,
    required this.spriteIndex,
    this.maxRadius = 70,
    this.duration  = 0.45,
    this.color     = const Color(0xFFFFFFFF),
  }) : super(position: position, size: Vector2.all(1), anchor: Anchor.center);

  final int spriteIndex;
  final double maxRadius;
  final double duration;
  final Color color;
  double _t = 0;

  // ── ring descriptors ────────────────────────────────────────────────────
  // Each entry: [startFrac, endFrac, radiusMult, maxAlpha]
  static const _rings = [
    // flash: instant bright white ring that peaks early
    [0.00, 0.30, 0.55, 0.90],
    // main: slower, full radius
    [0.05, 0.85, 1.00, 0.70],
    // trailing: very large, mostly transparent halo
    [0.20, 1.00, 1.50, 0.30],
  ];

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    if (_t >= duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final pct = (_t / duration).clamp(0.0, 1.0);

    // sprite behind all rings (orientation, scales with main ring)
    final mainPct = _easeOut((pct - 0.05).clamp(0.0, 1.0) / 0.80);
    final spriteR  = maxRadius * (0.25 + 0.75 * mainPct);
    final spriteA  = (1.0 - pct) * 0.85;
    if (spriteA > 0.01 && spriteR > 1) {
      final spritePaint = Paint()
          ..color = Color.fromRGBO(255, 255, 255, spriteA);
      final drawSize = Vector2.all(spriteR * 2);
      game.sprites.destructionFx(spriteIndex).render(
          canvas, position: -drawSize / 2, size: drawSize,
          overridePaint: spritePaint);
    }

    // rings
    for (final ring in _rings) {
      final rStart   = ring[0];
      final rEnd     = ring[1];
      final rMult    = ring[2];
      final maxAlpha = ring[3];
      if (pct < rStart || pct > rEnd) continue;

      final localT = ((pct - rStart) / (rEnd - rStart)).clamp(0.0, 1.0);
      final radius = maxRadius * rMult * _easeOut(localT);
      // alpha: ramp up first 20 %, then fade out
      final alpha = (localT < 0.2
          ? localT / 0.2
          : (1.0 - localT) / 0.8) * maxAlpha;

      if (radius < 1) continue;
      // glow halo
      final glowPaint = Paint()
        ..color = color.withValues(alpha: alpha * 0.55)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, (radius * 0.35).clamp(1, 60));
      canvas.drawCircle(Offset.zero, radius, glowPaint);

      // hard ring stroke
      final ringPaint = Paint()
        ..color = color.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.0, 3.0 * (1.0 - localT));
      canvas.drawCircle(Offset.zero, radius, ringPaint);
    }
  }

  static double _easeOut(double t) => 1.0 - pow(1.0 - t, 2.5).toDouble();
}
