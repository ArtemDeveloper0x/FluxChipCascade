import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import '../data/enemy_data.dart';
import '../flux_game.dart';

/// Mini-boss / area-boss component. Each [MiniBossType] gets a distinct
/// periodic ability, matching the design document.
class BossEntity extends PositionComponent with HasGameReference<FluxGame> {
  BossEntity({
    required Vector2 position,
    required this.type,
    required double hp,
    required this.damage,
    required this.isFinalBoss,
  })  : maxHp = hp,
        hp = hp,
        shieldLayers = type == MiniBossType.crystalColossus ? 3 : 0,
        super(position: position, size: Vector2.all(180), anchor: Anchor.center);

  final MiniBossType type;
  double maxHp;
  double hp;
  double damage;
  final bool isFinalBoss;
  int shieldLayers;
  double radius = 80;
  double speed = 26;
  double abilityCooldown = 3.5;
  double hitFlash = 0;
  bool dying = false;

  MiniBossDef get def => kMiniBossDefs[type]!;

  void takeDamage(double amount) {
    if (dying) return;
    if (shieldLayers > 0) {
      final layerHp = maxHp / 4;
      hp -= amount;
      if (hp <= layerHp * shieldLayers) {
        shieldLayers--;
      }
    } else {
      hp -= amount;
    }
    hitFlash = 0.12;
    if (hp <= 0) {
      dying = true;
      game.onBossKilled(this);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (dying) return;
    if (hitFlash > 0) hitFlash -= dt;

    final toPlayer = game.player.position - position;
    final dist = toPlayer.length;
    const preferred = 260.0;
    if (dist > preferred) {
      position += toPlayer.normalized() * speed * game.runState.eventSpeedMult * dt;
    }

    abilityCooldown -= dt;
    if (abilityCooldown <= 0) {
      abilityCooldown = 4.5;
      _useAbility();
    }

    _resolveContact(dt);
  }

  void _useAbility() {
    switch (type) {
      case MiniBossType.hiveCore:
        game.onBossSpawnMinion(position);
        break;
      case MiniBossType.orbitBreaker:
        game.onBossShockwave(position, damage * 2.4);
        break;
      case MiniBossType.prismTitan:
        game.onBossDisableSatellites(3, 3.5);
        break;
      case MiniBossType.magneticEye:
        game.onBossRadiusDistort();
        break;
      case MiniBossType.crystalColossus:
        game.onBossShockwave(position, damage * 1.4);
        break;
    }
  }

  void _resolveContact(double dt) {
    final satellites = game.orbitManager.satellites;
    bool touchedAny = false;
    for (final sat in List.of(satellites)) {
      if (sat.isDisabled) continue;
      final d = (sat.position - position).length;
      if (d < sat.radius + radius) {
        touchedAny = true;
        sat.takeDamage(damage * dt);
      }
    }
    if (!touchedAny && satellites.isEmpty) {
      final d = (game.player.position - position).length;
      if (d < game.player.radius + radius) {
        game.onCoreDamaged(damage * dt);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final center = size.toOffset() / 2;
    final glow = Paint()
      ..color = def.tint.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26);
    canvas.drawCircle(center, radius * 1.35, glow);

    final sprite = game.sprites.miniBoss(type);
    final drawSize = Vector2.all(radius * 2.1);
    final paint = hitFlash > 0
        ? (Paint()..colorFilter = const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcATop))
        : null;
    sprite.render(canvas,
        position: center.toVector2() - drawSize / 2,
        size: drawSize,
        overridePaint: paint);

    if (shieldLayers > 0) {
      for (int i = 0; i < shieldLayers; i++) {
        final ringPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = def.tint.withValues(alpha: 0.6);
        canvas.drawCircle(center, radius + 14 + i * 10, ringPaint);
      }
    }

    // hp bar
    final pct = (hp / maxHp).clamp(0.0, 1.0);
    final barW = radius * 2.2;
    final bg = Paint()..color = const Color(0x66101024);
    final fg = Paint()..color = def.tint;
    final rect = Rect.fromCenter(
        center: center.translate(0, -radius - 26), width: barW, height: 8);
    canvas.drawRect(rect, bg);
    canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, barW * pct, 8), fg);
  }
}
