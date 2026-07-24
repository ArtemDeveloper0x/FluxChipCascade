import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../game/data/event_data.dart';
import '../game/data/level_data.dart';
import '../game/flux_game.dart';
import '../widgets/game_overlays.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.level, required this.mutationId});

  final LevelConfig level;
  final String mutationId;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

enum _OverlayMode { none, upgrade, pause, gameOver, victory }

class _GameScreenState extends State<GameScreen> {
  late FluxGame _game;
  late LevelConfig _level;
  _OverlayMode _mode = _OverlayMode.none;
  List<int> _upgradeIndexes = [];
  GameEventDef? _eventBanner;

  late final FluxGameCallbacks _callbacks;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _level = widget.level;
    _callbacks = FluxGameCallbacks(
      onUpgradeChoice: (indexes) {
        setState(() {
          _upgradeIndexes = indexes;
          _mode = _OverlayMode.upgrade;
        });
      },
      onGameOver: () => setState(() => _mode = _OverlayMode.gameOver),
      onVictory: () => setState(() => _mode = _OverlayMode.victory),
      onEventBanner: (event) {
        setState(() => _eventBanner = event);
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _eventBanner == event) {
            setState(() => _eventBanner = null);
          }
        });
      },
    );
    _game = _buildGame();
  }

  FluxGame _buildGame() => FluxGame(
        level: _level,
        mutationId: widget.mutationId,
        callbacks: _callbacks,
      );

  void _restart() {
    setState(() {
      _mode = _OverlayMode.none;
      _eventBanner = null;
      _game = _buildGame();
    });
  }

  /// Advance to the next level in-place (no navigation) so progression is
  /// reliable on every level.
  void _continueToNext() {
    setState(() {
      _mode = _OverlayMode.none;
      _eventBanner = null;
      _level = levelConfigFor(_level.level + 1);
      _game = _buildGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_mode == _OverlayMode.none) {
          _game.pauseEngine();
          setState(() => _mode = _OverlayMode.pause);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgDeep,
        body: Stack(
          children: [
            // ObjectKey on the current game instance forces Flutter to fully
            // unmount the old GameWidget (which disposes the old FluxGame) when
            // we swap games for a restart or a level transition. Without this
            // the previous game's resources could linger and pile up between
            // levels, causing the freezes seen after the first win.
            Positioned.fill(child: GameWidget(key: ObjectKey(_game), game: _game)),
            if (_eventBanner != null) EventBanner(event: _eventBanner!),
            GameHud(
              runState: _game.runState,
              onPause: () {
                if (_mode != _OverlayMode.none) return;
                _game.pauseEngine();
                setState(() => _mode = _OverlayMode.pause);
              },
            ),
            if (_mode == _OverlayMode.upgrade)
              UpgradeChoiceOverlay(
                indexes: _upgradeIndexes,
                onChosen: (idx) {
                  _game.applyChosenUpgrade(idx);
                  setState(() => _mode = _OverlayMode.none);
                },
              ),
            if (_mode == _OverlayMode.pause)
              PauseOverlay(
                onResume: () {
                  _game.resumeEngine();
                  setState(() => _mode = _OverlayMode.none);
                },
                onRestart: _restart,
                onQuit: () => Navigator.of(context).popUntil((r) => r.isFirst),
              ),
            if (_mode == _OverlayMode.gameOver || _mode == _OverlayMode.victory)
              EndRunOverlay(
                victory: _mode == _OverlayMode.victory,
                runState: _game.runState,
                crystalReward: _mode == _OverlayMode.victory
                    ? _level.crystalReward
                    : _level.crystalReward ~/ 3,
                onContinue: _continueToNext,
                onRetry: _restart,
                onMenu: () => Navigator.of(context).popUntil((r) => r.isFirst),
              ),
          ],
        ),
      ),
    );
  }
}
