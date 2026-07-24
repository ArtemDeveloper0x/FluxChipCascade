import 'package:flame_audio/flame_audio.dart';
import 'constants.dart';
import 'storage_service.dart';

/// Thin wrapper around [FlameAudio] that respects the user's sound settings.
class AudioManager {
  AudioManager._();
  static final AudioManager I = AudioManager._();

  bool _initialized = false;

  /// High-frequency sfx are pre-pooled: pools reuse a small fixed set of audio
  /// players instead of creating a new `AudioPlayer` on every call. Without
  /// this, hundreds of players accumulate over a run (enemy deaths, impacts,
  /// pickups), flooding the media stack, blocking the main thread and freezing
  /// the game between levels.
  final Map<String, AudioPool> _pools = {};

  static const List<String> _pooledSounds = [
    Sounds.enemyDefeat,
    Sounds.energyImpact,
    Sounds.collectiblePickup,
    Sounds.sphereJoiningOrbit,
    Sounds.sphereBreakingApart,
    Sounds.projectileReflection,
    Sounds.plasmaExplosion,
    Sounds.buttonClick,
  ];

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    FlameAudio.updatePrefix('sounds/');
    await FlameAudio.audioCache.loadAll([
      Sounds.buttonClick,
      Sounds.buyUpgrade,
      Sounds.collectiblePickup,
      Sounds.crystalRain,
      Sounds.enemyDefeat,
      Sounds.energyImpact,
      Sounds.errorNotification,
      Sounds.electromagneticPulse,
      Sounds.gravityShift,
      Sounds.levelUp,
      Sounds.overload,
      Sounds.plasmaExplosion,
      Sounds.projectileReflection,
      Sounds.crystalPickupBurst,
      Sounds.rewardChestOpening,
      Sounds.rewardUpgrade,
      Sounds.satelliteInfection,
      Sounds.solarStorm,
      Sounds.sphereBreakingApart,
      Sounds.sphereJoiningOrbit,
      Sounds.satelliteTurnsHostile,
      Sounds.winVictoryBoss,
      Sounds.blackHole,
      Sounds.bossArrival,
    ]);
    for (final s in _pooledSounds) {
      try {
        _pools[s] = await FlameAudio.createPool(s, maxPlayers: 4);
      } catch (_) {
        // If pooling fails for any reason we fall back to FlameAudio.play.
      }
    }
  }

  // Throttling to prevent audio flooding: when many entities die/fire in the
  // same instant (dense waves, boss death), spawning a new AudioTrack for each
  // sound stalls the main thread and can freeze the game (ANR). We cap both the
  // per-sound rate and the global sound rate.
  final Map<String, int> _lastPlayedMs = {};
  int _lastAnySfxMs = 0;
  static const int _perSoundMinGapMs = 90;
  static const int _globalMinGapMs = 24;

  void sfx(String asset, {double volume = 1.0}) {
    if (!StorageService.I.sfxEnabled) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastAnySfxMs < _globalMinGapMs) return;
    final last = _lastPlayedMs[asset] ?? 0;
    if (now - last < _perSoundMinGapMs) return;
    _lastPlayedMs[asset] = now;
    _lastAnySfxMs = now;
    final pool = _pools[asset];
    if (pool != null) {
      // Fire and forget: pool reuses up to maxPlayers audio players.
      pool.start(volume: volume);
    } else {
      FlameAudio.play(asset, volume: volume);
    }
  }

  // Music is disabled game-wide: the short looping bgm clips were producing
  // heavy MediaPlayer traffic (seek spam) that contributed to main-thread
  // stalls. These are kept as no-ops so any existing call sites still compile.
  Future<void> playMenuMusic() async {}
  Future<void> playGameplayLoop() async {}

  void stopMusic() {
    // Safety: if any previous run had started bgm, silence it.
    FlameAudio.bgm.stop();
  }

  void setMusicEnabled(bool enabled) {}
}
