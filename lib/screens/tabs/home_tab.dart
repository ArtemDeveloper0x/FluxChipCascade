import 'package:flutter/material.dart';
import '../../core/audio_manager.dart';
import '../../core/constants.dart';
import '../../core/storage_service.dart';
import '../../core/theme.dart';
import '../achievements_screen.dart';
import '../bestiary_screen.dart';
import '../daily_quests_screen.dart';
import '../hangar_screen.dart';
import '../level_select_screen.dart';
import '../settings_screen.dart';
import '../webview_screen.dart';

/// Landing tab: the play hub with the big PLAY action, a quick stats strip and
/// fast links into the existing meta screens.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key, required this.onChanged});
  final VoidCallback onChanged;

  void _sfx() => AudioManager.I.sfx(Sounds.buttonClick);

  Future<void> _open(BuildContext context, Widget screen) async {
    _sfx();
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final store = StorageService.I;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 92),
      children: [
        // stats strip
        Row(children: [
          _MiniStat(
              icon: Icons.diamond_rounded,
              color: AppColors.gold,
              value: '${store.crystals}',
              label: 'CRYSTALS'),
          const SizedBox(width: 10),
          _MiniStat(
              icon: Icons.emoji_events_rounded,
              color: AppColors.cyan,
              value: '${store.bestWaveEver}',
              label: 'BEST WAVE'),
          const SizedBox(width: 10),
          _MiniStat(
              icon: Icons.flag_rounded,
              color: AppColors.green,
              value: '${store.maxUnlockedLevel}',
              label: 'LEVEL'),
        ]),
        const SizedBox(height: 26),

        // logo
        Center(child: Image.asset(Assets.gameName, width: 220)),
        const SizedBox(height: 6),
        const Center(
          child: Text('GROW YOUR ORBIT · SURVIVE THE CASCADE',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.cyan,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4)),
        ),
        const SizedBox(height: 26),

        // PLAY
        _PlayButton(onTap: () => _open(context, const LevelSelectScreen())),
        const SizedBox(height: 22),

        Text('COMMAND DECK',
            style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6)),
        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.0,
          children: [
            _HubTile(
                icon: Icons.workspaces_rounded,
                label: 'Hangar',
                color: AppColors.purple,
                onTap: () => _open(context, const HangarScreen())),
            _HubTile(
                icon: Icons.checklist_rounded,
                label: 'Quests',
                color: AppColors.green,
                onTap: () => _open(context, const DailyQuestsScreen())),
            _HubTile(
                icon: Icons.military_tech_rounded,
                label: 'Medals',
                color: AppColors.gold,
                onTap: () => _open(context, const AchievementsScreen())),
            _HubTile(
                icon: Icons.menu_book_rounded,
                label: 'Bestiary',
                color: AppColors.cyan,
                onTap: () => _open(context, const BestiaryScreen())),
            _HubTile(
                icon: Icons.settings_rounded,
                label: 'Config',
                color: AppColors.textSecondary,
                onTap: () => _open(context, const SettingsScreen())),
            _HubTile(
                icon: Icons.support_agent_rounded,
                label: 'Support',
                color: AppColors.orange,
                onTap: () => _open(
                    context,
                    const WebViewScreen(
                        title: 'Support',
                        url: AppLinks.support,
                        whiteBackground: false))),
          ],
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.bgPanel.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 12),
          ],
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 17)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: color.withValues(alpha: 0.85),
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8)),
        ]),
      ),
    );
  }
}

class _PlayButton extends StatefulWidget {
  const _PlayButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _beat =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
        ..repeat(reverse: true);
  double _scale = 1.0;

  @override
  void dispose() {
    _beat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _beat,
      builder: (_, __) {
        final glow = 0.30 + _beat.value * 0.30;
        return GestureDetector(
          onTapDown: (_) => setState(() => _scale = 0.97),
          onTapUp: (_) => setState(() => _scale = 1.0),
          onTapCancel: () => setState(() => _scale = 1.0),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 80),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D2540), Color(0xFF091628)],
                ),
                border: Border.all(color: AppColors.cyan.withValues(alpha: 0.8), width: 1.5),
                boxShadow: [
                  BoxShadow(color: AppColors.cyan.withValues(alpha: glow), blurRadius: 26, spreadRadius: 2),
                ],
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.rocket_launch_rounded, color: AppColors.cyan, size: 26),
                const SizedBox(width: 14),
                Text('PLAY',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 4,
                        shadows: [Shadow(color: AppColors.cyan.withValues(alpha: 0.9), blurRadius: 14)])),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.32)),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10)],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  color: color.withValues(alpha: 0.95),
                  fontSize: 11,
                  fontWeight: FontWeight.w800)),
        ]),
      ),
    );
  }
}
