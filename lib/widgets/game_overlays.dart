import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../game/data/event_data.dart';
import '../game/data/level_data.dart';
import '../game/data/upgrade_data.dart';
import '../game/run_state.dart';

/// Top HUD: core hp, satellite count, crystals, wave, timer, kills, pause.
class GameHud extends StatelessWidget {
  const GameHud({super.key, required this.runState, required this.onPause});

  final RunState runState;
  final VoidCallback onPause;

  String _fmtTime(double s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toInt().toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: runState,
      builder: (context, _) {
        final hpPct = (runState.coreHp / runState.coreMaxHp).clamp(0.0, 1.0);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: AppTheme.panelDecoration(glow: AppColors.cyan),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.shield, size: 14, color: AppColors.cyan),
                                const SizedBox(width: 4),
                                Text('${runState.coreHp}/${runState.coreMaxHp}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                              ],
                            ),
                            const SizedBox(height: 3),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: hpPct,
                                minHeight: 6,
                                backgroundColor: const Color(0x33FFFFFF),
                                valueColor: AlwaysStoppedAnimation(
                                    hpPct < 0.3 ? AppColors.red : AppColors.cyan),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatChip(icon: Icons.blur_circular, label: '${runState.satelliteCount}'),
                    const SizedBox(width: 8),
                    _StatChip(
                        icon: Icons.diamond,
                        label: '${runState.crystalsThisRun}',
                        color: AppColors.gold),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onPause,
                      child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: AppTheme.panelDecoration(),
                        child: const Icon(Icons.pause, size: 18, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _StatChip(
                        icon: Icons.waves,
                        label: runState.bossActive
                            ? 'BOSS'
                            : 'Wave ${runState.wave}/${runState.level.waveCount}',
                        color: runState.bossActive ? AppColors.red : null),
                    const SizedBox(width: 8),
                    _StatChip(icon: Icons.timer, label: _fmtTime(runState.elapsedSeconds)),
                    const SizedBox(width: 8),
                    _StatChip(icon: Icons.whatshot, label: '${runState.killCount}'),
                    const SizedBox(width: 8),
                    _StatChip(icon: Icons.star, label: 'Lv ${runState.runLevel}'),
                  ],
                ),
                const SizedBox(height: 6),
                _WaveProgressBar(
                  wave: runState.wave,
                  total: runState.level.waveCount,
                  bossActive: runState.bossActive,
                ),
                if (runState.activeEventName != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: AppTheme.panelDecoration(glow: AppColors.magenta),
                      child: Text(
                        runState.activeEventName!.toUpperCase(),
                        style: const TextStyle(
                            color: AppColors.magenta, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label, this.color});
  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: AppTheme.panelDecoration(glow: color),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? AppColors.textPrimary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

/// Slim segmented bar that fills as the player clears waves toward the boss.
class _WaveProgressBar extends StatelessWidget {
  const _WaveProgressBar({
    required this.wave,
    required this.total,
    required this.bossActive,
  });
  final int wave;
  final int total;
  final bool bossActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(total, (i) {
              final done = (i + 1) < wave || bossActive;
              final current = (i + 1) == wave && !bossActive;
              return Expanded(
                child: Container(
                  height: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: done
                        ? AppColors.cyan
                        : current
                            ? AppColors.cyan.withValues(alpha: 0.55)
                            : const Color(0x332C3B77),
                    boxShadow: (done || current)
                        ? [BoxShadow(color: AppColors.cyan.withValues(alpha: 0.5), blurRadius: 6)]
                        : null,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 6),
        Icon(Icons.emoji_events_rounded,
            size: 15,
            color: bossActive ? AppColors.red : AppColors.gold.withValues(alpha: 0.7)),
      ],
    );
  }
}

/// Brief mission briefing shown when a level starts, so the player always
/// knows the immediate goal instead of wandering.
class ObjectiveBanner extends StatelessWidget {
  const ObjectiveBanner({super.key, required this.level});
  final LevelConfig level;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0, -0.45),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutBack,
          builder: (context, v, child) => Opacity(
            opacity: v.clamp(0.0, 1.0),
            child: Transform.scale(scale: 0.9 + 0.1 * v.clamp(0.0, 1.0), child: child),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            decoration: AppTheme.panelDecoration(glow: AppColors.cyan),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('LEVEL ${level.level}  •  ${level.location.name}'.toUpperCase(),
                    style: TextStyle(
                        color: AppColors.cyan,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 1.4)),
                const SizedBox(height: 8),
                _objectiveRow(Icons.blur_circular,
                    'Collect glowing spheres to grow your orbit'),
                const SizedBox(height: 5),
                _objectiveRow(Icons.waves_rounded,
                    'Survive ${level.waveCount} waves'),
                const SizedBox(height: 5),
                _objectiveRow(Icons.emoji_events_rounded,
                    'Destroy the ${level.location.name} boss'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _objectiveRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.gold),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 12.5)),
      ],
    );
  }
}

