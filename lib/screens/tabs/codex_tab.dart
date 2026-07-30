import 'package:flutter/material.dart';
import '../../core/audio_manager.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../game/data/enemy_data.dart';
import '../../game/data/event_data.dart';
import '../bestiary_screen.dart';
import 'tab_common.dart';

/// Encyclopedia hub: enemies (links to full bestiary), area bosses and the
/// global random events, so players can study threats before a run.
class CodexTab extends StatelessWidget {
  const CodexTab({super.key});

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      title: 'CODEX',
      subtitle: 'Study every threat in the cascade',
      accent: AppColors.magenta,
      children: [
        // Enemies -> full bestiary
        GestureDetector(
          onTap: () {
            AudioManager.I.sfx(Sounds.buttonClick);
            Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BestiaryScreen()));
          },
          child: NeonCard(
            accent: AppColors.cyan,
            child: Row(children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cyan.withValues(alpha: 0.5)),
                ),
                child: const Icon(Icons.bug_report_rounded,
                    color: AppColors.cyan, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Enemy Bestiary',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 15)),
                    SizedBox(height: 2),
                    Text('Full roster of hostile archetypes',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.cyan, size: 22),
            ]),
          ),
        ),
        const SizedBox(height: 22),

        _SectionTitle('AREA BOSSES', AppColors.orange),
        const SizedBox(height: 12),
        for (final b in kMiniBossDefs.values) ...[
          _EntryCard(
            color: b.tint,
            icon: Icons.dangerous_rounded,
            title: b.name,
            subtitle: b.ability,
            stat: 'HP ${b.baseHp.round()} · DMG ${b.baseDamage.round()}',
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 12),

        _SectionTitle('COSMIC EVENTS', AppColors.purple),
        const SizedBox(height: 12),
        for (final e in kEventDefs.values) ...[
          _EntryCard(
            color: e.color,
            icon: Icons.flare_rounded,
            title: e.name,
            subtitle: e.description,
            stat: '${e.duration.round()}s',
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 3, height: 16, color: color),
      const SizedBox(width: 8),
      Text(label,
          style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6)),
    ]);
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard(
      {required this.color,
      required this.icon,
      required this.title,
      required this.subtitle,
      required this.stat});
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final String stat;

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      accent: color,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(title,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14)),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(stat,
                        style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w800)),
                  ),
                ]),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
