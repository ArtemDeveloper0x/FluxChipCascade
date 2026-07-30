import 'package:flutter/material.dart';
import '../../core/audio_manager.dart';
import '../../core/constants.dart';
import '../../core/storage_service.dart';
import '../../core/theme.dart';
import '../../game/data/lab_data.dart';
import 'tab_common.dart';

/// Pilot profile: rank derived from lifetime kills, editable callsign and a
/// snapshot of earned badges and installed lab modules.
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key, required this.onChanged});
  final VoidCallback onChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  static const _ranks = [
    (0, 'Cadet', AppColors.textSecondary),
    (500, 'Ensign', AppColors.green),
    (2500, 'Pilot', AppColors.cyan),
    (10000, 'Ace', AppColors.blue),
    (50000, 'Commander', AppColors.purple),
    (200000, 'Legend', AppColors.gold),
  ];

  (int, String, Color) _rankFor(int kills) {
    var current = _ranks.first;
    for (final r in _ranks) {
      if (kills >= r.$1) current = r;
    }
    return current;
  }

  (int, String, Color)? _nextRank(int kills) {
    for (final r in _ranks) {
      if (kills < r.$1) return r;
    }
    return null;
  }

  Future<void> _editCallsign() async {
    final controller =
        TextEditingController(text: StorageService.I.callsign);
    AudioManager.I.sfx(Sounds.buttonClick);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgPanel,
        title: const Text('Callsign',
            style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          maxLength: 16,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Enter callsign',
            hintStyle: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Save')),
        ],
      ),
    );
    if (result != null) {
      await StorageService.I.setCallsign(result);
      setState(() {});
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = StorageService.I;
    final kills = s.totalKills;
    final rank = _rankFor(kills);
    final next = _nextRank(kills);
    final prevThreshold = rank.$1;
    final progress = next == null
        ? 1.0
        : ((kills - prevThreshold) / (next.$1 - prevThreshold)).clamp(0.0, 1.0);

    final installedModules =
        kLabModules.where((m) => s.labLevel(m.id) > 0).toList();

    return TabScaffold(
      title: 'PILOT',
      subtitle: 'Your commander profile',
      accent: AppColors.purple,
      trailing: CrystalChip(amount: s.crystals),
      children: [
        // Identity card
        NeonCard(
          accent: rank.$3,
          padding: const EdgeInsets.all(18),
          child: Column(children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  rank.$3.withValues(alpha: 0.35),
                  rank.$3.withValues(alpha: 0.08),
                ]),
                border: Border.all(color: rank.$3, width: 2),
                boxShadow: [
                  BoxShadow(color: rank.$3.withValues(alpha: 0.5), blurRadius: 18)
                ],
              ),
              child: Icon(Icons.person_rounded, color: rank.$3, size: 44),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _editCallsign,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(s.callsign,
                    style: AppTheme.neonTitle(size: 22, color: rank.$3)),
                const SizedBox(width: 8),
                Icon(Icons.edit_rounded,
                    color: rank.$3.withValues(alpha: 0.7), size: 16),
              ]),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: rank.$3.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: rank.$3.withValues(alpha: 0.5)),
              ),
              child: Text('RANK · ${rank.$2.toUpperCase()}',
                  style: TextStyle(
                      color: rank.$3,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2)),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Text('$kills kills',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
              const Spacer(),
              Text(next == null ? 'MAX RANK' : 'Next: ${next.$2}',
                  style: TextStyle(
                      color: rank.$3.withValues(alpha: 0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 9,
                backgroundColor: AppColors.panelBorder.withValues(alpha: 0.4),
                valueColor: AlwaysStoppedAnimation(rank.$3),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        _SectionLabel('BADGES'),
        const SizedBox(height: 12),
        Row(children: [
          _Badge(
              icon: Icons.military_tech_rounded,
              color: AppColors.gold,
              value: '${s.claimedAchievements}',
              label: 'Medals'),
          const SizedBox(width: 10),
          _Badge(
              icon: Icons.emoji_events_rounded,
              color: AppColors.cyan,
              value: '${s.bestWaveEver}',
              label: 'Best wave'),
          const SizedBox(width: 10),
          _Badge(
              icon: Icons.dangerous_rounded,
              color: AppColors.orange,
              value: '${s.bossKills}',
              label: 'Bosses'),
        ]),
        const SizedBox(height: 20),

        _SectionLabel('INSTALLED MODULES'),
        const SizedBox(height: 12),
        if (installedModules.isEmpty)
          NeonCard(
            child: Row(children: [
              Icon(Icons.science_outlined,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                  size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('No lab modules installed yet — visit the Lab.',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ),
            ]),
          )
        else
          for (final m in installedModules) ...[
            NeonCard(
              accent: m.color,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(children: [
                Icon(m.icon, color: m.color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(m.name,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ),
                Text(labEffectText(m, s.labLevel(m.id)),
                    style: TextStyle(
                        color: m.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w800)),
              ]),
            ),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.8),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6));
  }
}

class _Badge extends StatelessWidget {
  const _Badge(
      {required this.icon,
      required this.color,
      required this.value,
      required this.label});
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: NeonCard(
        accent: color,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 7),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 17)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: color.withValues(alpha: 0.85),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}