/// One-time "how to play" card shown before the very first run.
class TutorialOverlay extends StatelessWidget {
  const TutorialOverlay({super.key, required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.88),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('HOW TO PLAY', style: AppTheme.neonTitle(size: 26, color: AppColors.cyan)),
            const SizedBox(height: 18),
            Container(
              width: 320,
              padding: const EdgeInsets.all(18),
              decoration: AppTheme.panelDecoration(),
              child: Column(
                children: const [
                  _TutorialRow(
                    icon: Icons.touch_app_rounded,
                    color: AppColors.cyan,
                    title: 'Move',
                    text: 'Drag anywhere to fly your core. Dodge the swarm.',
                  ),
                  SizedBox(height: 14),
                  _TutorialRow(
                    icon: Icons.blur_circular,
                    color: AppColors.green,
                    title: 'Grow your orbit',
                    text: 'Fly over glowing spheres. Each adds a satellite that '
                        'shields you and grinds enemies on contact.',
                  ),
                  SizedBox(height: 14),
                  _TutorialRow(
                    icon: Icons.auto_awesome,
                    color: AppColors.gold,
                    title: 'Level up',
                    text: 'Defeating enemies grants XP. Pick powerful upgrades — '
                        'rarer ones reshape your whole build.',
                  ),
                  SizedBox(height: 14),
                  _TutorialRow(
                    icon: Icons.emoji_events_rounded,
                    color: AppColors.red,
                    title: 'Win the level',
                    text: 'Survive every wave, then destroy the area boss.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _MenuButton(label: "Let's go", icon: Icons.rocket_launch_rounded, onTap: onStart),
          ],
        ),
      ),
    );
  }
}

class _TutorialRow extends StatelessWidget {
  const _TutorialRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w800, fontSize: 14)),
              const SizedBox(height: 3),
              Text(text,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11.5, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Fullscreen dimmed overlay presenting 3 random upgrade choices.
class UpgradeChoiceOverlay extends StatelessWidget {
  const UpgradeChoiceOverlay({
    super.key,
    required this.indexes,
    required this.onChosen,
  });

  final List<int> indexes;
  final void Function(int upgradeIndex) onChosen;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('AUGMENT READY', style: AppTheme.neonTitle(size: 26, color: AppColors.gold)),
            const SizedBox(height: 6),
            const Text('Pick one upgrade to power up your core',
                style: TextStyle(color: AppColors.textSecondary, letterSpacing: 1.0)),
            const SizedBox(height: 18),
            ...indexes.map((idx) {
              final upgrade = kAllUpgrades[idx];
              final rc = upgrade.rarity.color;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                child: GestureDetector(
                  onTap: () => onChosen(idx),
                  child: Container(
                    width: 330,
                    padding: const EdgeInsets.all(14),
                    decoration: AppTheme.panelDecoration(glow: rc),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: rc.withValues(alpha: 0.16),
                            shape: BoxShape.circle,
                            border: Border.all(color: rc.withValues(alpha: 0.7), width: 1.5),
                          ),
                          child: Icon(_categoryIcon(upgrade.category), color: rc),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(upgrade.name,
                                        style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14.5)),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: rc.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                          color: rc.withValues(alpha: 0.6), width: 0.8),
                                    ),
                                    child: Text(upgrade.rarity.label,
                                        style: TextStyle(
                                            color: rc,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.8)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(upgrade.description,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                      height: 1.25)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(UpgradeCategory c) {
    switch (c) {
      case UpgradeCategory.attack:
        return Icons.flash_on;
      case UpgradeCategory.defense:
        return Icons.shield;
      case UpgradeCategory.mobility:
        return Icons.speed;
      case UpgradeCategory.utility:
        return Icons.auto_awesome;
    }
  }
}

/// Small transient banner shown when a random global event begins.
class EventBanner extends StatelessWidget {
  const EventBanner({super.key, required this.event});
  final GameEventDef event;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.35),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 400),
        builder: (context, v, child) => Opacity(opacity: v, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: AppTheme.panelDecoration(glow: event.color),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(event.name.toUpperCase(),
                  style: TextStyle(
                      color: event.color, fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 4),
              Text(event.description,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pause menu overlay with resume / restart / quit options.
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
  });

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('PAUSED', style: AppTheme.neonTitle(size: 30)),
          const SizedBox(height: 24),
          _MenuButton(label: 'Resume', icon: Icons.play_arrow, onTap: onResume),
          const SizedBox(height: 12),
          _MenuButton(label: 'Restart', icon: Icons.refresh, onTap: onRestart),
          const SizedBox(height: 12),
          _MenuButton(label: 'Quit to Menu', icon: Icons.home, onTap: onQuit),
        ],
      ),
    );
  }
}

/// Shown when the run ends, either in victory or defeat.
class EndRunOverlay extends StatelessWidget {
  const EndRunOverlay({
    super.key,
    required this.victory,
    required this.runState,
    required this.crystalReward,
    required this.onContinue,
    required this.onRetry,
    required this.onMenu,
  });

  final bool victory;
  final RunState runState;
  final int crystalReward;
  final VoidCallback onContinue;
  final VoidCallback onRetry;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final totalCrystals = runState.crystalsThisRun + crystalReward;
    return Container(
      color: Colors.black.withValues(alpha: 0.86),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            victory ? 'VICTORY' : 'CORE DESTROYED',
            style: AppTheme.neonTitle(
                size: 32, color: victory ? AppColors.gold : AppColors.red),
          ),
          const SizedBox(height: 18),
          Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.panelDecoration(),
            child: Column(
              children: [
                _resultRow('Wave reached', '${runState.wave}'),
                _resultRow('Enemies defeated', '${runState.killCount}'),
                _resultRow('Satellites at end', '${runState.satelliteCount}'),
                _resultRow('Crystals earned', '$totalCrystals'),
              ],
            ),
          ),
          const SizedBox(height: 22),
          if (victory)
            _MenuButton(label: 'Continue', icon: Icons.arrow_forward, onTap: onContinue),
          const SizedBox(height: 12),
          _MenuButton(label: 'Try Again', icon: Icons.refresh, onTap: onRetry),
          const SizedBox(height: 12),
          _MenuButton(label: 'Main Menu', icon: Icons.home, onTap: onMenu),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: AppTheme.panelDecoration(glow: AppColors.cyan),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.cyan, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
