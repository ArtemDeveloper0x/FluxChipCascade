import 'dart:math';
import 'dart:ui' show Color;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import '../core/audio_manager.dart';
import '../core/constants.dart';
import '../core/storage_service.dart';
import 'components/background_layer.dart';
import 'components/boss_entity.dart';
import 'components/crystal_drop.dart';
import 'components/enemy_entity.dart';
import 'components/floating_joystick.dart';
import 'components/fx_burst.dart';
import 'components/neutral_sphere.dart';
import 'components/orbit_manager.dart';
import 'components/player_core.dart';
import 'components/player_projectile.dart';
import 'components/satellite.dart';
import 'data/enemy_data.dart';
import 'data/event_data.dart';
import 'data/level_data.dart';
import 'data/upgrade_data.dart';
import 'event_manager.dart';
import 'run_state.dart';
import 'sprite_atlas.dart';
import 'wave_manager.dart';

/// Callbacks the surrounding Flutter UI (GameScreen) hooks into.
class FluxGameCallbacks {
  final void Function(List<int> upgradeIndexes) onUpgradeChoice;
  final void Function() onGameOver;
  final void Function() onVictory;
  final void Function(GameEventDef event) onEventBanner;

  FluxGameCallbacks({
    required this.onUpgradeChoice,
    required this.onGameOver,
    required this.onVictory,
    required this.onEventBanner,
  });
}

class FluxGame extends FlameGame {
  FluxGame({required this.level, required String mutationId, required this.callbacks})
      : runState = RunState(level: level, mutationId: mutationId);

  final LevelConfig level;
  final RunState runState;
  final FluxGameCallbacks callbacks;
  final AudioManager audio = AudioManager.I;

  late final GameSprites sprites;
  late final PlayerCore player;
  late final OrbitManager orbitManager;
  late final WaveManager waveManager;
  late final EventManager eventManager;

  final List<EnemyEntity> enemies = [];
  final List<NeutralSphere> spheres = [];
  BossEntity? currentBoss;

  double totalTime = 0;
  final Random rng = Random();
  double _sphereSpawnTimer = 3;
  double radiusDistortTimer = 0;
  double _electricTimer = 1.5;
  double _waveTimer = 3.5;
  double _cannonTimer = 0.6;

  // screen shake
  double _shakeMag = 0;

  late FloatingJoystick joystick;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprites = GameSprites(images);
    await sprites.preload();

    runState.applyStartingMutation();
    _applyMetaUpgrades();
    runState.coreMaxHp = (140 * runState.coreHpMult).round();
    runState.coreHp = runState.coreMaxHp;

    world.add(BackgroundLayer());

    player = PlayerCore(position: Vector2.zero());
    world.add(player);
    camera.follow(player, snap: true);
    camera.viewfinder.zoom = 0.62;

    orbitManager = OrbitManager(this);
    // Always begin the run armed with a few satellites so the player can
    // fight back immediately instead of starting defenceless.
    final startCount = (3 + runState.startingSatellitesDelta).clamp(1, 8);
    for (int i = 0; i < startCount; i++) {
      orbitManager.addSatellite();
    }

    _scatterInitialSpheres();

    _setupJoystick();

    waveManager = WaveManager(this);
    eventManager = EventManager(this);
    waveManager.start();

