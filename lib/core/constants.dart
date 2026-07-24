/// Central place for asset paths, app-wide constants and simple config
/// values used across Flux Chip Cascade.
library;

class Assets {
  Assets._();

  static const String gameName = 'assets/Game_Name.webp';
  static const String icon = 'assets/Icon.png';
  static const String verticalLoading = 'assets/Vertical_Loading_Screen.webp';
  static const String horizontalLoading =
      'assets/Horizontal_Loading_Screen.webp';

  static const String enemies = 'assets/enemyes_asset.webp';
  static const String miniBosses = 'assets/mini_bosses_asset.webp';
  static const String mainSpheres = 'assets/main_spheres_asset.webp';
  static const String neutralSpheres =
      'assets/Neutral_energy_spheres_asset.webp';
  static const String energyCrystals =
      'assets/Energy_Crystals_Currency_asset.webp';
  static const String specialOrbitUpgrades =
      'assets/Special_Orbit_Upgrades_asset.webp';
  static const String destructionEffects =
      'assets/Effects_of_destruction_asset.webp';
  static const String randomEventEffects =
      'assets/Effects_of_random_events_asset.webp';
  static const String orbitEnergyEffects =
      'assets/Energy_effects_of_the_orbit_asset.webp';
  static const String movementTraces = 'assets/Traces_of_movement_asset.webp';
  static const String decorativeEffects =
      'assets/decorative_elements_effects_asset.webp';

  static String bgLocation(int tier) {
    final n = (tier.clamp(0, 9)) + 1;
    return 'assets/bg_location_${n}_asset.webp';
  }
}

class Sounds {
  Sounds._();

  static const String attractionSpheres = 'attraction_spheres_asset.mp3';
  static const String blackHole = 'Black_Hole_asset.mp3';
  static const String bossArrival = 'boss_arrival_asset.mp3';
  static const String buttonClick = 'button_click_asset.mp3';
  static const String buyUpgrade = 'buy_upgrade_asset.mp3';
  static const String collectiblePickup = 'collectible_pickup_asset.mp3';
  static const String crystalRain = 'Crystal_Rain_asset.mp3';
  static const String enemyDefeat = 'enemy_defeat_asset.mp3';
  static const String energyImpact = 'energy_impact_asset.mp3';
  static const String errorNotification = 'error_notification_asset.mp3';
  static const String electromagneticPulse =
      'expanding_electromagnetic_pulse_asset.mp3';
  static const String gravityShift = 'gravity_shift_asset.mp3';
  static const String hoveringLoop = 'hovering_loop_asset.mp3';
  static const String levelUp = 'level_up_asset.mp3';
  static const String electricalLoop =
      'Looping_electrical_energy_connection_asset.mp3';
  static const String orbitalLoop = 'Looping_orbital_energy_asset.mp3';
  static const String menuMusicLoop = 'loop_menu_music_asset.mp3';
  static const String overload = 'overload_asset.mp3';
  static const String plasmaExplosion = 'plasma_explosion_asset.mp3';
  static const String projectileReflection =
      'Projectile_reflection_asset.mp3';
  static const String crystalPickupBurst =
      'Rapid_sequence_of_bright_crystal_pickup_asset.mp3';
  static const String rewardChestOpening = 'reward_chest_opening_asset.mp3';
  static const String rewardUpgrade = 'Reward_upgrade_asset.mp3';
  static const String satelliteInfection = 'Satellite_infection_asset.mp3';
  static const String solarStorm = 'Solar_Storm_asset.mp3';
  static const String sphereBreakingApart = 'sphere_breaking_apart_asset.mp3';
  static const String sphereJoiningOrbit = 'sphere_joining_an_orbit_asset.mp3';
  static const String satelliteTurnsHostile =
      'Turning_a_satellite_into_an_enemy_asset.mp3';
  static const String winVictoryBoss = 'win_victory_boss_asset.mp3';
}

class AppLinks {
  AppLinks._();

  static const String privacyPolicy =
      'https://fluxchipcascade.com/privacy-policy.html';
  static const String support = 'https://fluxchipcascade.com/support.html';
}

class AppInfo {
  AppInfo._();

  static const String name = 'Flux Chip Cascade';
  static const String bundleId = 'com.fluxchip.cascadegame';
  static const int totalLevels = 40;
}
