import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Permanent meta-upgrades bought in the SHOP tab with energy crystals.
///
/// Each purchased level is persisted via `StorageService.labLevel(id)` and read
/// once per run in `FluxGame.onLoad`, so buying modules makes every future run
/// measurably stronger.
class LabModule {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int maxLevel;
  final int baseCost;
  final double costMult;

  /// Per-level effect magnitude (e.g. 0.10 == +10% per level). For the
  /// deployment bay this is a flat +1 satellite per level.
  final double perLevel;

  const LabModule({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.maxLevel,
    required this.baseCost,
    required this.costMult,
    required this.perLevel,
  });

  /// Crystal cost to go from [level] to [level]+1.
  int costForNext(int level) {
    var cost = baseCost.toDouble();
    for (var i = 0; i < level; i++) {
      cost *= costMult;
    }
    return cost.round();
  }
}

const List<LabModule> kLabModules = [
  LabModule(
    id: 'hull',
    name: 'Reinforced Hull',
    description: 'Plates the core with extra armor. More HP to survive longer.',
    icon: Icons.shield_rounded,
    color: AppColors.green,
    maxLevel: 5,
    baseCost: 60,
    costMult: 1.6,
    perLevel: 0.10,
  ),
  LabModule(
    id: 'bay',
    name: 'Deployment Bay',
    description: 'Launch the run with additional satellites already in orbit.',
    icon: Icons.workspaces_rounded,
    color: AppColors.cyan,
    maxLevel: 3,
    baseCost: 140,
    costMult: 2.1,
    perLevel: 1,
  ),
  LabModule(
    id: 'cannon',
    name: 'Cannon Overclock',
    description: 'Tunes the Core Pulse Cannon for higher projectile damage.',
    icon: Icons.bolt_rounded,
    color: AppColors.orange,
    maxLevel: 5,
    baseCost: 80,
    costMult: 1.7,
    perLevel: 0.08,
  ),
  LabModule(
    id: 'core',
    name: 'Power Core',
    description: 'Supercharges the orbit so satellites grind enemies faster.',
    icon: Icons.blur_on_rounded,
    color: AppColors.magenta,
    maxLevel: 5,
    baseCost: 90,
    costMult: 1.75,
    perLevel: 0.06,
  ),
  LabModule(
    id: 'magnet',
    name: 'Crystal Magnet',
    description: 'Refines salvage tech for a bigger crystal payout each run.',
    icon: Icons.diamond_rounded,
    color: AppColors.gold,
    maxLevel: 5,
    baseCost: 70,
    costMult: 1.7,
    perLevel: 0.12,
  ),
];

/// Module-aware effect text used by the shop UI.
String labEffectText(LabModule m, int level) {
  if (level <= 0) return 'Not installed';
  if (m.id == 'bay') {
    return '+$level satellite${level == 1 ? '' : 's'} at start';
  }
  return '+${(m.perLevel * level * 100).round()}% ${_effectNoun(m.id)}';
}

String _effectNoun(String id) {
  switch (id) {
    case 'hull':
      return 'core HP';
    case 'cannon':
      return 'cannon damage';
    case 'core':
      return 'orbit damage';
    case 'magnet':
      return 'crystal reward';
    default:
      return 'bonus';
  }
}
