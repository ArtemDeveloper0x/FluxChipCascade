import 'package:flutter/material.dart';
import '../core/audio_manager.dart';
import '../core/constants.dart';
import '../core/storage_service.dart';
import '../core/theme.dart';
import '../game/data/level_data.dart';
import '../game/data/mutation_data.dart';
import 'game_screen.dart';

class MutationSelectScreen extends StatefulWidget {
  const MutationSelectScreen({super.key, required this.level});
  final LevelConfig level;

  @override
  State<MutationSelectScreen> createState() => _MutationSelectScreenState();
}

class _MutationSelectScreenState extends State<MutationSelectScreen> {
  @override
  Widget build(BuildContext context) {
    final unlocked = StorageService.I.unlockedMutations;
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        title: Text('Level ${widget.level.level} · ${widget.level.location.name}'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: kAllMutations.length,
        itemBuilder: (context, i) {
          final m = kAllMutations[i];
          final isUnlocked = unlocked.contains(m.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () async {
                if (!isUnlocked) {
                  if (m.unlockCost > 0 && StorageService.I.crystals >= m.unlockCost) {
                    await _confirmUnlock(m);
                  } else {
                    AudioManager.I.sfx(Sounds.errorNotification, volume: 0.5);
                  }
                  return;
                }
                AudioManager.I.sfx(Sounds.buttonClick);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => GameScreen(level: widget.level, mutationId: m.id),
                ));
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: AppTheme.panelDecoration(
                    glow: isUnlocked ? AppColors.purple : AppColors.panelBorder),
                child: Row(
                  children: [
                    Icon(isUnlocked ? Icons.auto_awesome : Icons.lock,
                        color: isUnlocked ? AppColors.purple : AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name,
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          const SizedBox(height: 3),
                          Text('+ ${m.bonus}',
                              style: const TextStyle(color: AppColors.green, fontSize: 11)),
                          Text('- ${m.drawback}',
                              style: const TextStyle(color: AppColors.red, fontSize: 11)),
                        ],
                      ),
                    ),
                    if (!isUnlocked)
                      Column(
                        children: [
                          const Icon(Icons.diamond, color: AppColors.gold, size: 14),
                          Text('${m.unlockCost}',
                              style: const TextStyle(color: AppColors.gold, fontSize: 11)),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmUnlock(MutationDef m) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgPanel,
        title: Text('Unlock ${m.name}?', style: const TextStyle(color: AppColors.textPrimary)),
        content: Text('Cost: ${m.unlockCost} crystals',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Unlock')),
        ],
      ),
    );
    if (confirmed == true) {
      final ok = await StorageService.I.spendCrystals(m.unlockCost);
      if (ok) {
        await StorageService.I.unlockMutation(m.id);
        AudioManager.I.sfx(Sounds.buyUpgrade);
        setState(() {});
      }
    }
  }
}
