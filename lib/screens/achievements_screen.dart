import 'package:flutter/material.dart';
import '../core/audio_manager.dart';
import '../core/constants.dart';
import '../core/storage_service.dart';
import '../core/theme.dart';

/// A permanent milestone. [progress] reads live lifetime stats from storage.
class _Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int target;
  final int reward; // energy crystals
  final int Function(StorageService s) progress;

  const _Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.target,
    required this.reward,
    required this.progress,
  });
}

const List<_Achievement> _kAchievements = [
  _Achievement(
    id: 'first_blood',
    title: 'First Contact',
    description: 'Defeat 10 enemies',
    icon: Icons.flash_on,
    color: AppColors.cyan,
    target: 10,
    reward: 30,
    progress: _kills,
  ),
  _Achievement(
    id: 'exterminator',
    title: 'Exterminator',
    description: 'Defeat 500 enemies',
    icon: Icons.whatshot,
    color: AppColors.orange,
    target: 500,
    reward: 120,
    progress: _kills,
  ),
  _Achievement(
    id: 'sphere_hoarder',
    title: 'Sphere Hoarder',
    description: 'Collect 200 energy spheres',
    icon: Icons.blur_circular,
    color: AppColors.green,
    target: 200,
    reward: 60,
    progress: _spheres,
  ),
  _Achievement(
    id: 'boss_slayer',
    title: 'Boss Slayer',
    description: 'Defeat your first mini-boss',
    icon: Icons.local_fire_department,
    color: AppColors.red,
    target: 1,
    reward: 80,
    progress: _bosses,
  ),
  _Achievement(
    id: 'boss_hunter',
    title: 'Boss Hunter',
    description: 'Defeat 10 bosses',
    icon: Icons.military_tech,
    color: AppColors.magenta,
    target: 10,
    reward: 180,
    progress: _bosses,
  ),
  _Achievement(
    id: 'marathon',
    title: 'Marathon',
    description: 'Complete 5 runs',
    icon: Icons.emoji_events,
    color: AppColors.gold,
    target: 5,
    reward: 140,
    progress: _runs,
  ),
  _Achievement(
    id: 'grand_orbit',
    title: 'Grand Orbit',
    description: 'Build an orbit of 25 satellites',
    icon: Icons.track_changes,
    color: AppColors.blue,
    target: 25,
    reward: 100,
    progress: _orbit,
  ),
  _Achievement(
    id: 'survivor',
    title: 'Survivor',
    description: 'Reach wave 10 in a single run',
    icon: Icons.waves,
    color: AppColors.cyan,
    target: 10,
    reward: 90,
    progress: _wave,
  ),
  _Achievement(
    id: 'purifier',
    title: 'Purifier',
    description: 'Destroy 50 infected enemies',
    icon: Icons.coronavirus,
    color: AppColors.purple,
    target: 50,
    reward: 110,
    progress: _infected,
  ),
];

int _kills(StorageService s) => s.totalKills;
int _spheres(StorageService s) => s.totalSpheresCollected;
int _bosses(StorageService s) => s.bossKills;
int _runs(StorageService s) => s.totalRunsCompleted;
int _orbit(StorageService s) => s.bestOrbitSize;
int _wave(StorageService s) => s.bestWaveEver;
int _infected(StorageService s) => s.infectedKills;

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  @override
  Widget build(BuildContext context) {
    final storage = StorageService.I;
    final unlocked = _kAchievements
        .where((a) => a.progress(storage) >= a.target)
        .length;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        title: const Text('Achievements'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.diamond, color: AppColors.gold, size: 16),
                const SizedBox(width: 4),
                Text('${storage.crystals}',
                    style: const TextStyle(
                        color: AppColors.gold, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: AppTheme.panelDecoration(glow: AppColors.gold),
              child: Row(
                children: [
                  const Icon(Icons.military_tech, color: AppColors.gold),
                  const SizedBox(width: 12),
                  Text('$unlocked / ${_kAchievements.length} unlocked',
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _kAchievements.length,
              itemBuilder: (context, i) {
                final a = _kAchievements[i];
                final current = a.progress(storage);
                final done = current >= a.target;
                final claimed = storage.isAchievementClaimed(a.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: AppTheme.panelDecoration(
                        glow: done ? a.color : AppColors.panelBorder),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: a.color.withValues(
                                    alpha: done ? 0.22 : 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(a.icon,
                                  color: done
                                      ? a.color
                                      : AppColors.textSecondary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(a.title,
                                      style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  Text(a.description,
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                            if (done && !claimed)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: a.color,
                                    foregroundColor: AppColors.bgDeep),
                                onPressed: () async {
                                  await storage.addCrystals(a.reward);
                                  await storage.claimAchievement(a.id);
                                  AudioManager.I.sfx(Sounds.rewardChestOpening);
                                  setState(() {});
                                },
                                child: Text('+${a.reward}'),
                              )
                            else if (claimed)
                              const Icon(Icons.check_circle,
                                  color: AppColors.green)
                            else
                              Text('+${a.reward}',
                                  style: const TextStyle(
                                      color: AppColors.gold,
                                      fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (current / a.target).clamp(0.0, 1.0),
                            minHeight: 7,
                            backgroundColor: const Color(0x33FFFFFF),
                            valueColor: AlwaysStoppedAnimation(a.color),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text('${current.clamp(0, a.target)}/${a.target}',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
