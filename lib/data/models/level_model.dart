import 'arrow_model.dart';

/// Difficulty tiers for level progression.
enum DifficultyTier {
  beginner,
  intermediate,
  advanced,
  nightmare;

  String get displayName {
    switch (this) {
      case DifficultyTier.beginner:
        return 'Beginner';
      case DifficultyTier.intermediate:
        return 'Intermediate';
      case DifficultyTier.advanced:
        return 'Advanced';
      case DifficultyTier.nightmare:
        return 'Nightmare';
    }
  }
}

/// Shaped board layout masks for level diversity.
enum BoardShape {
  rectangle,
  heart,
  circle,
  happyFace,
  hintBulb;

  String get displayName {
    switch (this) {
      case BoardShape.rectangle:
        return 'Rectangle';
      case BoardShape.heart:
        return 'Heart Maze';
      case BoardShape.circle:
        return 'Circle Maze';
      case BoardShape.happyFace:
        return 'Happy Face';
      case BoardShape.hintBulb:
        return 'Lightbulb';
    }
  }
}

/// Represents a complete puzzle level.
class LevelModel {
  final int levelIndex;
  final int rows;
  final int cols;
  final List<ArrowModel> arrows;
  final DifficultyTier difficultyTier;
  final BoardShape boardShape;
  final List<String> solutionOrder;

  const LevelModel({
    required this.levelIndex,
    required this.rows,
    required this.cols,
    required this.arrows,
    required this.difficultyTier,
    this.boardShape = BoardShape.rectangle,
    required this.solutionOrder,
  });
}
