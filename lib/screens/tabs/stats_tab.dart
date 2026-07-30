import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/storage_service.dart';
import '../../core/theme.dart';
import 'tab_common.dart';

/// Career dashboard built entirely from persisted meta stats.
class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final s = StorageService.I;
    final stats = <_StatItem>[
      _StatItem(Icons.whatshot_rounded, AppColors.red, '${s.totalKills}', 'Total kills'),
      _StatItem(Icons.flag_rounded, AppColors.cyan, '${s.totalRunsCompleted}', 'Runs finished'),
      _StatItem(Icons.emoji_events_rounded, AppColors.gold, '${s.bestWaveEver}', 'Best wave'),
      _StatItem(Icons.blur_on_rounded, AppColors.green, '${s.totalSpheresCollected}', 'Spheres'),
      _StatItem(Icons.coronavirus_rounded, AppColors.purple, '${s.infectedKills}', 'Infected slain'),
      _StatItem(Icons.dangerous_rounded, AppColors.orange, '${s.bossKills}', 'Bosses down'),
      _StatItem(Icons.radar_rounded, AppColors.blue, '${s.bestOrbitSize}', 'Best orbit'),
      _StatItem(Icons.dark_mode_rounded, AppColors.magenta, '${s.blackHolesSurvived}', 'Black holes'),
      _StatItem(Icons.auto_awesome_rounded, AppColors.cyan, '${s.upgradesUsedUnique}', 'Augments used'),
    ];

    return TabScaffold(
      title: 'STATS',
      subtitle: 'Your career across every run',
      accent: AppColors.green,
      trailing: CrystalChip(amount: s.crystals),
      children: [
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.92,
          children: [for (final it in stats) _StatCard(item: it)],
        ),
        const SizedBox(height: 18),
        Text('MILESTONES',
            style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6)),
        const SizedBox(height: 12),
        _Milestone(
            label: 'Exterminator',
            color: AppColors.red,
            value: s.totalKills,
            target: _nextTier(s.totalKills, const [500, 2500, 10000, 50000])),
        const SizedBox(height: 10),
        _Milestone(
            label: 'Veteran Pilot',
            color: AppColors.cyan,
            value: s.totalRunsCompleted,
            target: _nextTier(s.totalRunsCompleted, const [5, 25, 100, 500])),
        const SizedBox(height: 10),
        _Milestone(
            label: 'Boss Hunter',
            color: AppColors.orange,
            value: s.bossKills,
            target: _nextTier(s.bossKills, const [3, 15, 50, 200])),
      ],
    );
  }

  int _nextTier(int value, List<int> tiers) {
    for (final t in tiers) {
      if (value < t) return t;
    }
    return tiers.last;
  }
}

class _StatItem {
  const _StatItem(this.icon, this.color, this.value, this.label);
  final IconData icon;
  final Color color;
  final String value;
  final String label;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});
  final _StatItem item;

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      accent: item.color,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: item.color, size: 22),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(item.value,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 20)),
          ),
          const SizedBox(height: 3),
          Text(item.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: item.color.withValues(alpha: 0.85),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Milestone extends StatelessWidget {
  const _Milestone(
      {required this.label,
      required this.color,
      required this.value,
      required this.target});
  final String label;
  final Color color;
  final int value;
  final int target;

  @override
  Widget build(BuildContext context) {
    final pct = (value / target).clamp(0.0, 1.0);
    return NeonCard(
      accent: color,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13)),
            const Spacer(),
            Text('$value / $target',
                style: TextStyle(
                    color: color.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppColors.panelBorder.withValues(alpha: 0.4),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
