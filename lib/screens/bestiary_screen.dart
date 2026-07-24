import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../game/data/enemy_data.dart';

/// A data-driven codex of every hostile in the game: the enemy archetypes and
/// the area mini-bosses, with their live stats pulled from the game data.
class BestiaryScreen extends StatelessWidget {
  const BestiaryScreen({super.key});

  static const Map<EnemyType, String> _enemyDesc = {
    EnemyType.hunter: 'Basic chaser. Rushes straight at your core.',
    EnemyType.destroyer: 'Slow bruiser with heavy contact damage.',
    EnemyType.sniper: 'Keeps its distance and fires energy bolts.',
    EnemyType.magnet: 'Emits pulses that scramble your orbit.',
    EnemyType.kamikaze: 'Fast suicide unit that explodes on impact.',
    EnemyType.virusBall: 'Infects satellites, turning them hostile.',
    EnemyType.swarmer: 'Tiny and fast — attacks in relentless packs.',
    EnemyType.splitter: 'Bursts into two swarmers when destroyed.',
  };

  static const Map<EnemyType, IconData> _enemyIcon = {
    EnemyType.hunter: Icons.navigation,
    EnemyType.destroyer: Icons.shield_moon,
    EnemyType.sniper: Icons.my_location,
    EnemyType.magnet: Icons.wifi_tethering,
    EnemyType.kamikaze: Icons.dangerous,
    EnemyType.virusBall: Icons.coronavirus,
    EnemyType.swarmer: Icons.grain,
    EnemyType.splitter: Icons.call_split,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        title: const Text('Bestiary'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Enemies', AppColors.cyan),
          const SizedBox(height: 10),
          ...EnemyType.values.map((type) {
            final def = kEnemyDefs[type]!;
            return _EntityCard(
              name: def.name,
              description: _enemyDesc[type] ?? '',
              icon: _enemyIcon[type] ?? Icons.bug_report,
              color: def.tint,
              stats: [
                _Stat('HP', def.baseHp.toStringAsFixed(0)),
                _Stat('DMG', def.baseDamage.toStringAsFixed(0)),
                _Stat('SPD', def.baseSpeed.toStringAsFixed(0)),
                _Stat('DROP', '${def.crystalDrop}'),
              ],
            );
          }),
          const SizedBox(height: 22),
          _sectionTitle('Mini-Bosses', AppColors.red),
          const SizedBox(height: 10),
          ...MiniBossType.values.map((type) {
            final def = kMiniBossDefs[type]!;
            return _EntityCard(
              name: def.name,
              description: def.ability,
              icon: Icons.local_fire_department,
              color: def.tint,
              stats: [
                _Stat('HP', def.baseHp.toStringAsFixed(0)),
                _Stat('DMG', def.baseDamage.toStringAsFixed(0)),
              ],
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, Color color) {
    return Row(
      children: [
        Container(width: 4, height: 20, color: color),
        const SizedBox(width: 8),
        Text(text,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w900, fontSize: 18)),
      ],
    );
  }
}

class _Stat {
  final String label;
  final String value;
  const _Stat(this.label, this.value);
}

class _EntityCard extends StatelessWidget {
  const _EntityCard({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.stats,
  });

  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final List<_Stat> stats;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.panelDecoration(glow: color),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.6)),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(description,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 14,
                    runSpacing: 4,
                    children: stats
                        .map((s) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${s.label} ',
                                    style: TextStyle(
                                        color: color.withValues(alpha: 0.85),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                                Text(s.value,
                                    style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
