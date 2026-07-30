import 'dart:math';
import 'package:flame/components.dart';
import 'data/enemy_data.dart';
import 'flux_game.dart';

enum RunPhase { waves, miniBoss, finalBoss, complete }

/// Drives enemy spawning, wave progression, periodic mini-bosses and the
/// final area boss for the current level.
class WaveManager {
  WaveManager(this.game);

  final FluxGame game;
  final Random _rng = Random();

  int currentWave = 1;
  RunPhase phase = RunPhase.waves;
  double spawnTimer = 0;
  int enemiesSpawnedThisWave = 0;
  int enemiesToSpawnThisWave = 0;
  bool waveAnnounced = false;

  void start() {
    _beginWave();
  }

  void _beginWave() {
    enemiesSpawnedThisWave = 0;
    enemiesToSpawnThisWave =
        game.level.enemiesPerWave + (currentWave * 0.6).round();
    spawnTimer = 0;
    waveAnnounced = false;
    game.runState.wave = currentWave;
    game.runState.pushHudUpdate();
  }

  List<EnemyType> _weightedPool() {
    final progress = currentWave / game.level.waveCount;
    final pool = <EnemyType>[EnemyType.hunter, EnemyType.hunter, EnemyType.hunter];
    if (progress > 0.1) pool.addAll([EnemyType.swarmer, EnemyType.swarmer]);
    if (progress > 0.15) pool.addAll([EnemyType.sniper, EnemyType.sniper]);
    if (progress > 0.25) pool.addAll([EnemyType.kamikaze]);
    if (progress > 0.35) pool.add(EnemyType.splitter);
    if (progress > 0.4) pool.addAll([EnemyType.destroyer]);
    if (progress > 0.5) pool.addAll([EnemyType.magnet]);
    if (progress > 0.6) {
      final virusWeight =
          (2 * game.runState.eventVirusWeightMult).round().clamp(1, 8);
      pool.addAll(List.filled(virusWeight, EnemyType.virusBall));
    }
    // Each biome leans into a different threat, matching its theme.
    switch (game.level.locationIndex) {
      case 0: // Crystal Garden: calm, mostly stragglers.
        pool.addAll([EnemyType.hunter, EnemyType.hunter]);
        break;
      case 1: // Neon Factory: disruptive support enemies everywhere.
        if (progress > 0.2) pool.addAll([EnemyType.magnet, EnemyType.magnet]);
        pool.add(EnemyType.kamikaze);
        break;
      case 2: // Prism Caves: reflective, ranged-heavy.
        pool.addAll([EnemyType.sniper, EnemyType.sniper]);
        if (progress > 0.3) pool.add(EnemyType.sniper);
        break;
      case 3: // Void Sector: scarce resources, elite pressure.
        pool.addAll([EnemyType.destroyer, EnemyType.destroyer]);
        if (progress > 0.3) pool.add(EnemyType.virusBall);
        break;
      case 4: // Core Reactor: everything, all at once.
        pool.addAll([
          EnemyType.destroyer,
          EnemyType.kamikaze,
          EnemyType.magnet,
          EnemyType.sniper,
          EnemyType.virusBall,
          EnemyType.splitter,
          EnemyType.swarmer,
        ]);
        break;
    }
    return pool;
  }

  void update(double dt) {
    if (game.runState.gameOver || game.runState.victory) return;

    switch (phase) {
      case RunPhase.waves:
        _updateWaves(dt);
        break;
      case RunPhase.miniBoss:
      case RunPhase.finalBoss:
        // handled entirely by boss-death callback
        break;
      case RunPhase.complete:
        break;
    }
  }

  void _updateWaves(double dt) {
    if (enemiesSpawnedThisWave < enemiesToSpawnThisWave &&
        game.enemies.length < game.level.maxConcurrentEnemies) {
      spawnTimer -= dt;
      if (spawnTimer <= 0) {
        spawnTimer = game.level.spawnInterval;
        enemiesSpawnedThisWave += _spawnEnemy();
      }
    }

    final waveCleared =
        enemiesSpawnedThisWave >= enemiesToSpawnThisWave && game.enemies.isEmpty;
    if (waveCleared) {
      if (currentWave % 3 == 0 && currentWave != game.level.waveCount) {
        phase = RunPhase.miniBoss;
        game.spawnMiniBoss(isFinal: false);
      } else if (currentWave >= game.level.waveCount) {
        phase = RunPhase.finalBoss;
        game.spawnMiniBoss(isFinal: true);
      } else {
        currentWave++;
        _beginWave();
      }
    }
  }

  void onMiniBossCleared() {
    if (phase == RunPhase.finalBoss) {
      phase = RunPhase.complete;
      game.onLevelVictory();
      return;
    }
    phase = RunPhase.waves;
    currentWave++;
    _beginWave();
  }

  /// Spawns one enemy (or a whole pack for swarmers) and returns how many
  /// units were actually added, so the wave counter stays accurate.
  int _spawnEnemy() {
    final pool = _weightedPool();
    final type = pool[_rng.nextInt(pool.length)];
    final def = kEnemyDefs[type]!;
    final level = game.level;
    final hp = def.baseHp * level.enemyHpMult;
    final dmg = def.baseDamage * level.enemyDamageMult;
    final speed = def.baseSpeed * level.enemySpeedMult;

    final angle = _rng.nextDouble() * pi * 2;
    final spawnRadius = game.spawnRingRadius();
    final basePos = game.player.position +
        Vector2(cos(angle), sin(angle)) * spawnRadius;

    // Swarmers arrive as a large fast-moving pack for extra chaos; other basic
    // enemies occasionally arrive in pairs so the field stays busy and readable.
    int count;
    if (type == EnemyType.swarmer) {
      count = 4 + _rng.nextInt(4); // 4..7
    } else if (type == EnemyType.hunter && _rng.nextDouble() < 0.5) {
      count = 2;
    } else {
      count = 1;
    }
    for (int i = 0; i < count; i++) {
      final jitter = Vector2(
        (_rng.nextDouble() - 0.5) * 90,
        (_rng.nextDouble() - 0.5) * 90,
      );
      game.addEnemy(
        type: type,
        tier: level.tier,
        position: basePos + jitter,
        hp: hp,
        damage: dmg,
        speed: speed,
      );
    }
    return count;
  }
}
