import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import '../data/enemy_data.dart';
import '../flux_game.dart';
import 'projectile.dart';
import 'satellite.dart';

/// Generic enemy component whose behavior branches on [EnemyType].
class EnemyEntity extends PositionComponent with HasGameReference<FluxGame> {
  EnemyEntity({
    required Vector2 position,
    required this.type,
    required this.tier,
    required double hp,
    required this.speed,
    required this.damage,
  })  : maxHp = hp,
        hp = hp,
        radius = kEnemyDefs[type]!.baseRadius,
        super(position: position, size: Vector2.all(50), anchor: Anchor.center);

  final EnemyType type;
  final int tier;
  double maxHp;
  double hp;
  double speed;
  double damage;
  double radius;

  double rangedCooldown = 1.6;
  double magnetPulseCooldown = 2.2;
  double hitFlash = 0;
  bool dying = false;
  double approachDistance = 0;

  EnemyDef get def => kEnemyDefs[type]!;

  void takeDamage(double amount) {
    if (dying) return;
    hp -= amount;
    hitFlash = 0.12;
    if (hp <= 0) {
      dying = true;
      game.onEnemyKilled(this);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (dying) return;
    if (hitFlash > 0) hitFlash -= dt;

    final speedMult = game.runState.eventSpeedMult;
    final toPlayer = game.player.position - position;
    final dist = toPlayer.length;

    switch (type) {
      case EnemyType.hunter:
        if (dist > 1) position += toPlayer.normalized() * speed * speedMult * dt;
        break;
      case EnemyType.destroyer:
        if (dist > 1) position += toPlayer.normalized() * speed * speedMult * dt;
        break;
      case EnemyType.kamikaze:
        if (dist > 1) position += toPlayer.normalized() * speed * speedMult * dt;
        break;
      case EnemyType.sniper:
        _rangedBehavior(dt, toPlayer, dist, speedMult);
        break;
      case EnemyType.magnet:
        _magnetBehavior(dt, toPlayer, dist, speedMult);
        break;
      case EnemyType.virusBall:
        if (dist > 1) position += toPlayer.normalized() * speed * speedMult * dt;
        break;
      case EnemyType.swarmer:
        if (dist > 1) position += toPlayer.normalized() * speed * speedMult * dt;
        break;
      case EnemyType.splitter:
        if (dist > 1) position += toPlayer.normalized() * speed * speedMult * dt;
        break;
    }

    _resolveCollisions(dt);
  }

  void _rangedBehavior(double dt, Vector2 toPlayer, double dist, double speedMult) {
    const preferred = 340.0;
    if (dist > preferred + 20) {
      position += toPlayer.normalized() * speed * speedMult * dt;
    } else if (dist < preferred - 20) {
      position -= toPlayer.normalized() * speed * speedMult * dt;
    } else {
      final tangent = Vector2(-toPlayer.y, toPlayer.x).normalized();
      position += tangent * (speed * 0.4) * speedMult * dt;
    }
    rangedCooldown -= dt;
    if (rangedCooldown <= 0 && dist < 520) {
      rangedCooldown = 1.8;
      final target = game.orbitManager.satellites.isNotEmpty
          ? game.orbitManager.satellites[
                  Random().nextInt(game.orbitManager.satellites.length)]
              .position
          : game.player.position;
      final dir = (target - position);
      game.world.add(Projectile(
        position: position.clone(),
        direction: dir,
        damage: damage,
      ));
    }
  }

  void _magnetBehavior(double dt, Vector2 toPlayer, double dist, double speedMult) {
    const preferred = 220.0;
    if (dist > preferred) {
      position += toPlayer.normalized() * speed * speedMult * dt;
    }
    magnetPulseCooldown -= dt;
    if (magnetPulseCooldown <= 0 && dist < 420) {
      magnetPulseCooldown = 3.2;
      game.onMagnetPulse(position);
    }
  }

  void _resolveCollisions(double dt) {
    if (type == EnemyType.kamikaze) {
      final distToCore = (game.player.position - position).length;
      final satellites = game.orbitManager.satellites;
      Satellite? nearest;
      double nearestDist = double.infinity;
      for (final s in satellites) {
        final d = (s.position - position).length;
        if (d < nearestDist) {
          nearestDist = d;
          nearest = s;
        }
      }
      final triggerDist = radius + (nearest?.radius ?? game.player.radius) + 4;
      if ((nearest != null && nearestDist < triggerDist) ||
          (satellites.isEmpty && distToCore < radius + game.player.radius + 4)) {
        game.onKamikazeExplode(this);
      }
      return;
    }

    final satellites = game.orbitManager.satellites;
    final satDamagePerSecond = 20.0 *
        game.runState.damageMult *
        game.runState.eventDamageMult;
    bool touchedAny = false;
    for (final sat in List.of(satellites)) {
      if (sat.isDisabled) continue;
      final d = (sat.position - position).length;
      if (d < sat.radius + radius) {
        touchedAny = true;
        // Satellites are sturdier now so the orbit isn't shredded instantly.
        sat.takeDamage(damage * 0.6 * dt);
        takeDamage(satDamagePerSecond * dt);
        if (type == EnemyType.virusBall && !sat.infected) {
          game.onVirusInfect(sat);
        }
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
      ..color = def.tint.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(center, radius * 1.5, glow);

    final sprite = game.sprites.enemySprite(type, tier);
    final drawSize = Vector2.all(radius * 2.3);
    final paint = hitFlash > 0
        ? (Paint()..colorFilter = const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcATop))
        : null;
    sprite.render(canvas,
        position: center.toVector2() - drawSize / 2,
        size: drawSize,
        overridePaint: paint);

    if (hp < maxHp) {
      final pct = (hp / maxHp).clamp(0.0, 1.0);
      final bg = Paint()..color = const Color(0x552A2A40);
      final fg = Paint()..color = def.tint;
      final barW = radius * 2;
      final rect = Rect.fromCenter(
          center: center.translate(0, -radius - 10), width: barW, height: 4);
      canvas.drawRect(rect, bg);
      canvas.drawRect(
          Rect.fromLTWH(rect.left, rect.top, barW * pct, 4), fg);
    }
  }
}
