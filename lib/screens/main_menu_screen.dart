import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../core/audio_manager.dart';
import '../core/constants.dart';
import '../core/storage_service.dart';
import '../core/theme.dart';
import 'achievements_screen.dart';
import 'bestiary_screen.dart';
import 'daily_quests_screen.dart';
import 'hangar_screen.dart';
import 'level_select_screen.dart';
import 'settings_screen.dart';
import 'webview_screen.dart';

// ─── palette ────────────────────────────────────────────────────────────────
const _kCyan   = Color(0xFF29E8FF);
const _kGold   = Color(0xFFFFD84D);
const _kBlue   = Color(0xFF1A2E6E);
const _kBg     = Color(0xFF050914);

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});
  @override State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin {

  // ambient loop – powers the orbit deco + scan line
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(seconds: 16))
        ..repeat();

  // entrance – staggered fade-in once per visit
  late final AnimationController _intro =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
        ..forward();

  // play-button heartbeat
  late final AnimationController _beat =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
        ..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    AudioManager.I.playMenuMusic();
  }

  @override
  void dispose() {
    _loop.dispose();
    _intro.dispose();
    _beat.dispose();
    super.dispose();
  }

  void _sfx() => AudioManager.I.sfx(Sounds.buttonClick);

  @override
  Widget build(BuildContext context) {
    final store = StorageService.I;
    final size  = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(fit: StackFit.expand, children: [

        // ── 1. Atmospheric background ──────────────────────────────────────
        _BgLayer(controller: _loop),

        // ── 2. Corner chrome decoration ───────────────────────────────────
        Positioned.fill(child: IgnorePointer(child: CustomPaint(
          painter: _ChromePainter(anim: _loop),
        ))),

        // ── 3. Content ────────────────────────────────────────────────────
        SafeArea(
          child: Column(children: [

            // stats strip
            _Enter(_intro, 0.0, 0.4, child: _StatsStrip(
              crystals: store.crystals,
              bestWave: store.bestWaveEver,
            )),

            const Spacer(),

            // logo + orbit ring
            _Enter(_intro, 0.05, 0.55, child: _LogoSection(loop: _loop, size: size)),

            const Spacer(flex: 2),

            // PLAY
            _Enter(_intro, 0.2, 0.7, child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: _PlayButton(beat: _beat, onTap: () {
                _sfx();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const LevelSelectScreen()));
              }),
            )),

            const SizedBox(height: 20),

            // secondary row
            _Enter(_intro, 0.3, 0.85, child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(children: [
                _SecBtn(icon: Icons.workspaces_rounded, label: 'HANGAR',
                    color: AppColors.purple, onTap: () { _sfx();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const HangarScreen())); }),
                const SizedBox(width: 10),
                _SecBtn(icon: Icons.checklist_rounded, label: 'QUESTS',
                    color: AppColors.green, onTap: () { _sfx();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const DailyQuestsScreen())); }),
                const SizedBox(width: 10),
                _SecBtn(icon: Icons.settings_rounded, label: 'CONFIG',
                    color: AppColors.textSecondary, onTap: () { _sfx();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const SettingsScreen())); }),
                const SizedBox(width: 10),
                _SecBtn(icon: Icons.support_agent_rounded, label: 'HELP',
                    color: AppColors.orange, onTap: () { _sfx();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const WebViewScreen(
                      title: 'Support',
                      url: AppLinks.support,
                      whiteBackground: false,
                    ))); }),
              ]),
            )),

            const SizedBox(height: 10),

            // secondary row 2 – codex + milestones
            _Enter(_intro, 0.35, 0.9, child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(children: [
                _SecBtn(icon: Icons.menu_book_rounded, label: 'BESTIARY',
                    color: AppColors.cyan, onTap: () { _sfx();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const BestiaryScreen())); }),
                const SizedBox(width: 10),
                _SecBtn(icon: Icons.military_tech_rounded, label: 'MEDALS',
                    color: AppColors.gold, onTap: () { _sfx();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const AchievementsScreen())); }),
              ]),
            )),

            const SizedBox(height: 22),

            // footer
            _Enter(_intro, 0.45, 1.0, child: GestureDetector(
              onTap: () { _sfx();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const WebViewScreen(
                    title: 'Privacy Policy',
                    url: AppLinks.privacyPolicy,
                    whiteBackground: true,
                  )));
              },
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.lock_outline_rounded, size: 11, color: Color(0xFF4A5B8A)),
                const SizedBox(width: 5),
                Text('Privacy Policy',
                    style: TextStyle(
                        fontSize: 12, color: const Color(0xFF4A5B8A),
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFF4A5B8A).withValues(alpha: 0.6))),
              ]),
            )),
            const SizedBox(height: 10),
          ]),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BG LAYER – bg_location_1 image, zoomed slowly, darkened, radial vignette
