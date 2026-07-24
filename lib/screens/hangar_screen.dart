import 'package:flutter/material.dart';
import '../core/audio_manager.dart';
import '../core/constants.dart';
import '../core/storage_service.dart';
import '../core/theme.dart';
import '../game/data/mutation_data.dart';

/// Meta-progression hub: spend energy crystals to unlock new starting
/// mutations, and review lifetime statistics.
class HangarScreen extends StatefulWidget {
  const HangarScreen({super.key});

  @override
  State<HangarScreen> createState() => _HangarScreenState();
}

class _HangarScreenState extends State<HangarScreen> {
  @override
  Widget build(BuildContext context) {
    final storage = StorageService.I;
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        title: const Text('Hangar'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.diamond, color: AppColors.gold, size: 16),
                const SizedBox(width: 4),
                Text('${storage.crystals}',
                    style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: AppTheme.panelDecoration(glow: AppColors.cyan),
            child: Wrap(
              spacing: 18,
              runSpacing: 10,
              children: [
                _stat('Total kills', '${storage.totalKills}'),
                _stat('Runs completed', '${storage.totalRunsCompleted}'),
                _stat('Spheres collected', '${storage.totalSpheresCollected}'),
                _stat('Best orbit size', '${storage.bestOrbitSize}'),
                _stat('Boss kills', '${storage.bossKills}'),
                _stat('Best wave', '${storage.bestWaveEver}'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Mutations',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          ...kAllMutations.map((m) {
            final unlocked = storage.unlockedMutations.contains(m.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: AppTheme.panelDecoration(
                    glow: unlocked ? AppColors.purple : AppColors.panelBorder),
                child: Row(
                  children: [
                    Icon(unlocked ? Icons.auto_awesome : Icons.lock,
                        color: unlocked ? AppColors.purple : AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name,
                              style: const TextStyle(
                                  color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                          Text('+ ${m.bonus}', style: const TextStyle(color: AppColors.green, fontSize: 11)),
                          Text('- ${m.drawback}', style: const TextStyle(color: AppColors.red, fontSize: 11)),
                        ],
                      ),
                    ),
                    if (!unlocked)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
                        onPressed: () async {
                          if (storage.crystals < m.unlockCost) {
                            AudioManager.I.sfx(Sounds.errorNotification, volume: 0.5);
                            return;
                          }
                          final ok = await storage.spendCrystals(m.unlockCost);
                          if (ok) {
                            await storage.unlockMutation(m.id);
                            AudioManager.I.sfx(Sounds.buyUpgrade);
                            setState(() {});
                          }
                        },
                        child: Text('${m.unlockCost}'),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
