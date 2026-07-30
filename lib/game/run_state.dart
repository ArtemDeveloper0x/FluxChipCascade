import 'package:flutter/foundation.dart';
import 'data/level_data.dart';
import 'data/mutation_data.dart';

/// Mutable per-run modifiers. Mutations & upgrades write into this object;
/// gameplay components read from it every frame.
class RunState extends ChangeNotifier {
  final LevelConfig level;
  final String mutationId;

  RunState({required this.level, required this.mutationId});

  // multiplicative modifiers
  double orbitSpeedMult = 1.0;
  double orbitRadiusMult = 1.0;
  double damageMult = 1.0;
  double satelliteHpMult = 1.0;
  double moveSpeedMult = 1.0;
  double coreHpMult = 1.0;
  double attractRadiusMult = 1.0;
  double sphereSpawnMult = 1.0;
  double critChance = 0.05;
  double critDamageMult = 1.7;
  double slowFieldStrength = 0.0;
  int extraLayers = 0;
  int startingSatellitesDelta = 0;

  bool electricDischarge = false;
  bool satelliteExplode = false;
  bool satelliteRegen = false;
  bool reflectProjectiles = false;
  bool energyWave = false;
  bool cometTrail = false;
  bool bonusCrystalDrop = false;

  // New build-defining modifiers (added in the "meaning & depth" pass).
  double lifestealChance = 0.0; // chance a kill restores core HP
  double xpMult = 1.0; // faster leveling → more upgrade choices
  double pickupHealAmount = 0.0; // core HP restored per sphere collected
  double thornsMult = 0.0; // fraction of core damage reflected to nearby foes
  bool chainLightning = false; // cannon hits arc to a second enemy

  // Core Pulse Cannon: a baseline auto-attack that fires at the nearest
  // hostile, so the player always has a way to deal ranged damage.
  bool cannonEnabled = true;
  double cannonDamageMult = 1.0;
  double cannonFireRateMult = 1.0;
  int cannonExtraShots = 0;
  bool cannonHoming = false; // bolts steer toward the nearest target
  int cannonPierce = 0; // bolts pass through this many enemies

  // live run stats (surfaced to HUD)
  int coreHp = 100;
  int coreMaxHp = 100;
  int satelliteCount = 0;
  int crystalsThisRun = 0;
  int wave = 1;
  int killCount = 0;
  int runLevel = 1; // player level within the run (from XP)
  double xp = 0;
  double xpToNext = 26;
  double elapsedSeconds = 0;
  bool bossActive = false;
  String? activeEventName;
  bool gameOver = false;
  bool victory = false;

  // event-driven temporary modifiers (reset by EventManager)
  double eventSpeedMult = 1.0;
  double eventDamageMult = 1.0;
  double eventVirusWeightMult = 1.0;
  bool blackHoleActive = false;

  void applyStartingMutation() {
    final def = kAllMutations.firstWhere((m) => m.id == mutationId,
        orElse: () => kAllMutations.first);
    def.apply(this);
  }

  void applyUpgrade(void Function(RunState) apply) {
    apply(this);
    notifyListeners();
  }

  void pushHudUpdate() => notifyListeners();
}
