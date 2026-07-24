import 'dart:math';
import 'data/event_data.dart';
import 'flux_game.dart';

/// Periodically triggers one of the six global random events described in
/// the design document, and reverts its temporary modifiers afterwards.
class EventManager {
  EventManager(this.game);

  final FluxGame game;
  final Random _rng = Random();

  double _timeUntilNext = 22;
  GameEventType? active;
  double _remaining = 0;

  void update(double dt) {
    if (game.runState.gameOver || game.runState.victory) return;

    if (active != null) {
      _remaining -= dt;
      if (_remaining <= 0) {
        _endEvent();
      }
      return;
    }

    _timeUntilNext -= dt;
    if (_timeUntilNext <= 0) {
      _startEvent();
    }
  }

  void _startEvent() {
    final values = GameEventType.values;
    final type = values[_rng.nextInt(values.length)];
    final def = kEventDefs[type]!;
    active = type;
    _remaining = def.duration;
    game.runState.activeEventName = def.name;
    game.onEventStarted(def);

    switch (type) {
      case GameEventType.gravityShift:
        // handled visually / via slight random drift already applied in
        // enemy/sphere update through eventSpeedMult jitter.
        break;
      case GameEventType.blackHole:
        game.runState.blackHoleActive = true;
        break;
      case GameEventType.crystalRain:
        game.spawnCrystalRain();
        break;
      case GameEventType.solarStorm:
        game.runState.eventSpeedMult = 1.6;
        break;
      case GameEventType.overcharge:
        game.runState.eventDamageMult = 1.8;
        break;
      case GameEventType.virusBloom:
        game.runState.eventVirusWeightMult = 3.0;
        break;
    }
    game.runState.pushHudUpdate();
  }

  void _endEvent() {
    final def = active != null ? kEventDefs[active!] : null;
    active = null;
    game.runState.activeEventName = null;
    game.runState.blackHoleActive = false;
    game.runState.eventSpeedMult = 1.0;
    game.runState.eventDamageMult = 1.0;
    game.runState.eventVirusWeightMult = 1.0;
    _timeUntilNext = 24 + _rng.nextDouble() * 14;
    if (def?.type == GameEventType.blackHole) {
      game.onBlackHoleSurvived();
    }
    game.runState.pushHudUpdate();
  }
}
