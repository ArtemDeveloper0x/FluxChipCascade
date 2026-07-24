import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// The enemy archetypes. The first six are from the design document; the
/// swarmer and splitter add extra on-screen chaos and dynamics.
enum EnemyType {
  hunter,
  destroyer,
  sniper,
  magnet,
  kamikaze,
  virusBall,
  swarmer,
  splitter,
}

class EnemyDef {
  final EnemyType type;
  final String name;
  final int spriteRow; // row within enemies sprite sheet (0,1,2)
  final Color tint;
  final double baseHp;
  final double baseSpeed;
  final double baseDamage;
  final double baseRadius;
  final int crystalDrop;

  const EnemyDef({
    required this.type,
    required this.name,
    required this.spriteRow,
    required this.tint,
    required this.baseHp,
    required this.baseSpeed,
    required this.baseDamage,
    required this.baseRadius,
    required this.crystalDrop,
  });
}

const Map<EnemyType, EnemyDef> kEnemyDefs = {
  EnemyType.hunter: EnemyDef(
    type: EnemyType.hunter,
    name: 'Hunter',
    spriteRow: 0,
    tint: AppColors.cyan,
    baseHp: 14,
    baseSpeed: 78,
    baseDamage: 6,
    baseRadius: 20,
    crystalDrop: 1,
  ),
  EnemyType.destroyer: EnemyDef(
    type: EnemyType.destroyer,
    name: 'Destroyer',
    spriteRow: 1,
    tint: AppColors.orange,
    baseHp: 60,
    baseSpeed: 34,
    baseDamage: 22,
    baseRadius: 30,
    crystalDrop: 3,
  ),
  EnemyType.sniper: EnemyDef(
    type: EnemyType.sniper,
    name: 'Sniper',
    spriteRow: 2,
    tint: AppColors.purple,
    baseHp: 18,
    baseSpeed: 42,
    baseDamage: 9,
    baseRadius: 22,
    crystalDrop: 2,
  ),
  EnemyType.magnet: EnemyDef(
    type: EnemyType.magnet,
    name: 'Magnet',
    spriteRow: 1,
    tint: AppColors.green,
    baseHp: 30,
    baseSpeed: 46,
    baseDamage: 4,
    baseRadius: 26,
    crystalDrop: 2,
  ),
  EnemyType.kamikaze: EnemyDef(
    type: EnemyType.kamikaze,
    name: 'Kamikaze',
    spriteRow: 0,
    tint: AppColors.red,
    baseHp: 10,
    baseSpeed: 118,
    baseDamage: 26,
    baseRadius: 18,
    crystalDrop: 2,
  ),
  EnemyType.virusBall: EnemyDef(
    type: EnemyType.virusBall,
    name: 'Virus Ball',
    spriteRow: 2,
    tint: AppColors.magenta,
    baseHp: 22,
    baseSpeed: 52,
    baseDamage: 5,
    baseRadius: 22,
    crystalDrop: 2,
  ),
  EnemyType.swarmer: EnemyDef(
    type: EnemyType.swarmer,
    name: 'Swarmer',
    spriteRow: 0,
    tint: AppColors.green,
    baseHp: 7,
    baseSpeed: 132,
    baseDamage: 3,
    baseRadius: 15,
    crystalDrop: 1,
  ),
  EnemyType.splitter: EnemyDef(
    type: EnemyType.splitter,
    name: 'Splitter',
    spriteRow: 1,
    tint: AppColors.blue,
    baseHp: 46,
    baseSpeed: 40,
    baseDamage: 12,
    baseRadius: 27,
    crystalDrop: 3,
  ),
};

/// The five mini-bosses. Hand-picked source rects inside mini_bosses_asset.webp
/// (original sheet is 1584x672).
enum MiniBossType { hiveCore, orbitBreaker, prismTitan, magneticEye, crystalColossus }

class MiniBossDef {
  final MiniBossType type;
  final String name;
  final Rect srcRect;
  final Color tint;
  final double baseHp;
  final double baseDamage;
  final String ability;

  const MiniBossDef({
    required this.type,
    required this.name,
    required this.srcRect,
    required this.tint,
    required this.baseHp,
    required this.baseDamage,
    required this.ability,
  });
}

const Map<MiniBossType, MiniBossDef> kMiniBossDefs = {
  MiniBossType.hiveCore: MiniBossDef(
    type: MiniBossType.hiveCore,
    name: 'Hive Core',
    srcRect: Rect.fromLTWH(0, 0, 450, 420),
    tint: AppColors.purple,
    baseHp: 420,
    baseDamage: 12,
    ability: 'Continuously spawns virus spheres',
  ),
  MiniBossType.orbitBreaker: MiniBossDef(
    type: MiniBossType.orbitBreaker,
    name: 'Orbit Breaker',
    srcRect: Rect.fromLTWH(560, 0, 440, 400),
    tint: AppColors.gold,
    baseHp: 520,
    baseDamage: 18,
    ability: 'Emits shockwaves that shatter satellites',
  ),
  MiniBossType.prismTitan: MiniBossDef(
    type: MiniBossType.prismTitan,
    name: 'Prism Titan',
    srcRect: Rect.fromLTWH(1170, 0, 414, 400),
    tint: AppColors.blue,
    baseHp: 480,
    baseDamage: 14,
    ability: 'Temporarily disables part of the orbit',
  ),
  MiniBossType.magneticEye: MiniBossDef(
    type: MiniBossType.magneticEye,
    name: 'Magnetic Eye',
    srcRect: Rect.fromLTWH(300, 270, 420, 350),
    tint: AppColors.green,
    baseHp: 460,
    baseDamage: 10,
    ability: 'Distorts the orbit radius continuously',
  ),
  MiniBossType.crystalColossus: MiniBossDef(
    type: MiniBossType.crystalColossus,
    name: 'Crystal Colossus',
    srcRect: Rect.fromLTWH(860, 260, 420, 410),
    tint: AppColors.cyan,
    baseHp: 900,
    baseDamage: 20,
    ability: 'Surrounded by several layers of shields',
  ),
};
