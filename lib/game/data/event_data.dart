import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Global random events. [effectColumn] indexes into
/// Effects_of_random_events_asset.webp (6 columns x 3 rows).
enum GameEventType {
  gravityShift,
  blackHole,
  crystalRain,
  solarStorm,
  overcharge,
  virusBloom,
}

class GameEventDef {
  final GameEventType type;
  final String name;
  final String description;
  final int effectColumn;
  final Color color;
  final double duration;
  final String soundAsset;

  const GameEventDef({
    required this.type,
    required this.name,
    required this.description,
    required this.effectColumn,
    required this.color,
    required this.duration,
    required this.soundAsset,
  });
}

const Map<GameEventType, GameEventDef> kEventDefs = {
  GameEventType.gravityShift: GameEventDef(
    type: GameEventType.gravityShift,
    name: 'Gravity Shift',
    description: 'Gravity and movement behavior are altered.',
    effectColumn: 0,
    color: AppColors.purple,
    duration: 9,
    soundAsset: 'gravity_shift_asset.mp3',
  ),
  GameEventType.blackHole: GameEventDef(
    type: GameEventType.blackHole,
    name: 'Black Hole',
    description: 'A gravity anomaly pulls everything toward the center.',
    effectColumn: 1,
    color: AppColors.blue,
    duration: 8,
    soundAsset: 'Black_Hole_asset.mp3',
  ),
  GameEventType.crystalRain: GameEventDef(
    type: GameEventType.crystalRain,
    name: 'Crystal Rain',
    description: 'A large number of neutral spheres appear.',
    effectColumn: 2,
    color: AppColors.cyan,
    duration: 10,
    soundAsset: 'Crystal_Rain_asset.mp3',
  ),
  GameEventType.solarStorm: GameEventDef(
    type: GameEventType.solarStorm,
    name: 'Solar Storm',
    description: 'All objects move significantly faster.',
    effectColumn: 3,
    color: AppColors.orange,
    duration: 8,
    soundAsset: 'Solar_Storm_asset.mp3',
  ),
  GameEventType.overcharge: GameEventDef(
    type: GameEventType.overcharge,
    name: 'Overcharge',
    description: 'The orbit deals significantly more damage.',
    effectColumn: 4,
    color: AppColors.magenta,
    duration: 8,
    soundAsset: 'overload_asset.mp3',
  ),
  GameEventType.virusBloom: GameEventDef(
    type: GameEventType.virusBloom,
    name: 'Virus Bloom',
    description: 'The number of infected enemies rises sharply.',
    effectColumn: 5,
    color: AppColors.green,
    duration: 10,
    soundAsset: 'Turning_a_satellite_into_an_enemy_asset.mp3',
  ),
};
