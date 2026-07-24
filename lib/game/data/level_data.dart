import 'enemy_data.dart';

class LocationInfo {
  final String name;
  final String description;

  const LocationInfo(this.name, this.description);
}

const List<LocationInfo> kLocations = [
  LocationInfo('Crystal Garden', 'Calm starting area, abundant with spheres.'),
  LocationInfo('Neon Factory', 'Industrial complex with shifting routes.'),
  LocationInfo('Prism Caves', 'Crystalline caverns full of reflections.'),
  LocationInfo('Void Sector', 'Dark zone with scarce resources.'),
  LocationInfo('Core Reactor', 'The final, most hostile region.'),
];

/// Full configuration for a single level (there are 40, easy -> hard).
class LevelConfig {
  final int level; // 1-based
  final int tier; // 0..9, groups of 4 levels
  final int locationIndex; // 0..4
  final int waveCount;
  final double enemyHpMult;
  final double enemyDamageMult;
  final double enemySpeedMult;
  final double spawnInterval;
  final int maxConcurrentEnemies;
  final int enemiesPerWave;
  final MiniBossType areaBoss;
  final double bossHpMult;
  final double bossDamageMult;
  final bool isLocationFinale; // last level of a location (level % 8 == 0)
  final int crystalReward;

  const LevelConfig({
    required this.level,
    required this.tier,
    required this.locationIndex,
    required this.waveCount,
    required this.enemyHpMult,
    required this.enemyDamageMult,
    required this.enemySpeedMult,
    required this.spawnInterval,
    required this.maxConcurrentEnemies,
    required this.enemiesPerWave,
    required this.areaBoss,
    required this.bossHpMult,
    required this.bossDamageMult,
    required this.isLocationFinale,
    required this.crystalReward,
  });

  LocationInfo get location => kLocations[locationIndex];
  int get bgIndex => tier;
}

const List<MiniBossType> _bossRotation = [
  MiniBossType.hiveCore,
  MiniBossType.orbitBreaker,
  MiniBossType.prismTitan,
  MiniBossType.magneticEye,
  MiniBossType.crystalColossus,
];

List<LevelConfig> _generate() {
  final list = <LevelConfig>[];
  for (int level = 1; level <= 40; level++) {
    final tier = (level - 1) ~/ 4; // 0..9
    final locationIndex = (level - 1) ~/ 8; // 0..4
    final progress = (level - 1) / 39.0; // 0..1 overall difficulty curve

    final waveCount = 3 + (level ~/ 4); // 3 .. ~13, slightly shorter runs
    // Gentle difficulty curve so runs are comfortably winnable, paired with the
    // player's Pulse Cannon and sturdier orbit.
    final enemyHpMult = 1.0 + progress * 1.8;
    final enemyDamageMult = 1.0 + progress * 1.1;
    final enemySpeedMult = 1.0 + progress * 0.45;
    final spawnInterval = (2.2 - progress * 1.7).clamp(0.35, 2.2);
    // Plenty of total enemies per wave for dynamics, but the on-screen count is
    // capped so we never overload the device (each entity draws a blur glow).
    final maxConcurrent = (12 + (level * 0.7)).round().clamp(12, 26);
    final enemiesPerWave = (6 + (level * 1.0)).round();
    final isFinale = level % 8 == 0;
    final areaBoss = _bossRotation[locationIndex % _bossRotation.length];
    final bossHpMult = (1.0 + progress * 2.2) * (isFinale ? 1.4 : 1.0);
    final bossDamageMult = 1.0 + progress * 1.2;
    // Much more generous crystal payouts so upgrades/mutations are easy to earn.
    final crystalReward = 60 + level * 14 + (isFinale ? 150 : 0);

    list.add(LevelConfig(
      level: level,
      tier: tier,
      locationIndex: locationIndex,
      waveCount: waveCount,
      enemyHpMult: enemyHpMult,
      enemyDamageMult: enemyDamageMult,
      enemySpeedMult: enemySpeedMult,
      spawnInterval: spawnInterval,
      maxConcurrentEnemies: maxConcurrent,
      enemiesPerWave: enemiesPerWave,
      areaBoss: areaBoss,
      bossHpMult: bossHpMult,
      bossDamageMult: bossDamageMult,
      isLocationFinale: isFinale,
      crystalReward: crystalReward,
    ));
  }
  return list;
}

final List<LevelConfig> kLevels = _generate();

LevelConfig levelConfigFor(int level) =>
    kLevels[(level - 1).clamp(0, kLevels.length - 1)];
