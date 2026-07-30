import 'dart:math';
import 'package:flutter/material.dart';
import '../core/audio_manager.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import 'tabs/codex_tab.dart';
import 'tabs/home_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/shop_tab.dart';
import 'tabs/stats_tab.dart';

/// Root hub of the app after loading. Hosts the five primary screens behind a
/// persistent neon bottom navigation bar.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _index = 0;

  late final AnimationController _bg =
      AnimationController(vsync: this, duration: const Duration(seconds: 20))
        ..repeat();

  @override
  void initState() {
    super.initState();
    AudioManager.I.playMenuMusic();
  }

  @override
  void dispose() {
    _bg.dispose();
    super.dispose();
  }

  /// Called by tabs whenever persisted data changes (e.g. a purchase) so
  /// sibling tabs (crystal counters, stats) refresh.
  void _refresh() => setState(() {});

  static const _tabs = <_TabDef>[
    _TabDef('Home', Icons.rocket_launch_rounded, AppColors.cyan),
    _TabDef('Shop', Icons.science_rounded, AppColors.gold),
    _TabDef('Stats', Icons.insights_rounded, AppColors.green),
    _TabDef('Codex', Icons.menu_book_rounded, AppColors.magenta),
    _TabDef('Pilot', Icons.person_rounded, AppColors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _ShellBackground(controller: _bg),
          SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _index,
              children: [
                HomeTab(onChanged: _refresh),
                ShopTab(onChanged: _refresh),
                const StatsTab(),
                const CodexTab(),
                ProfileTab(onChanged: _refresh),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _NeonNavBar(
        tabs: _tabs,
        index: _index,
        onTap: (i) {
          if (i == _index) return;
          AudioManager.I.sfx(Sounds.buttonClick);
          setState(() => _index = i);
        },
      ),
    );
  }
}

class _TabDef {
  const _TabDef(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

// ═══════════════════════════════════════════════════════════════════════════
// NEON BOTTOM NAV
// ═══════════════════════════════════════════════════════════════════════════
class _NeonNavBar extends StatelessWidget {
  const _NeonNavBar(
      {required this.tabs, required this.index, required this.onTap});
  final List<_TabDef> tabs;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: const Color(0xF00A0E1E),
        border: Border(
          top: BorderSide(
              color: AppColors.panelBorder.withValues(alpha: 0.7), width: 1),
        ),
        boxShadow: [
          BoxShadow(
              color: AppColors.cyan.withValues(alpha: 0.10),
              blurRadius: 22,
              offset: const Offset(0, -4)),
        ],
      ),
      child: SizedBox(
        height: 62,
        child: Row(
          children: [
            for (int i = 0; i < tabs.length; i++)
              Expanded(
                child: _NavItem(
                  def: tabs[i],
                  selected: i == index,
                  onTap: () => onTap(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem(
      {required this.def, required this.selected, required this.onTap});
  final _TabDef def;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = selected ? def.color : AppColors.textSecondary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // top indicator bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 3,
              width: selected ? 26 : 0,
              decoration: BoxDecoration(
                color: def.color,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(color: def.color.withValues(alpha: 0.9), blurRadius: 8),
                ],
              ),
            ),
            const SizedBox(height: 7),
            Icon(def.icon,
                color: c,
                size: selected ? 24 : 22,
                shadows: selected
                    ? [Shadow(color: def.color.withValues(alpha: 0.9), blurRadius: 12)]
                    : null),
            const SizedBox(height: 3),
            Text(
              def.label.toUpperCase(),
              style: TextStyle(
                  color: c,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED ANIMATED BACKGROUND
// ═══════════════════════════════════════════════════════════════════════════
class _ShellBackground extends StatelessWidget {
  const _ShellBackground({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final zoom = 1.06 + 0.04 * sin(controller.value * 2 * pi);
        return Stack(fit: StackFit.expand, children: [
          Opacity(
            opacity: 0.22,
            child: Transform.scale(
              scale: zoom,
              child: Image.asset(Assets.bgLocation(0), fit: BoxFit.cover),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.3),
                radius: 1.3,
                colors: [
                  AppColors.bgDeep.withValues(alpha: 0.15),
                  AppColors.bgDeep.withValues(alpha: 0.72),
                  AppColors.bgDeep.withValues(alpha: 0.97),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ]);
      },
    );
  }
}
