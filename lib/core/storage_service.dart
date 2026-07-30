import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple persistence layer wrapping [SharedPreferences] for meta progression:
/// currency, unlocked content, best scores and daily quests.
class StorageService {
  StorageService._(this._prefs);

  static StorageService? _instance;
  final SharedPreferences _prefs;

  static Future<StorageService> init() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = StorageService._(prefs);
    return _instance!;
  }

  static StorageService get I => _instance!;

  // --- Currency -------------------------------------------------------
  int get crystals => _prefs.getInt('crystals') ?? 0;
  Future<void> addCrystals(int amount) async {
    await _prefs.setInt('crystals', crystals + amount);
  }

  Future<bool> spendCrystals(int amount) async {
    if (crystals < amount) return false;
    await _prefs.setInt('crystals', crystals - amount);
    return true;
  }

  // --- Level progress ---------------------------------------------------
  int get maxUnlockedLevel => _prefs.getInt('maxUnlockedLevel') ?? 1;
  Future<void> unlockLevel(int level) async {
    if (level > maxUnlockedLevel) {
      await _prefs.setInt('maxUnlockedLevel', level);
    }
  }

  // --- Mutations ----------------------------------------------------
  static const defaultUnlockedMutations = [
    'gravitational_core',
    'overload',
    'heavy_core',
  ];

  List<String> get unlockedMutations {
    final raw = _prefs.getStringList('unlockedMutations');
    if (raw == null) return List.of(defaultUnlockedMutations);
    return raw;
  }

  Future<void> unlockMutation(String id) async {
    final list = unlockedMutations;
    if (!list.contains(id)) {
      list.add(id);
      await _prefs.setStringList('unlockedMutations', list);
    }
  }

  // --- Stats -------------------------------------------------------------
  int get bestWaveEver => _prefs.getInt('bestWave') ?? 0;
  Future<void> reportWave(int wave) async {
    if (wave > bestWaveEver) await _prefs.setInt('bestWave', wave);
  }

  int get totalKills => _prefs.getInt('totalKills') ?? 0;
  Future<void> addKills(int amount) async {
    await _prefs.setInt('totalKills', totalKills + amount);
  }

  int get totalRunsCompleted => _prefs.getInt('totalRunsCompleted') ?? 0;
  Future<void> incRunsCompleted() async {
    await _prefs.setInt('totalRunsCompleted', totalRunsCompleted + 1);
  }

  int get totalSpheresCollected => _prefs.getInt('totalSpheres') ?? 0;
  Future<void> addSpheres(int amount) async {
    await _prefs.setInt('totalSpheres', totalSpheresCollected + amount);
  }

  int get bestOrbitSize => _prefs.getInt('bestOrbit') ?? 0;
  Future<void> reportOrbit(int size) async {
    if (size > bestOrbitSize) await _prefs.setInt('bestOrbit', size);
  }

  int get infectedKills => _prefs.getInt('infectedKills') ?? 0;
  Future<void> addInfectedKills(int amount) async {
    await _prefs.setInt('infectedKills', infectedKills + amount);
  }

  int get bossKills => _prefs.getInt('bossKills') ?? 0;
  Future<void> addBossKill() async {
    await _prefs.setInt('bossKills', bossKills + 1);
  }

  int get blackHolesSurvived => _prefs.getInt('blackHolesSurvived') ?? 0;
  Future<void> addBlackHoleSurvived() async {
    await _prefs.setInt('blackHolesSurvived', blackHolesSurvived + 1);
  }

  Set<String> get usedUpgradeIds =>
      (_prefs.getStringList('usedUpgradeIds') ?? const []).toSet();

  Future<void> addUsedUpgrade(String id) async {
    final set = usedUpgradeIds..add(id);
    await _prefs.setStringList('usedUpgradeIds', set.toList());
  }

  int get upgradesUsedUnique => usedUpgradeIds.length;

  // --- Onboarding -----------------------------------------------------
  bool get tutorialSeen => _prefs.getBool('tutorialSeen') ?? false;
  Future<void> setTutorialSeen() => _prefs.setBool('tutorialSeen', true);

  // --- Lab / meta-upgrade shop ---------------------------------------
  // Permanent upgrades bought with crystals. Each module stores a level that
  // gameplay reads at run start (see FluxGame.onLoad).
  int labLevel(String id) => _prefs.getInt('lab_$id') ?? 0;
  Future<void> incLabLevel(String id) =>
      _prefs.setInt('lab_$id', labLevel(id) + 1);

  // --- Pilot profile --------------------------------------------------
  String get callsign => _prefs.getString('callsign') ?? 'Pilot-07';
  Future<void> setCallsign(String v) =>
      _prefs.setString('callsign', v.trim().isEmpty ? 'Pilot-07' : v.trim());

  // --- Settings -----------------------------------------------------
  bool get musicEnabled => _prefs.getBool('musicEnabled') ?? true;
  Future<void> setMusicEnabled(bool v) => _prefs.setBool('musicEnabled', v);

  bool get sfxEnabled => _prefs.getBool('sfxEnabled') ?? true;
  Future<void> setSfxEnabled(bool v) => _prefs.setBool('sfxEnabled', v);

  // --- Daily quests -------------------------------------------------
  static const List<Map<String, dynamic>> questPool = [
    {'id': 'collect_spheres', 'label': 'Collect 250 energy spheres', 'target': 250},
    {'id': 'defeat_enemies', 'label': 'Defeat 500 enemies', 'target': 500},
    {'id': 'finish_runs', 'label': 'Finish 3 runs', 'target': 3},
    {'id': 'defeat_miniboss', 'label': 'Defeat any mini-boss', 'target': 1},
    {'id': 'orbit_20', 'label': 'Build an orbit of 20 satellites', 'target': 1},
    {'id': 'defeat_infected', 'label': 'Destroy 50 infected enemies', 'target': 50},
    {'id': 'survive_blackhole', 'label': 'Survive a Black Hole event', 'target': 1},
    {'id': 'defeat_final_boss', 'label': 'Defeat the final boss', 'target': 1},
    {'id': 'use_upgrades', 'label': 'Use 10 different upgrades', 'target': 10},
    {'id': 'no_damage_run', 'label': 'Finish a run without core damage', 'target': 1},
  ];

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  List<Map<String, dynamic>> dailyQuests() {
    final key = 'dailyQuestDay';
    final progressKey = 'dailyQuestProgress';
    final storedDay = _prefs.getString(key);
    if (storedDay != _todayKey) {
      // Roll new quests deterministically for the day.
      final seed = _todayKey.hashCode;
      final rnd = Random(seed);
      final pool = List.of(questPool)..shuffle(rnd);
      final chosen = pool.take(3).toList();
      _prefs.setString(key, _todayKey);
      _prefs.setString('dailyQuestChosen', jsonEncode(chosen));
      _prefs.setString(progressKey, jsonEncode({for (final q in chosen) q['id']: 0}));
    }
    final chosenRaw = _prefs.getString('dailyQuestChosen');
    if (chosenRaw == null) return [];
    return (jsonDecode(chosenRaw) as List).cast<Map<String, dynamic>>();
  }

  Map<String, int> dailyQuestProgress() {
    dailyQuests();
    final raw = _prefs.getString('dailyQuestProgress');
    if (raw == null) return {};
    return (jsonDecode(raw) as Map).map((k, v) => MapEntry(k as String, v as int));
  }

  Future<void> addDailyQuestProgress(String id, int amount) async {
    final quests = dailyQuests();
    if (!quests.any((q) => q['id'] == id)) return;
    final progress = dailyQuestProgress();
    progress[id] = (progress[id] ?? 0) + amount;
    await _prefs.setString('dailyQuestProgress', jsonEncode(progress));
  }

  bool isQuestClaimed(String id) =>
      _prefs.getBool('questClaimed_${id}_$_todayKey') ?? false;

  Future<void> claimQuest(String id) async {
    await _prefs.setBool('questClaimed_${id}_$_todayKey', true);
  }

  // --- Achievements (permanent milestones) --------------------------------
  bool isAchievementClaimed(String id) =>
      _prefs.getBool('achievementClaimed_$id') ?? false;

  Future<void> claimAchievement(String id) async {
    await _prefs.setBool('achievementClaimed_$id', true);
  }

  int get claimedAchievements =>
      _prefs.getKeys().where((k) => k.startsWith('achievementClaimed_')).length;
}
