import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../run_state.dart';

enum UpgradeCategory { attack, defense, mobility, utility }

/// Rarity drives both the visual treatment on the level-up screen and how
/// often an upgrade shows up. Legendary picks are build-defining and rare.
enum UpgradeRarity { common, rare, epic, legendary }

extension UpgradeRarityInfo on UpgradeRarity {
  String get label {
    switch (this) {
      case UpgradeRarity.common:
        return 'COMMON';
      case UpgradeRarity.rare:
        return 'RARE';
      case UpgradeRarity.epic:
        return 'EPIC';
      case UpgradeRarity.legendary:
        return 'LEGENDARY';
    }
  }

  Color get color {
    switch (this) {
      case UpgradeRarity.common:
        return AppColors.textSecondary;
      case UpgradeRarity.rare:
        return AppColors.cyan;
      case UpgradeRarity.epic:
        return AppColors.purple;
      case UpgradeRarity.legendary:
        return AppColors.gold;
    }
  }

  /// Relative draw weight. Rarer upgrades appear far less frequently.
  int get weight {
    switch (this) {
      case UpgradeRarity.common:
        return 100;
      case UpgradeRarity.rare:
        return 46;
      case UpgradeRarity.epic:
        return 20;
      case UpgradeRarity.legendary:
        return 7;
    }
  }
}

class UpgradeDef {
  final String id;
  final String name;
  final String description;
  final UpgradeCategory category;
  final UpgradeRarity rarity;
  final int iconIndex; // index into Special_Orbit_Upgrades sheet (0..7)
  final void Function(RunState state) apply;

  const UpgradeDef({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.rarity,
    required this.iconIndex,
    required this.apply,
  });
}

