import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../game/data/event_data.dart';
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
                    _StatChip(icon: Icons.waves, label: 'Wave ${runState.wave}'),
                    const SizedBox(width: 8),
                    _StatChip(icon: Icons.timer, label: _fmtTime(runState.elapsedSeconds)),
                    const SizedBox(width: 8),
                    _StatChip(icon: Icons.whatshot, label: '${runState.killCount}'),
                    const SizedBox(width: 8),
                    _StatChip(icon: Icons.star, label: 'Lv ${runState.runLevel}'),
                  ],
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
      color: Colors.black.withValues(alpha: 0.75),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('LEVEL UP', style: AppTheme.neonTitle(size: 26, color: AppColors.gold)),
          const SizedBox(height: 6),
          const Text('Choose an upgrade', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 18),
          ...indexes.map((idx) {
            final upgrade = kAllUpgrades[idx];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 6),
              child: GestureDetector(
                onTap: () => onChosen(idx),
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(14),
                  decoration: AppTheme.panelDecoration(glow: _categoryColor(upgrade.category)),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _categoryColor(upgrade.category).withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_categoryIcon(upgrade.category),
                            color: _categoryColor(upgrade.category)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(upgrade.name,
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 3),
                            Text(upgrade.description,
                                style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 11)),
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
    );
  }

  Color _categoryColor(UpgradeCategory c) {
    switch (c) {
      case UpgradeCategory.attack:
        return AppColors.red;
      case UpgradeCategory.defense:
        return AppColors.cyan;
      case UpgradeCategory.mobility:
        return AppColors.green;
      case UpgradeCategory.utility:
        return AppColors.gold;
    }
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
