import '../models/level_model.dart';
import 'level_generator.dart';

/// Repository responsible for loading and caching puzzle levels.
class LevelRepository {
  final LevelGenerator _generator;
  final Map<int, LevelModel> _cache = {};

  LevelRepository({LevelGenerator? generator})
      : _generator = generator ?? LevelGenerator();

  /// Retrieves a level by its 1-based index (1 to infinity).
  LevelModel getLevel(int levelIndex) {
    if (levelIndex < 1) levelIndex = 1;

    if (!_cache.containsKey(levelIndex)) {
      _cache[levelIndex] = _generator.generateLevel(levelIndex);
    }
    return _cache[levelIndex]!;
  }

  /// Generates a fresh random level for a selected difficulty hardness (Easy, Medium, Hard, Nightmare).
  LevelModel getRandomLevel(DifficultyTier tier) {
    return _generator.generateRandomLevel(tier);
  }

  /// Generates today's unique Daily Challenge puzzle.
  LevelModel getDailyChallenge() {
    return _generator.generateDailyChallenge(DateTime.now());
  }

  /// Total available levels (Infinite).
  int get totalLevels => 999999;
}
