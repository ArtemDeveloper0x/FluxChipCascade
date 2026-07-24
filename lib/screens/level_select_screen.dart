import 'package:flutter/material.dart';
import '../core/audio_manager.dart';
import '../core/constants.dart';
import '../core/storage_service.dart';
import '../core/theme.dart';
import '../game/data/level_data.dart';
import 'mutation_select_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  @override
  Widget build(BuildContext context) {
    final maxUnlocked = StorageService.I.maxUnlockedLevel;
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        title: const Text('Select Level'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: kLocations.length,
        itemBuilder: (context, locIndex) {
          final loc = kLocations[locIndex];
          final levelsInLoc = kLevels.where((l) => l.locationIndex == locIndex).toList();
          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.name,
                    style: const TextStyle(
                        color: AppColors.cyan, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(loc.description,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: levelsInLoc.length,
                  itemBuilder: (context, i) {
                    final level = levelsInLoc[i];
                    final unlocked = level.level <= maxUnlocked;
                    final isBoss = level.isLocationFinale;
                    return GestureDetector(
                      onTap: unlocked
                          ? () {
                              AudioManager.I.sfx(Sounds.buttonClick);
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => MutationSelectScreen(level: level)));
                            }
                          : () => AudioManager.I.sfx(Sounds.errorNotification, volume: 0.4),
                      child: Container(
                        decoration: AppTheme.panelDecoration(
                            glow: unlocked
                                ? (isBoss ? AppColors.red : AppColors.cyan)
                                : AppColors.panelBorder),
                        alignment: Alignment.center,
                        child: unlocked
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isBoss)
                                    const Icon(Icons.local_fire_department,
                                        color: AppColors.red, size: 14),
                                  Text('${level.level}',
                                      style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.bold)),
                                ],
                              )
                            : const Icon(Icons.lock, color: AppColors.textSecondary, size: 16),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
