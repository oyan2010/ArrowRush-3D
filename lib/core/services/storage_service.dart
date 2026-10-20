import 'package:hive_flutter/hive_flutter.dart';
import '../config/app_config.dart';

/// Local database service using Hive for persisting user progress and preferences.
class StorageService {
  static const String _boxName = 'arrows_3d_db';

  static const String _keyCurrentLevel = 'current_level';
  static const String _keyHighestLevel = 'highest_level';
  static const String _keyHasSeenTutorial = 'has_seen_tutorial';
  static const String _keyHintsCount   = 'hints_count';
  static const String _keyStreakCount  = 'streak_count';
  static const String _keyLastWinTime  = 'last_win_time';
  static const String _keyDarkMode     = 'dark_mode';
  static const String _keySoundEnabled = 'sound_enabled';
  static const String _keyHapticEnabled = 'haptic_enabled';
  static const String _keyAdsRemoved   = 'ads_removed';
  static const String _keyTotalWins    = 'total_wins';
  static const String _keyTotalPlayed  = 'total_played';

  late Box _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  // --- Current Level & Progress ---
  int get currentLevel => _box.get(_keyCurrentLevel, defaultValue: 1);
  Future<void> setCurrentLevel(int level) async {
    await _box.put(_keyCurrentLevel, level);
    if (level > highestUnlockedLevel) {
      await _box.put(_keyHighestLevel, level);
    }
  }

  int get highestUnlockedLevel => _box.get(_keyHighestLevel, defaultValue: 1);

  // --- Tutorial Flag ---
  bool get hasSeenTutorial => _box.get(_keyHasSeenTutorial, defaultValue: false);
  Future<void> setHasSeenTutorial(bool val) => _box.put(_keyHasSeenTutorial, val);

  // --- Hints ---
  int get hintsCount => _box.get(_keyHintsCount, defaultValue: AppConfig.startingHints);
  Future<void> setHintsCount(int count) => _box.put(_keyHintsCount, count);

  // --- Daily Streak & Trophy ---
  int get streakCount => _box.get(_keyStreakCount, defaultValue: 0);

  DateTime? get lastWinTime {
    final str = _box.get(_keyLastWinTime);
    return str != null ? DateTime.tryParse(str) : null;
  }

  Future<void> recordWin() async {
    final now = DateTime.now();
    final last = lastWinTime;

    int streak = streakCount;
    if (last == null) {
      streak = 1;
    } else {
      final hours = now.difference(last).inHours;
      if (hours <= AppConfig.streakHoursWindow) {
        if (now.day != last.day || now.month != last.month || now.year != last.year) {
          streak += 1;
        }
      } else {
        streak = 1;
      }
    }

    await _box.put(_keyStreakCount, streak);
    await _box.put(_keyLastWinTime, now.toIso8601String());

    await _box.put(_keyTotalWins, totalWins + 1);
    await _box.put(_keyTotalPlayed, totalPlayed + 1);
  }

  Future<void> recordLoss() async {
    await _box.put(_keyTotalPlayed, totalPlayed + 1);
  }

  int get totalWins => _box.get(_keyTotalWins, defaultValue: 0);
  int get totalPlayed => _box.get(_keyTotalPlayed, defaultValue: 0);

  double get winRate => totalPlayed == 0 ? 100.0 : ((totalWins / totalPlayed) * 100);

  // --- Settings ---
  bool get isDarkMode => _box.get(_keyDarkMode, defaultValue: true);
  Future<void> setDarkMode(bool val) => _box.put(_keyDarkMode, val);

  bool get isSoundEnabled => _box.get(_keySoundEnabled, defaultValue: true);
  Future<void> setSoundEnabled(bool val) => _box.put(_keySoundEnabled, val);

  bool get isHapticEnabled => _box.get(_keyHapticEnabled, defaultValue: true);
  Future<void> setHapticEnabled(bool val) => _box.put(_keyHapticEnabled, val);

  // --- Remove Ads Toggle ---
  bool get adsRemoved => _box.get(_keyAdsRemoved, defaultValue: false);
  Future<void> setAdsRemoved(bool val) => _box.put(_keyAdsRemoved, val);
}
