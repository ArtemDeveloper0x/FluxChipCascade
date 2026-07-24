import '../run_state.dart';

class MutationDef {
  final String id;
  final String name;
  final String bonus;
  final String drawback;
  final int unlockCost; // energy crystals, 0 = unlocked from the start
  final void Function(RunState state) apply;

  const MutationDef({
    required this.id,
    required this.name,
    required this.bonus,
    required this.drawback,
    required this.unlockCost,
    required this.apply,
  });
}

final List<MutationDef> kAllMutations = [
  MutationDef(
    id: 'gravitational_core',
    name: 'Gravitational Core',
    bonus: 'Pulls neutral spheres from a much larger range.',
    drawback: 'Orbit rotation speed reduced.',
    unlockCost: 0,
    apply: (s) {
      s.attractRadiusMult *= 2.2;
      s.orbitSpeedMult *= 0.85;
    },
  ),
  MutationDef(
    id: 'overload',
    name: 'Overload',
    bonus: 'Contact damage significantly increased.',
    drawback: 'Satellites are more fragile.',
    unlockCost: 0,
    apply: (s) {
      s.damageMult *= 1.5;
      s.satelliteHpMult *= 0.7;
    },
  ),
  MutationDef(
    id: 'heavy_core',
    name: 'Heavy Core',
    bonus: 'Central core has much higher max durability.',
    drawback: 'Movement speed reduced.',
    unlockCost: 0,
    apply: (s) {
      s.coreHpMult *= 1.8;
      s.moveSpeedMult *= 0.8;
    },
  ),
  MutationDef(
    id: 'light_core',
    name: 'Light Core',
    bonus: 'Movement speed greatly increased.',
    drawback: 'Central core has reduced durability.',
    unlockCost: 200,
    apply: (s) {
      s.moveSpeedMult *= 1.4;
      s.coreHpMult *= 0.65;
    },
  ),
  MutationDef(
    id: 'resonance',
    name: 'Resonance',
    bonus: 'Orbit radius greatly increased.',
    drawback: 'Contact damage reduced.',
    unlockCost: 200,
    apply: (s) {
      s.orbitRadiusMult *= 1.35;
      s.damageMult *= 0.75;
    },
  ),
  MutationDef(
    id: 'parasite',
    name: 'Parasite',
    bonus: 'Defeated enemies always drop crystals.',
    drawback: 'Starts with fewer satellites.',
    unlockCost: 300,
    apply: (s) {
      s.bonusCrystalDrop = true;
      s.startingSatellitesDelta -= 2;
    },
  ),
  MutationDef(
    id: 'regeneration',
    name: 'Regeneration',
    bonus: 'Lost satellites regenerate automatically over time.',
    drawback: 'Slower orbit rotation.',
    unlockCost: 300,
    apply: (s) {
      s.satelliteRegen = true;
      s.orbitSpeedMult *= 0.9;
    },
  ),
  MutationDef(
    id: 'prism',
    name: 'Prism',
    bonus: 'Satellites can reflect enemy projectiles.',
    drawback: 'Satellite durability reduced.',
    unlockCost: 400,
    apply: (s) {
      s.reflectProjectiles = true;
      s.satelliteHpMult *= 0.85;
    },
  ),
  MutationDef(
    id: 'comet',
    name: 'Comet',
    bonus: 'Core moves with a damaging trailing streak.',
    drawback: 'Orbit radius reduced.',
    unlockCost: 400,
    apply: (s) {
      s.cometTrail = true;
      s.orbitRadiusMult *= 0.85;
    },
  ),
  MutationDef(
    id: 'infection',
    name: 'Infection',
    bonus: 'Satellites lost to infection explode violently.',
    drawback: 'Slightly reduced max core durability.',
    unlockCost: 500,
    apply: (s) {
      s.satelliteExplode = true;
      s.coreHpMult *= 0.9;
    },
  ),
];