// ═══════════════════════════════════════════════════════════════════════════
class _BgLayer extends StatelessWidget {
  const _BgLayer({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final zoom = 1.05 + 0.04 * sin(controller.value * 2 * pi);
        return Stack(fit: StackFit.expand, children: [
          Opacity(
            opacity: 0.28,
            child: Transform.scale(scale: zoom, child:
              Image.asset(Assets.bgLocation(0), fit: BoxFit.cover)),
          ),
          // heavy radial vignette so text/buttons are always legible
          DecoratedBox(decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.2),
              radius: 1.2,
              colors: [
                _kBg.withValues(alpha: 0.0),
                _kBg.withValues(alpha: 0.65),
                _kBg.withValues(alpha: 0.96),
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          )),
          // top bar fade
          Align(alignment: Alignment.topCenter,
            child: Container(height: 120,
              decoration: BoxDecoration(gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [_kBg, _kBg.withValues(alpha: 0.0)])))),
          // bottom fade
          Align(alignment: Alignment.bottomCenter,
            child: Container(height: 200,
              decoration: BoxDecoration(gradient: LinearGradient(
                begin: Alignment.bottomCenter, end: Alignment.topCenter,
                colors: [_kBg, _kBg.withValues(alpha: 0.0)])))),
        ]);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CHROME PAINTER – corner brackets + faint hex grid + slow scan line
// ═══════════════════════════════════════════════════════════════════════════
class _ChromePainter extends CustomPainter {
  _ChromePainter({required this.anim}) : super(repaint: anim);
  final Animation<double> anim;

  @override
  void paint(Canvas canvas, Size size) {
    final t  = anim.value;
    final p1 = Paint()
      ..color = _kCyan.withValues(alpha: 0.18)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // corner brackets (4 corners, same L-shape)
    const arm = 28.0;
    const pad = 18.0;
    for (final corner in [
      [pad, pad, 1.0, 1.0],    // TL
      [size.width - pad, pad, -1.0, 1.0],  // TR
      [pad, size.height - pad, 1.0, -1.0], // BL
      [size.width - pad, size.height - pad, -1.0, -1.0], // BR
    ]) {
      final x = corner[0]; final y = corner[1];
      final sx = corner[2]; final sy = corner[3];
      canvas.drawLine(Offset(x, y), Offset(x + sx * arm, y), p1);
      canvas.drawLine(Offset(x, y), Offset(x, y + sy * arm), p1);
    }

    // animated scan line
    final scanY = size.height * ((t * 1.4) % 1.0);
    final scanPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, scanY - 60), Offset(0, scanY + 60),
        [Colors.transparent, _kCyan.withValues(alpha: 0.08), Colors.transparent],
        [0.0, 0.5, 1.0],   // colorStops required when colors.length != 2
      );
    canvas.drawRect(Rect.fromLTWH(0, scanY - 60, size.width, 120), scanPaint);
  }

  @override bool shouldRepaint(_ChromePainter old) => true;
}

// ═══════════════════════════════════════════════════════════════════════════
// STATS STRIP – top edge, crystal count + best wave
// ═══════════════════════════════════════════════════════════════════════════
class _StatsStrip extends StatelessWidget {
  const _StatsStrip({required this.crystals, required this.bestWave});
  final int crystals;
  final int bestWave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
      child: Row(children: [
        _Stat(icon: Icons.diamond_rounded, value: crystals,   color: _kGold),
        const Spacer(),
        _Stat(icon: Icons.emoji_events_rounded, value: bestWave, color: _kCyan,
            label: 'BEST'),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.color, this.label});
  final IconData icon;
  final int value;
  final Color color;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: _kBg.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.28), width: 1),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 12)],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 6),
        if (label != null) ...[
          Text(label!, style: TextStyle(
              color: color.withValues(alpha: 0.7), fontSize: 9,
              fontWeight: FontWeight.w700, letterSpacing: 1.4)),
          const SizedBox(width: 5),
        ],
        Text('$value', style: const TextStyle(
            color: AppColors.textPrimary, fontSize: 14,
            fontWeight: FontWeight.w900)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LOGO SECTION – game_name asset + animated orbital ring
// ═══════════════════════════════════════════════════════════════════════════
class _LogoSection extends StatelessWidget {
  const _LogoSection({required this.loop, required this.size});
  final AnimationController loop;
  final Size size;

  static const _orbs = [
    (r: 118.0, speed: 0.60, phase: 0.0,  color: _kCyan,             sz: 10.0),
    (r: 130.0, speed: -0.40, phase: 2.1, color: AppColors.magenta,  sz: 8.0),
    (r: 122.0, speed: 0.90, phase: 1.0,  color: AppColors.gold,     sz: 7.0),
    (r: 112.0, speed: -0.70, phase: 3.5, color: AppColors.green,    sz: 6.0),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 290,
      height: 290,
      child: AnimatedBuilder(
        animation: loop,
        builder: (_, __) {
          final t = loop.value * 2 * pi;
          return Stack(alignment: Alignment.center, children: [

            // dashed orbit ring
            CustomPaint(size: const Size(290, 290),
                painter: _RingPainter(t: t)),

            // satellite dots
            for (final o in _orbs) ...[
              _OrbDot(
                angle: t * o.speed + o.phase,
                radius: o.r,
                color: o.color,
                sz: o.sz,
              ),
            ],

            // logo
            Image.asset(Assets.gameName, width: 230),
          ]);
        },
      ),
    );
  }
}

