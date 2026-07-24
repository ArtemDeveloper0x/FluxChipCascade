import 'package:flutter/material.dart';
import '../core/audio_manager.dart';
import '../core/constants.dart';
import '../core/storage_service.dart';
import '../core/theme.dart';

class DailyQuestsScreen extends StatefulWidget {
  const DailyQuestsScreen({super.key});

  @override
  State<DailyQuestsScreen> createState() => _DailyQuestsScreenState();
}

class _DailyQuestsScreenState extends State<DailyQuestsScreen> {
  static const int _rewardPerQuest = 40;

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.I;
    final quests = storage.dailyQuests();
    final progress = storage.dailyQuestProgress();

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(backgroundColor: AppColors.bgDeep, title: const Text('Daily Quests')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: quests.length,
        itemBuilder: (context, i) {
          final q = quests[i];
          final id = q['id'] as String;
          final label = q['label'] as String;
          final target = q['target'] as int;
          final current = (id == 'use_upgrades')
              ? storage.upgradesUsedUnique
              : (progress[id] ?? 0);
          final done = current >= target;
          final claimed = storage.isQuestClaimed(id);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: AppTheme.panelDecoration(
                  glow: done ? AppColors.gold : AppColors.panelBorder),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (current / target).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: const Color(0x33FFFFFF),
                      valueColor: const AlwaysStoppedAnimation(AppColors.cyan),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${current.clamp(0, target)}/$target',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      if (done && !claimed)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
                          onPressed: () async {
                            await storage.addCrystals(_rewardPerQuest);
                            await storage.claimQuest(id);
                            AudioManager.I.sfx(Sounds.rewardChestOpening);
                            setState(() {});
                          },
                          child: const Text('Claim +$_rewardPerQuest'),
                        )
                      else if (claimed)
                        const Text('Claimed', style: TextStyle(color: AppColors.green, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