    await audio.playGameplayLoop();
  }

  /// Applies permanent SHOP (lab module) purchases on top of the run's
  /// starting mutation. Magnitudes mirror `kLabModules` in lab_data.dart.
  void _applyMetaUpgrades() {
    final store = StorageService.I;
    runState.coreHpMult *= 1 + 0.10 * store.labLevel('hull');
    runState.startingSatellitesDelta += store.labLevel('bay');
    runState.cannonDamageMult *= 1 + 0.08 * store.labLevel('cannon');
    runState.damageMult *= 1 + 0.06 * store.labLevel('core');
  }

  void _setupJoystick() {
    joystick = FloatingJoystick();
    camera.viewport.add(joystick);
  }

  @override
  void onRemove() {
    // When the game is torn down (level transition / quit), make absolutely
    // sure nothing keeps running in the background: pause the engine, silence
    // any audio, and drop live entity references so the next level starts
    // with a completely clean state.
    pauseEngine();
    audio.stopMusic();
    enemies.clear();
    spheres.clear();
    currentBoss = null;
    super.onRemove();
  }

  double spawnRingRadius() {
    final visible = camera.visibleWorldRect;
    return max(visible.width, visible.height) * 0.62 + 120;
  }

  void _scatterInitialSpheres() {
    final count = (14 * _locationSphereMult).round().clamp(6, 20);
    for (int i = 0; i < count; i++) {
      _spawnSphereNear(player.position, minR: 150, maxR: spawnRingRadius() * 0.85);
    }
  }

  void _spawnSphereNear(Vector2 center, {required double minR, required double maxR}) {
    final angle = rng.nextDouble() * pi * 2;
    final r = minR + rng.nextDouble() * (maxR - minR);
    final pos = center + Vector2(cos(angle), sin(angle)) * r;
    final sphere = NeutralSphere(position: pos, spriteIndex: rng.nextInt(21));
    spheres.add(sphere);
    world.add(sphere);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (runState.gameOver || runState.victory) return;

    totalTime += dt;
    runState.elapsedSeconds += dt;

    _handleMovement(dt);
    orbitManager.update(dt);
    waveManager.update(dt);
    eventManager.update(dt);
    _handleSphereSpawning(dt);
    _handleBlackHole(dt);
    _handleCannon(dt);
    _handleSpecialUpgrades(dt);
    if (radiusDistortTimer > 0) radiusDistortTimer -= dt;
    _applyShake(dt);

    enemies.removeWhere((e) => e.isRemoving || (e.dying && !e.isMounted));
    spheres.removeWhere((s) => s.isRemoving);
  }

  void _applyShake(double dt) {
    if (_shakeMag < 0.5) { _shakeMag = 0; return; }
    final dx = (rng.nextDouble() - 0.5) * 2 * _shakeMag;
    final dy = (rng.nextDouble() - 0.5) * 2 * _shakeMag;
    // offset viewfinder away from the exact player position
    camera.viewfinder.position = player.position + Vector2(dx, dy);
    _shakeMag *= (1.0 - dt * 22);
  }

  void _handleMovement(double dt) {
    final delta = joystick.relativeDelta;
    if (delta.length2 > 0.0001) {
      final speed = 210 * runState.moveSpeedMult * runState.eventSpeedMult;
      player.position += delta * speed * dt;
    }
  }

  /// Crystal Garden is resource-rich and calm; Void Sector / Core Reactor
  /// are scarce and hostile, per the design doc.
  double get _locationSphereMult {
    switch (level.locationIndex) {
      case 0:
        return 1.4;
      case 1:
        return 1.1;
      case 2:
        return 1.0;
      case 3:
        return 0.7;
      case 4:
        return 0.55;
      default:
        return 1.0;
    }
  }

  void _handleSphereSpawning(double dt) {
    _sphereSpawnTimer -= dt;
    final maxSpheres =
        (10 * runState.sphereSpawnMult * _locationSphereMult).round().clamp(4, 30);
    if (_sphereSpawnTimer <= 0 && spheres.length < maxSpheres) {
      _sphereSpawnTimer = (2.4 / runState.sphereSpawnMult) / _locationSphereMult;
      _spawnSphereNear(player.position, minR: spawnRingRadius() * 0.5, maxR: spawnRingRadius() * 0.95);
    }
  }

  void _handleBlackHole(double dt) {
    if (!runState.blackHoleActive) return;
    final center = player.position;
    for (final e in enemies) {
      final toCenter = center - e.position;
      if (toCenter.length > 4) e.position += toCenter.normalized() * 40 * dt;
    }
    for (final s in spheres) {
      final toCenter = center - s.position;
      if (toCenter.length > 4) s.position += toCenter.normalized() * 60 * dt;
    }
  }

  /// Core Pulse Cannon: periodically auto-fires energy bolts at the nearest
  /// hostile. Damage scales with the player's damage upgrades and run level so
  /// it stays relevant against tanky bosses.
  void _handleCannon(double dt) {
    if (!runState.cannonEnabled) return;
    _cannonTimer -= dt;
    if (_cannonTimer > 0) return;

    // Choose a target: prefer the active boss, otherwise the nearest enemy.
    Vector2? targetPos;
    final boss = currentBoss;
    if (boss != null && !boss.dying) {
      targetPos = boss.position;
    } else {
      double best = double.infinity;
      for (final e in enemies) {
        if (e.dying) continue;
        final d = (e.position - player.position).length2;
        if (d < best) {
          best = d;
          targetPos = e.position;
        }
      }
    }
    if (targetPos == null) {
      // Nothing to shoot at; check again shortly.
      _cannonTimer = 0.25;
      return;
    }

    final fireInterval = (0.62 / runState.cannonFireRateMult).clamp(0.18, 1.2);
    _cannonTimer = fireInterval;

    double damage = 15.0 *
        runState.cannonDamageMult *
        runState.damageMult *
        runState.eventDamageMult *
        (1 + runState.runLevel * 0.06);

    // Critical Flux: roll a crit for the whole volley.
    final isCrit = rng.nextDouble() < runState.critChance;
    if (isCrit) damage *= runState.critDamageMult;
    final boltColor =
        isCrit ? const Color(0xFFFFD84D) : const Color(0xFF3DE8FF);

    final baseDir = (targetPos - player.position);
    if (baseDir.length2 < 0.0001) baseDir.setValues(1, 0);
    final shots = 1 + runState.cannonExtraShots;
    for (int i = 0; i < shots; i++) {
      // Fan multiple shots out slightly around the aim direction.
      final spread = shots == 1 ? 0.0 : (i - (shots - 1) / 2) * 0.16;
      final dir = baseDir.clone()..rotate(spread);
      world.add(PlayerProjectile(
        position: player.position.clone(),
        direction: dir,
        damage: damage,
        color: boltColor,
        homing: runState.cannonHoming,
        pierce: runState.cannonPierce,
        chain: runState.chainLightning,
      ));
    }
  }

  /// Chain Conductor: when a bolt hits, arc a weaker strike to a second nearby
  /// enemy so crowds melt faster.
  void onProjectileChain(Vector2 origin, double damage, EnemyEntity? exclude) {
    EnemyEntity? nearest;
    double best = 260;
    for (final e in enemies) {
      if (e.dying || e == exclude) continue;
      final d = (e.position - origin).length;
      if (d < best) {
        best = d;
        nearest = e;
      }
    }
    if (nearest != null) {
      nearest.takeDamage(damage * 0.6);
      world.add(FxBurst(
          position: (origin + nearest.position) / 2,
          spriteIndex: rng.nextInt(30),
          maxRadius: 34,
          duration: 0.22,
          color: const Color(0xFF3DE8FF)));
    }
  }

  void _handleSpecialUpgrades(double dt) {
    if (runState.electricDischarge) {
      _electricTimer -= dt;
      if (_electricTimer <= 0 && orbitManager.satellites.isNotEmpty && enemies.isNotEmpty) {
        _electricTimer = 1.5;
        final sat = orbitManager.satellites[rng.nextInt(orbitManager.satellites.length)];
        EnemyEntity? nearest;
        double best = 220;
        for (final e in enemies) {
          final d = (e.position - sat.position).length;
          if (d < best) {
            best = d;
            nearest = e;
          }
        }
        if (nearest != null) {
          nearest.takeDamage(12 * runState.damageMult * runState.eventDamageMult);
          world.add(FxBurst(
              position: (sat.position + nearest.position) / 2,
              spriteIndex: rng.nextInt(30),
              maxRadius: 30,
              duration: 0.25,
              color: const Color(0xFF3DE8FF)));
        }
      }
    }
    if (runState.energyWave) {
      _waveTimer -= dt;
      if (_waveTimer <= 0) {
        _waveTimer = 4.5;
        world.add(FxBurst(
            position: player.position.clone(),
            spriteIndex: rng.nextInt(30),
            maxRadius: 260,
            duration: 0.7,
            color: const Color(0xFFE93DFF)));
        for (final e in List.of(enemies)) {
          if ((e.position - player.position).length < 260) {
            e.takeDamage(14 * runState.damageMult * runState.eventDamageMult);
          }
        }
      }
    }
  }

  // ---------------------------------------------------------------------
  // Entity lifecycle callbacks
  // ---------------------------------------------------------------------

  void addEnemy({
    required EnemyType type,
    required int tier,
    required Vector2 position,
    required double hp,
    required double damage,
    required double speed,
  }) {
    final enemy = EnemyEntity(
      position: position,
      type: type,
      tier: tier,
      hp: hp,
      damage: damage,
      speed: speed,
    );
    enemies.add(enemy);
    world.add(enemy);
  }

  void onCollectSphere(NeutralSphere sphere) {
    spheres.remove(sphere);
    sphere.removeFromParent();
    orbitManager.addSatellite();
    // Restorative Intake: each collected sphere mends the core a little.
    if (runState.pickupHealAmount > 0 &&
        runState.coreHp < runState.coreMaxHp) {
      runState.coreHp = (runState.coreHp + runState.pickupHealAmount.round())
          .clamp(0, runState.coreMaxHp);
    }
    audio.sfx(Sounds.sphereJoiningOrbit);
    StorageService.I.addSpheres(1);
    StorageService.I.addDailyQuestProgress('collect_spheres', 1);
    StorageService.I.reportOrbit(orbitManager.satellites.length);
    world.add(FxBurst(
        position: sphere.position.clone(),
        spriteIndex: rng.nextInt(30),
        maxRadius: 40,
        color: const Color(0xFF3DE8FF)));
  }

  void onEnemyKilled(EnemyEntity enemy) {
    enemies.remove(enemy);
    world.add(FxBurst(
      position: enemy.position.clone(),
      spriteIndex: rng.nextInt(30),
      maxRadius: 60,
      color: enemy.def.tint,
    ));
    enemy.removeFromParent();
    audio.sfx(Sounds.enemyDefeat, volume: 0.6);

    final crystalValue = (enemy.def.crystalDrop +
            (runState.bonusCrystalDrop ? 1 : 0)) *
        2;
    world.add(CrystalDrop(position: enemy.position.clone(), value: crystalValue));

    // Splitters burst into a pair of fast swarmers when destroyed.
    if (enemy.type == EnemyType.splitter) {
      _spawnSplitterChildren(enemy.position.clone());
    }

    // Vampiric Circuit: kills have a chance to mend the core.
    if (runState.lifestealChance > 0 &&
        rng.nextDouble() < runState.lifestealChance &&
        runState.coreHp < runState.coreMaxHp) {
      runState.coreHp =
          (runState.coreHp + 6).clamp(0, runState.coreMaxHp);
    }

    runState.killCount++;
    StorageService.I.addKills(1);
    StorageService.I.addDailyQuestProgress('defeat_enemies', 1);
    if (enemy.type == EnemyType.virusBall) {
      StorageService.I.addInfectedKills(1);
      StorageService.I.addDailyQuestProgress('defeat_infected', 1);
    }

    _gainXp(3.0 + enemy.tier * 0.6);
    runState.pushHudUpdate();
  }

  void _spawnSplitterChildren(Vector2 origin) {
    final def = kEnemyDefs[EnemyType.swarmer]!;
    for (int i = 0; i < 2; i++) {
      final angle = rng.nextDouble() * pi * 2;
      final pos = origin + Vector2(cos(angle), sin(angle)) * 40;
      addEnemy(
        type: EnemyType.swarmer,
        tier: level.tier,
        position: pos,
        hp: def.baseHp * level.enemyHpMult,
        damage: def.baseDamage * level.enemyDamageMult,
        speed: def.baseSpeed * level.enemySpeedMult,
      );
    }
  }

  void onKamikazeExplode(EnemyEntity enemy) {
    world.add(FxBurst(
      position: enemy.position.clone(),
      spriteIndex: rng.nextInt(30),
      maxRadius: 110,
      duration: 0.6,
      color: const Color(0xFFFF3D5A),
    ));
    audio.sfx(Sounds.plasmaExplosion);
    const blastRadius = 130.0;
    for (final sat in List.of(orbitManager.satellites)) {
      if ((sat.position - enemy.position).length < blastRadius) {
        sat.takeDamage(enemy.damage * 2.2);
      }
    }
    if (orbitManager.satellites.isEmpty &&
        (player.position - enemy.position).length < blastRadius) {
      onCoreDamaged(enemy.damage * 1.6);
    }
    enemy.hp = 0;
    onEnemyKilled(enemy);
  }

  void onSatelliteDestroyed(Satellite sat) {
    final pos = sat.position.clone();
    final wasExplosive = runState.satelliteExplode;
    orbitManager.removeSatellite(sat);
    audio.sfx(Sounds.sphereBreakingApart, volume: 0.6);
    world.add(FxBurst(
        position: pos,
        spriteIndex: rng.nextInt(30),
        maxRadius: 50,
        color: const Color(0xFF8FA3D1)));
    if (wasExplosive) {
      world.add(FxBurst(
          position: pos,
          spriteIndex: rng.nextInt(30),
          maxRadius: 100,
          duration: 0.5,
          color: const Color(0xFFFF9A3D)));
      const blast = 110.0;
      for (final e in List.of(enemies)) {
        if ((e.position - pos).length < blast) {
          e.takeDamage(18 * runState.damageMult);
        }
      }
    }
  }

  void onVirusInfect(Satellite sat) {
    if (sat.infected) return;
    sat.infected = true;
    sat.infectionTimer = 4.5;
    audio.sfx(Sounds.satelliteInfection);
  }

  void onSatelliteInfectionComplete(Satellite sat) {
    final pos = sat.position.clone();
    orbitManager.removeSatellite(sat);
    audio.sfx(Sounds.satelliteTurnsHostile);
    final def = kEnemyDefs[EnemyType.virusBall]!;
    addEnemy(
      type: EnemyType.virusBall,
      tier: level.tier,
      position: pos,
      hp: def.baseHp * level.enemyHpMult * 0.7,
      damage: def.baseDamage * level.enemyDamageMult,
      speed: def.baseSpeed * level.enemySpeedMult,
    );
  }

  void onMagnetPulse(Vector2 origin) {
    audio.sfx(Sounds.electromagneticPulse);
    world.add(FxBurst(
        position: origin.clone(),
        spriteIndex: rng.nextInt(30),
        maxRadius: 150,
        duration: 0.5,
        color: const Color(0xFF52FF7A)));
    for (final sat in orbitManager.satellites) {
      sat.angleOffset += (rng.nextDouble() - 0.5) * 1.4;
    }
  }

  void onCoreDamaged(double amount) {
    if (player.invulnTimer > 0) return;
    runState.coreHp -= amount.round();
    audio.sfx(Sounds.energyImpact, volume: 0.5);
    player.invulnTimer = 0.35;
    _shakeMag = 11.0;

    // Retaliation Field: burst nearby attackers when the core is struck.
    if (runState.thornsMult > 0) {
      const retaliationRadius = 180.0;
      final thornDamage = 26.0 * runState.thornsMult * runState.damageMult;
      for (final e in List.of(enemies)) {
        if ((e.position - player.position).length < retaliationRadius) {
          e.takeDamage(thornDamage);
        }
      }
      world.add(FxBurst(
          position: player.position.clone(),
          spriteIndex: rng.nextInt(30),
          maxRadius: retaliationRadius,
          duration: 0.4,
          color: const Color(0xFFFFD84D)));
    }

    runState.pushHudUpdate();
    if (runState.coreHp <= 0) {
      runState.coreHp = 0;
      _endRun(victory: false);
    }
  }

  void onCollectCrystal(int value) {
    runState.crystalsThisRun += value;
    audio.sfx(Sounds.collectiblePickup, volume: 0.5);
    runState.pushHudUpdate();
  }

  void _gainXp(double amount) {
    runState.xp += amount * runState.xpMult;
    // Steeper curve so level-ups feel like real milestones rather than a
    // pop-up every few seconds.
    if (runState.xp >= runState.xpToNext) {
      runState.xp -= runState.xpToNext;
      runState.runLevel++;
      runState.xpToNext *= 1.35;
      audio.sfx(Sounds.levelUp);
      _triggerUpgradeChoice();
    }
  }

  void _triggerUpgradeChoice() {
    pauseEngine();
    callbacks.onUpgradeChoice(pickUpgradeChoices(rng, 3));
  }

  void applyChosenUpgrade(int upgradeIndex) {
    final upgrade = kAllUpgrades[upgradeIndex % kAllUpgrades.length];
    runState.applyUpgrade(upgrade.apply);
    audio.sfx(Sounds.rewardUpgrade);
    StorageService.I.addUsedUpgrade(upgrade.id);
    StorageService.I.addDailyQuestProgress('use_upgrades', 1);
    resumeEngine();
  }

  // --- Boss handling -----------------------------------------------------

  void spawnMiniBoss({required bool isFinal}) {
    runState.bossActive = true;
    audio.sfx(Sounds.bossArrival);
    final type = level.areaBoss;
    final def = kMiniBossDefs[type]!;
    final hpMult = isFinal ? level.bossHpMult : level.bossHpMult * 0.55;
    final angle = rng.nextDouble() * pi * 2;
    final pos = player.position + Vector2(cos(angle), sin(angle)) * spawnRingRadius() * 0.7;
    currentBoss = BossEntity(
      position: pos,
      type: type,
      hp: def.baseHp * hpMult,
      damage: def.baseDamage * level.bossDamageMult,
      isFinalBoss: isFinal,
    );
    world.add(currentBoss!);
  }

  void onBossKilled(BossEntity boss) {
    world.add(FxBurst(
      position: boss.position.clone(),
      spriteIndex: rng.nextInt(30),
      maxRadius: 180,
      duration: 0.9,
      color: boss.def.tint,
    ));
    boss.removeFromParent();
    currentBoss = null;
    runState.bossActive = false;
    audio.sfx(Sounds.winVictoryBoss);
    StorageService.I.addBossKill();
    StorageService.I.addDailyQuestProgress('defeat_miniboss', 1);
    if (boss.isFinalBoss) {
      StorageService.I.addDailyQuestProgress('defeat_final_boss', 1);
    }
    world.add(CrystalDrop(position: boss.position.clone(), value: 50));
    waveManager.onMiniBossCleared();
  }

  void onBossSpawnMinion(Vector2 origin) {
    final angle = rng.nextDouble() * pi * 2;
    final pos = origin + Vector2(cos(angle), sin(angle)) * 90;
    final def = kEnemyDefs[EnemyType.virusBall]!;
    addEnemy(
      type: EnemyType.virusBall,
      tier: level.tier,
      position: pos,
      hp: def.baseHp * level.enemyHpMult * 0.6,
      damage: def.baseDamage * level.enemyDamageMult,
      speed: def.baseSpeed * level.enemySpeedMult,
    );
  }

  void onBossShockwave(Vector2 origin, double damage) {
    audio.sfx(Sounds.electromagneticPulse);
    world.add(FxBurst(
        position: origin.clone(),
        spriteIndex: rng.nextInt(30),
        maxRadius: 220,
        duration: 0.6,
        color: const Color(0xFFFFD84D)));
    for (final sat in List.of(orbitManager.satellites)) {
      if ((sat.position - origin).length < 260) {
        sat.takeDamage(damage);
      }
    }
  }

  void onBossDisableSatellites(int count, double duration) {
    final list = List.of(orbitManager.satellites)..shuffle(rng);
    for (final sat in list.take(count)) {
      sat.disabledTimer = duration;
    }
  }

  void onBossRadiusDistort() {
    radiusDistortTimer = 6.0;
  }

  // --- Events --------------------------------------------------------

  void onEventStarted(GameEventDef def) {
    audio.sfx(def.soundAsset, volume: 0.7);
    callbacks.onEventBanner(def);
  }

  void spawnCrystalRain() {
    audio.sfx(Sounds.crystalRain);
    for (int i = 0; i < 16; i++) {
      _spawnSphereNear(player.position, minR: 60, maxR: spawnRingRadius() * 0.9);
    }
  }

  void onBlackHoleSurvived() {
    StorageService.I.addBlackHoleSurvived();
    StorageService.I.addDailyQuestProgress('survive_blackhole', 1);
  }

  // --- Run completion --------------------------------------------------

  void onLevelVictory() {
    _endRun(victory: true);
  }

  void _endRun({required bool victory}) {
    runState.gameOver = !victory;
    runState.victory = victory;
    pauseEngine();
    audio.stopMusic();
    final baseReward =
        victory ? level.crystalReward : (level.crystalReward ~/ 3);
    final magnet = 1 + 0.12 * StorageService.I.labLevel('magnet');
    final earned = ((runState.crystalsThisRun + baseReward) * magnet).round();
    StorageService.I.addCrystals(earned);
    StorageService.I.reportWave(runState.wave);
    if (victory) {
      StorageService.I.unlockLevel(level.level + 1);
      StorageService.I.incRunsCompleted();
      StorageService.I.addDailyQuestProgress('finish_runs', 1);
      if (runState.coreHp == runState.coreMaxHp) {
        StorageService.I.addDailyQuestProgress('no_damage_run', 1);
      }
      callbacks.onVictory();
    } else {
      callbacks.onGameOver();
    }
  }
}