final List<UpgradeDef> kAllUpgrades = [
  // ── Common: reliable stat bumps ─────────────────────────────────────────
  UpgradeDef(
    id: 'orbit_speed',
    name: 'Rotation Surge',
    description: 'Orbit rotation speed +18%. Satellites sweep enemies faster.',
    category: UpgradeCategory.attack,
    rarity: UpgradeRarity.common,
    iconIndex: 0,
    apply: (s) => s.orbitSpeedMult *= 1.18,
  ),
  UpgradeDef(
    id: 'orbit_radius',
    name: 'Expanded Orbit',
    description: 'Orbit radius +12%. Reach and sweep a wider area.',
    category: UpgradeCategory.mobility,
    rarity: UpgradeRarity.common,
    iconIndex: 6,
    apply: (s) => s.orbitRadiusMult *= 1.12,
  ),
  UpgradeDef(
    id: 'contact_damage',
    name: 'Overcharged Contact',
    description: 'Satellite & weapon damage +20%.',
    category: UpgradeCategory.attack,
    rarity: UpgradeRarity.common,
    iconIndex: 1,
    apply: (s) => s.damageMult *= 1.2,
  ),
  UpgradeDef(
    id: 'move_speed',
    name: 'Ion Thrusters',
    description: 'Movement speed +15%. Kite the swarm with ease.',
    category: UpgradeCategory.mobility,
    rarity: UpgradeRarity.common,
    iconIndex: 2,
    apply: (s) => s.moveSpeedMult *= 1.15,
  ),
  UpgradeDef(
    id: 'satellite_hp',
    name: 'Reinforced Plating',
    description: 'Satellite durability +25%. Orbit lasts far longer.',
    category: UpgradeCategory.defense,
    rarity: UpgradeRarity.common,
    iconIndex: 3,
    apply: (s) => s.satelliteHpMult *= 1.25,
  ),
  UpgradeDef(
    id: 'more_spheres',
    name: 'Resource Bloom',
    description: 'More energy spheres spawn — grow your orbit faster.',
    category: UpgradeCategory.utility,
    rarity: UpgradeRarity.common,
    iconIndex: 7,
    apply: (s) => s.sphereSpawnMult *= 1.3,
  ),
  UpgradeDef(
    id: 'cannon_damage',
    name: 'Pulse Overcharge',
    description: 'Core Pulse Cannon damage +30%.',
    category: UpgradeCategory.attack,
    rarity: UpgradeRarity.common,
    iconIndex: 0,
    apply: (s) => s.cannonDamageMult *= 1.3,
  ),

  // ── Rare: meaningful behaviour changes ──────────────────────────────────
  UpgradeDef(
    id: 'extra_layer',
    name: 'New Satellite Layer',
    description: 'Unlocks an additional orbital ring — hold many more satellites.',
    category: UpgradeCategory.defense,
    rarity: UpgradeRarity.rare,
    iconIndex: 5,
    apply: (s) => s.extraLayers += 1,
  ),
  UpgradeDef(
    id: 'auto_attract',
    name: 'Magnetic Pull',
    description: 'Energy spheres are pulled in from much farther away.',
    category: UpgradeCategory.utility,
    rarity: UpgradeRarity.rare,
    iconIndex: 7,
    apply: (s) => s.attractRadiusMult *= 1.6,
  ),
  UpgradeDef(
    id: 'crit',
    name: 'Critical Flux',
    description: 'Critical hit chance +8%. Crits deal massive bonus damage.',
    category: UpgradeCategory.attack,
    rarity: UpgradeRarity.rare,
    iconIndex: 1,
    apply: (s) => s.critChance += 0.08,
  ),
  UpgradeDef(
    id: 'cannon_rate',
    name: 'Rapid Coils',
    description: 'Core Pulse Cannon fires 25% faster.',
    category: UpgradeCategory.attack,
    rarity: UpgradeRarity.rare,
    iconIndex: 1,
    apply: (s) => s.cannonFireRateMult *= 1.25,
  ),
  UpgradeDef(
    id: 'slow_field',
    name: 'Temporal Field',
    description: 'Nearby enemies are slowed — control the crowd.',
    category: UpgradeCategory.utility,
    rarity: UpgradeRarity.rare,
    iconIndex: 4,
    apply: (s) => s.slowFieldStrength += 0.1,
  ),
  UpgradeDef(
    id: 'xp_gain',
    name: 'Neural Uplink',
    description: 'Gain +30% XP — level up and pick upgrades more often.',
    category: UpgradeCategory.utility,
    rarity: UpgradeRarity.rare,
    iconIndex: 7,
    apply: (s) => s.xpMult *= 1.3,
  ),
  UpgradeDef(
    id: 'pickup_heal',
    name: 'Restorative Intake',
    description: 'Collecting a sphere restores a bit of core HP.',
    category: UpgradeCategory.defense,
    rarity: UpgradeRarity.rare,
    iconIndex: 3,
    apply: (s) => s.pickupHealAmount += 2,
  ),

  // ── Epic: strong active systems ─────────────────────────────────────────
  UpgradeDef(
    id: 'electric_discharge',
    name: 'Electric Discharge',
    description: 'Satellites periodically arc lightning to nearby enemies.',
    category: UpgradeCategory.attack,
    rarity: UpgradeRarity.epic,
    iconIndex: 0,
    apply: (s) => s.electricDischarge = true,
  ),
  UpgradeDef(
    id: 'death_explosion',
    name: 'Volatile Core',
    description: 'Destroyed satellites detonate, damaging surrounding enemies.',
    category: UpgradeCategory.attack,
    rarity: UpgradeRarity.epic,
    iconIndex: 1,
    apply: (s) => s.satelliteExplode = true,
  ),
  UpgradeDef(
    id: 'reflect',
    name: 'Reflective Shell',
    description: 'Satellites reflect enemy projectiles back at their source.',
    category: UpgradeCategory.defense,
    rarity: UpgradeRarity.epic,
    iconIndex: 6,
    apply: (s) => s.reflectProjectiles = true,
  ),
  UpgradeDef(
    id: 'energy_wave',
    name: 'Energy Wave',
    description: 'Periodically emit a shockwave that damages everything close.',
    category: UpgradeCategory.attack,
    rarity: UpgradeRarity.epic,
    iconIndex: 4,
    apply: (s) => s.energyWave = true,
  ),
  UpgradeDef(
    id: 'cannon_split',
    name: 'Split Barrel',
    description: 'Core Pulse Cannon fires an extra bolt in a spread.',
    category: UpgradeCategory.attack,
    rarity: UpgradeRarity.epic,
    iconIndex: 4,
    apply: (s) => s.cannonExtraShots += 1,
  ),
  UpgradeDef(
    id: 'thorns',
    name: 'Retaliation Field',
    description: 'When the core is hit, nearby attackers take burst damage.',
    category: UpgradeCategory.defense,
    rarity: UpgradeRarity.epic,
    iconIndex: 6,
    apply: (s) => s.thornsMult += 0.9,
  ),

  // ── Legendary: build-defining ───────────────────────────────────────────
  UpgradeDef(
    id: 'lifesteal',
    name: 'Vampiric Circuit',
    description: 'Defeated enemies have a chance to restore core HP.',
    category: UpgradeCategory.defense,
    rarity: UpgradeRarity.legendary,
    iconIndex: 3,
    apply: (s) => s.lifestealChance += 0.22,
  ),
  UpgradeDef(
    id: 'chain_lightning',
    name: 'Chain Conductor',
    description: 'Cannon bolts arc to a second nearby enemy on impact.',
    category: UpgradeCategory.attack,
    rarity: UpgradeRarity.legendary,
    iconIndex: 0,
    apply: (s) => s.chainLightning = true,
  ),
  UpgradeDef(
    id: 'homing_bolts',
    name: 'Seeker Rounds',
    description: 'Cannon bolts curve to chase down their targets.',
    category: UpgradeCategory.attack,
    rarity: UpgradeRarity.legendary,
    iconIndex: 1,
    apply: (s) => s.cannonHoming = true,
  ),
  UpgradeDef(
    id: 'piercing_bolts',
    name: 'Rail Penetrator',
    description: 'Cannon bolts punch through two extra enemies each.',
    category: UpgradeCategory.attack,
    rarity: UpgradeRarity.legendary,
    iconIndex: 4,
    apply: (s) => s.cannonPierce += 2,
  ),
];

/// Weighted, no-duplicate pick of [count] upgrade indices for the level-up
/// screen. Rarer upgrades surface less often, so a legendary feels special.
List<int> pickUpgradeChoices(Random rng, int count) {
  final remaining = List<int>.generate(kAllUpgrades.length, (i) => i);
  final chosen = <int>[];
  while (chosen.length < count && remaining.isNotEmpty) {
    final totalWeight =
        remaining.fold<int>(0, (sum, i) => sum + kAllUpgrades[i].rarity.weight);
    var roll = rng.nextInt(totalWeight);
    int picked = remaining.first;
    for (final i in remaining) {
      roll -= kAllUpgrades[i].rarity.weight;
      if (roll < 0) {
        picked = i;
        break;
      }
    }
    chosen.add(picked);
    remaining.remove(picked);
  }
  return chosen;
}
