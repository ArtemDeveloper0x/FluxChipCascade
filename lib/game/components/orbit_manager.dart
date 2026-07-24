import 'dart:math';
import 'package:flame/components.dart';
import 'satellite.dart';
import '../flux_game.dart';

/// Keeps every [Satellite] evenly distributed across concentric rings around
/// the player core, and updates their world position every frame.
class OrbitManager {
  OrbitManager(this.game);

  final FluxGame game;
  final List<Satellite> satellites = [];

  static const List<int> ringCapacity = [8, 12, 16, 20, 24, 28];
  static const double baseRadius = 70;
  static const double ringGap = 46;

  double _time = 0;
  int _colorCycle = 0;

  int get ringCount {
    final extra = game.runState.extraLayers;
    return (1 + extra).clamp(1, ringCapacity.length);
  }

  double ringRadius(int ring) {
    double distort = 1.0;
    if (game.radiusDistortTimer > 0) {
      distort += 0.28 * sin(_time * 3.4);
    }
    return (baseRadius + ring * ringGap) * game.runState.orbitRadiusMult * distort;
  }

  double ringAngularSpeed(int ring) {
    final base = 0.55 + ring * 0.12;
    final dir = ring.isEven ? 1.0 : -1.0;
    return base * dir * game.runState.orbitSpeedMult * game.runState.eventSpeedMult;
  }

  void addSatellite() {
    final ring = _assignRing();
    final colorIndex = _colorCycle++ % 10;
    final maxHp = 44.0 * game.runState.satelliteHpMult;
    final sat = Satellite(ring: ring, colorIndex: colorIndex, maxHp: maxHp);
    satellites.add(sat);
    game.world.add(sat);
    _redistribute();
    game.runState.satelliteCount = satellites.length;
    game.runState.pushHudUpdate();
  }

  int _assignRing() {
    final maxRing = ringCount;
    for (int r = 0; r < maxRing; r++) {
      final count = satellites.where((s) => s.ring == r).length;
      if (count < ringCapacity[r]) return r;
    }
    return maxRing - 1;
  }

  void removeSatellite(Satellite sat) {
    satellites.remove(sat);
    sat.removeFromParent();
    _redistribute();
    game.runState.satelliteCount = satellites.length;
    game.runState.pushHudUpdate();
  }

  void _redistribute() {
    final byRing = <int, List<Satellite>>{};
    for (final s in satellites) {
      byRing.putIfAbsent(s.ring, () => []).add(s);
    }
    byRing.forEach((ring, list) {
      for (int i = 0; i < list.length; i++) {
        list[i].angleOffset = (2 * pi / list.length) * i;
      }
    });
  }

  void update(double dt) {
    _time += dt;
    final playerPos = game.player.position;
    // Iterate over a copy: completing an infection removes a satellite from
    // [satellites] mid-loop, which would otherwise throw
    // ConcurrentModificationError.
    for (final sat in List.of(satellites)) {
      final speed = ringAngularSpeed(sat.ring);
      sat.orbitAngle = sat.angleOffset + _time * speed;
      final r = ringRadius(sat.ring);
      sat.position = playerPos +
          Vector2(cos(sat.orbitAngle), sin(sat.orbitAngle)) * r;

      if (game.runState.satelliteRegen) {
        sat.hp = min(sat.maxHp, sat.hp + sat.maxHp * 0.03 * dt);
      }
      if (sat.infected && sat.infectionTimer <= 0) {
        game.onSatelliteInfectionComplete(sat);
      }
    }

    for (final sat in List.of(satellites)) {
      if (sat.hp <= 0 && !sat.infected) {
        game.onSatelliteDestroyed(sat);
      }
    }
  }

  void clear() {
    for (final s in List.of(satellites)) {
      s.removeFromParent();
    }
    satellites.clear();
  }
}