class _OrbDot extends StatelessWidget {
  const _OrbDot({required this.angle, required this.radius,
    required this.color, required this.sz});
  final double angle, radius, sz;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(cos(angle) * radius, sin(angle) * radius * 0.55),
      child: Container(
        width: sz, height: sz,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color,
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.95),
              blurRadius: 10, spreadRadius: 2)]),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.t});
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = _kCyan.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // draw an ellipse as a series of dashed arcs
    const steps = 64;
    for (int i = 0; i < steps; i++) {
      if (i % 3 == 0) continue; // gap every 3rd segment
      final a0 = i * 2 * pi / steps + t * 0.25;
      final a1 = a0 + 2 * pi / steps * 0.7;
      final p0 = center + Offset(cos(a0) * 118, sin(a0) * 65);
      final p1 = center + Offset(cos(a1) * 118, sin(a1) * 65);
      canvas.drawLine(p0, p1, paint);
    }
  }

  @override bool shouldRepaint(_RingPainter o) => o.t != t;
}

// ═══════════════════════════════════════════════════════════════════════════
// PLAY BUTTON – wide energy cell, breathing glow
// ═══════════════════════════════════════════════════════════════════════════
class _PlayButton extends StatefulWidget {
  const _PlayButton({required this.beat, required this.onTap});
  final AnimationController beat;
  final VoidCallback onTap;

  @override State<_PlayButton> createState() => _PlayButtonState();
}
class _PlayButtonState extends State<_PlayButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.beat,
      builder: (_, __) {
        final glow = 0.28 + widget.beat.value * 0.30;
        return GestureDetector(
          onTapDown:  (_) => setState(() => _scale = 0.97),
          onTapUp:    (_) => setState(() => _scale = 1.0),
          onTapCancel: () => setState(() => _scale = 1.0),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 80),
            child: Container(
              height: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFF0D2540), Color(0xFF091628)],
                ),
                border: Border.all(color: _kCyan.withValues(alpha: 0.8), width: 1.5),
                boxShadow: [
                  BoxShadow(color: _kCyan.withValues(alpha: glow),
                      blurRadius: 26, spreadRadius: 2),
                  BoxShadow(color: _kCyan.withValues(alpha: glow * 0.5),
                      blurRadius: 60, spreadRadius: 4),
                ],
              ),
              child: Stack(alignment: Alignment.center, children: [

                // interior light bleed
                Align(alignment: const Alignment(0, -1.5),
                  child: Container(height: 28, width: 180,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(colors: [
                        _kCyan.withValues(alpha: glow * 0.25), Colors.transparent]),
                      borderRadius: BorderRadius.circular(100),
                    ))),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.rocket_launch_rounded, color: _kCyan, size: 26),
                  const SizedBox(width: 14),
                  Text('PLAY',
                      style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w900,
                        color: Colors.white, letterSpacing: 4,
                        shadows: [
                          Shadow(color: _kCyan.withValues(alpha: 0.9), blurRadius: 14),
                        ],
                      )),
                  const SizedBox(width: 14),
                  Icon(Icons.chevron_right_rounded,
                      color: _kCyan.withValues(alpha: 0.7), size: 22),
                ]),
              ]),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECONDARY BUTTON – compact icon + label tile
// ═══════════════════════════════════════════════════════════════════════════
class _SecBtn extends StatefulWidget {
  const _SecBtn({required this.icon, required this.label,
    required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override State<_SecBtn> createState() => _SecBtnState();
}
class _SecBtnState extends State<_SecBtn> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown:  (_) => setState(() => _scale = 0.94),
        onTapUp:    (_) => setState(() => _scale = 1.0),
        onTapCancel: () => setState(() => _scale = 1.0),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 80),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: widget.color.withValues(alpha: 0.08),
              border: Border.all(
                  color: widget.color.withValues(alpha: 0.35), width: 1),
              boxShadow: [BoxShadow(
                  color: widget.color.withValues(alpha: 0.12), blurRadius: 10)],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(widget.icon, color: widget.color, size: 20),
              const SizedBox(height: 5),
              Text(widget.label,
                  style: TextStyle(
                      color: widget.color.withValues(alpha: 0.9),
                      fontSize: 9.5, fontWeight: FontWeight.w800,
                      letterSpacing: 1.1)),
            ]),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ENTRANCE FADE+SLIDE helper
// ═══════════════════════════════════════════════════════════════════════════
class _Enter extends StatelessWidget {
  const _Enter(this.ctrl, this.from, this.to, {required this.child});
  final AnimationController ctrl;
  final double from, to;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(
        parent: ctrl, curve: Interval(from, to, curve: Curves.easeOutCubic));
    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) => Opacity(
        opacity: anim.value.clamp(0.0, 1.0),
        child: Transform.translate(
            offset: Offset(0, (1 - anim.value) * 18), child: child),
      ),
      child: child,
    );
  }
}
