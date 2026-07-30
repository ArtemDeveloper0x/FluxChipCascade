import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/audio_manager.dart';
import '../core/constants.dart';
import '../core/storage_service.dart';
import '../core/theme.dart';
import 'main_shell.dart';

/// First screen shown on app start. Free to rotate (art is provided for both
/// orientations); the horizontal progress bar only reaches 100% right before
/// the actual transition into the (portrait-locked) app.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  double _progress = 0;
  int _dotCount = 0;
  Timer? _dotTimer;
  bool _launching = false;

  static const double _capBeforeReady = 0.93;

  @override
  void initState() {
    super.initState();
    // Allow the device to rotate freely while the loading screen is shown.
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _dotTimer = Timer.periodic(const Duration(milliseconds: 420), (_) {
      if (!mounted) return;
      setState(() => _dotCount = (_dotCount + 1) % 4);
    });
    _runLoadSequence();
  }

  Future<void> _setProgress(double v) async {
    if (!mounted) return;
    setState(() => _progress = v.clamp(0.0, _capBeforeReady));
    await Future.delayed(const Duration(milliseconds: 60));
  }

  Future<void> _runLoadSequence() async {
    final stopwatch = Stopwatch()..start();

    // Warm up the loading screen's own background art first — it's a large
    // image, and without precaching it the "Loading" text/bar paint on the
    // very first frame while the artwork is still decoding, showing a bare
    // dark screen for a moment before the picture pops in.
    await _precache(Assets.verticalLoading);
    await _precache(Assets.horizontalLoading);

    await _setProgress(0.05);
    await StorageService.init();

    await _setProgress(0.22);
    await AudioManager.I.init();

    await _setProgress(0.45);
    await _precache(Assets.gameName);
    await _setProgress(0.58);
    await _precache(Assets.icon);

    await _setProgress(0.72);
    for (int i = 0; i < 10; i += 3) {
      await _precache(Assets.bgLocation(i));
    }

    await _setProgress(0.86);
    await _precache(Assets.enemies);
    await _precache(Assets.mainSpheres);
    await _precache(Assets.miniBosses);

    await _setProgress(_capBeforeReady);

    // Ensure a pleasant minimum loading time so the animation reads clearly.
    const minDuration = Duration(milliseconds: 2600);
    final elapsed = stopwatch.elapsed;
    if (elapsed < minDuration) {
      await Future.delayed(minDuration - elapsed);
    }

    if (!mounted) return;
    setState(() => _launching = true);

    // Final fill to 100% happens only now, right before the actual launch.
    for (double v = _progress; v <= 1.0; v += 0.04) {
      if (!mounted) return;
      setState(() => _progress = v);
      await Future.delayed(const Duration(milliseconds: 16));
    }
    if (!mounted) return;
    setState(() => _progress = 1.0);
    await Future.delayed(const Duration(milliseconds: 260));

    // Lock the real game experience to portrait only, as required.
    await SystemChrome.setPreferredOrientations(
        const [DeviceOrientation.portraitUp]);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  Future<void> _precache(String asset) async {
    try {
      await precacheImage(AssetImage(asset), context);
    } catch (_) {
      // Non-fatal: continue loading even if a particular asset fails.
    }
  }

  @override
  void dispose() {
    _dotTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: OrientationBuilder(
        builder: (context, orientation) {
          final asset = orientation == Orientation.portrait
              ? Assets.verticalLoading
              : Assets.horizontalLoading;
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                asset,
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  // Fade the art in once it finishes decoding instead of
                  // popping in abruptly over the plain dark background.
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
              ),
              Align(
                alignment: const Alignment(0, 0.62),
                child: _LoadingBar(progress: _progress, dotCount: _dotCount, launching: _launching),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar({required this.progress, required this.dotCount, required this.launching});

  final double progress;
  final int dotCount;
  final bool launching;

  @override
  Widget build(BuildContext context) {
    final dots = '.' * dotCount;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 220,
            child: Text(
              'Loading$dots',
              textAlign: TextAlign.center,
              style: AppTheme.neonTitle(
                  size: 20, color: launching ? AppColors.gold : AppColors.cyan),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0x552C3B77),
                border: Border.all(color: AppColors.panelBorder, width: 1),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        AppColors.blue,
                        AppColors.cyan,
                      ]),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyan.withValues(alpha: 0.7),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text('${(progress * 100).clamp(0, 100).toInt()}%',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
