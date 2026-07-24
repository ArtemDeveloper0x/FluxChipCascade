import '../run_state.dart';

enum UpgradeCategory { attack, defense, mobility, utility }

class UpgradeDef {
  final String id;
  final String name;
  final String description;
  final UpgradeCategory category;
  final int iconIndex; // index into Special_Orbit_Upgrades sheet (0..7)
  final void Function(RunState state) apply;

  const UpgradeDef({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.iconIndex,
    required this.apply,
  });
}

final List<UpgradeDef> kAllUpgrades = [
  UpgradeDef(
    id: 'orbit_speed',
    name: 'Rotation Surge',
    description: 'Increases orbit rotation speed by 18%.',
    category: UpgradeCategory.attack,
    iconIndex: 0,
    apply: (s) => s.orbitSpeedMult *= 1.18,
  ),
  UpgradeDef(
    id: 'orbit_radius',
    name: 'Expanded Orbit',
    description: 'Increases orbit radius by 12%.',
    category: UpgradeCategory.mobility,
    iconIndex: 6,
    apply: (s) => s.orbitRadiusMult *= 1.12,
  ),
  UpgradeDef(
    id: 'extra_layer',
    name: 'New Satellite Layer',
    description: 'Unlocks an additional orbital ring.',
    category: UpgradeCategory.defense,
    iconIndex: 5,
    apply: (s) => s.extraLayers += 1,
  ),
  UpgradeDef(
    id: 'contact_damage',
    name: 'Overcharged Contact',
    description: 'Satellite contact damage +20%.',
    category: UpgradeCategory.attack,
    iconIndex: 1,
    apply: (s) => s.damageMult *= 1.2,
  ),
  UpgradeDef(
    id: 'electric_discharge',
    name: 'Electric Discharge',
    description: 'Satellites periodically arc electricity to enemies.',
    category: UpgradeCategory.attack,
    iconIndex: 0,
    apply: (s) => s.electricDischarge = true,
  ),
  UpgradeDef(
    id: 'death_explosion',
    name: 'Volatile Core',
    description: 'Destroyed satellites explode, damaging nearby enemies.',
    category: UpgradeCategory.attack,
    iconIndex: 1,
    apply: (s) => s.satelliteExplode = true,
  ),
  UpgradeDef(
    id: 'satellite_regen',
    name: 'Slow Regeneration',
    description: 'Lost satellites slowly regenerate over time.',
    category: UpgradeCategory.defense,
    iconIndex: 3,
    apply: (s) => s.satelliteRegen = true,
  ),
  UpgradeDef(
    id: 'auto_attract',
    name: 'Magnetic Pull',
    description: 'Neutral spheres are pulled from farther away.',
    category: UpgradeCategory.utility,
    iconIndex: 7,
    apply: (s) => s.attractRadiusMult *= 1.6,
  ),
  UpgradeDef(
    id: 'reflect',
    name: 'Reflective Shell',
    description: 'Satellites can reflect enemy projectiles.',
    category: UpgradeCategory.defense,
    iconIndex: 6,
    apply: (s) => s.reflectProjectiles = true,
  ),
  UpgradeDef(
    id: 'move_speed',
    name: 'Ion Thrusters',
    description: 'Movement speed +15%.',
    category: UpgradeCategory.mobility,
    iconIndex: 2,
    apply: (s) => s.moveSpeedMult *= 1.15,
  ),
  UpgradeDef(
    id: 'slow_field',
    name: 'Temporal Field',
    description: 'Nearby enemies are slightly slowed.',
    category: UpgradeCategory.utility,
    iconIndex: 4,
    apply: (s) => s.slowFieldStrength += 0.08,
  ),
  UpgradeDef(
    id: 'satellite_hp',
    name: 'Reinforced Plating',
    description: 'Satellite durability +25%.',
    category: UpgradeCategory.defense,
    iconIndex: 3,
    apply: (s) => s.satelliteHpMult *= 1.25,
  ),
  UpgradeDef(
    id: 'crit',
    name: 'Critical Flux',
    description: 'Increases critical hit chance and damage.',
    category: UpgradeCategory.attack,
    iconIndex: 1,
    apply: (s) => s.critChance += 0.08,
  ),
  UpgradeDef(
    id: 'energy_wave',
    name: 'Energy Wave',
    description: 'Periodically emits a damaging pulse wave.',
    category: UpgradeCategory.attack,
    iconIndex: 4,
    apply: (s) => s.energyWave = true,
  ),
  UpgradeDef(
    id: 'more_spheres',
    name: 'Resource Bloom',
    description: 'More neutral spheres appear on the map.',
    category: UpgradeCategory.utility,
    iconIndex: 7,
    apply: (s) => s.sphereSpawnMult *= 1.3,
  ),
  UpgradeDef(
    id: 'cannon_damage',
    name: 'Pulse Overcharge',
    description: 'Core Pulse Cannon damage +30%.',
    category: UpgradeCategory.attack,
    iconIndex: 0,
    apply: (s) => s.cannonDamageMult *= 1.3,
  ),
  UpgradeDef(
    id: 'cannon_rate',
    name: 'Rapid Coils',
    description: 'Core Pulse Cannon fires 25% faster.',
    category: UpgradeCategory.attack,
    iconIndex: 1,
    apply: (s) => s.cannonFireRateMult *= 1.25,
  ),
  UpgradeDef(
    id: 'cannon_split',
    name: 'Split Barrel',
    description: 'Core Pulse Cannon fires an extra bolt per shot.',
    category: UpgradeCategory.attack,
    iconIndex: 4,
    apply: (s) => s.cannonExtraShots += 1,
  ),
];
