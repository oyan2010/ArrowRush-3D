import 'package:equatable/equatable.dart';
import '../../data/models/arrow_model.dart';
import '../../data/models/level_model.dart';

enum GameStatus { initial, playing, won, outOfLives }

class GameState extends Equatable {
  final GameStatus status;
  final LevelModel? level;
  final List<ArrowModel> arrows;
  final int lives;
  final int hintsRemaining;
  final String? hintedArrowId;
  final String? animatingArrowId;
  final String? collidingArrowId;

  const GameState({
    this.status = GameStatus.initial,
    this.level,
    this.arrows = const [],
    this.lives = 3,
    this.hintsRemaining = 3,
    this.hintedArrowId,
    this.animatingArrowId,
    this.collidingArrowId,
  });

  GameState copyWith({
    GameStatus? status,
    LevelModel? level,
    List<ArrowModel>? arrows,
    int? lives,
    int? hintsRemaining,
    String? hintedArrowId,
    bool clearHint = false,
    String? animatingArrowId,
    bool clearAnimating = false,
    String? collidingArrowId,
    bool clearColliding = false,
  }) {
    return GameState(
      status: status ?? this.status,
      level: level ?? this.level,
      arrows: arrows ?? this.arrows,
      lives: lives ?? this.lives,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      hintedArrowId: clearHint ? null : (hintedArrowId ?? this.hintedArrowId),
      animatingArrowId: clearAnimating ? null : (animatingArrowId ?? this.animatingArrowId),
      collidingArrowId: clearColliding ? null : (collidingArrowId ?? this.collidingArrowId),
    );
  }

  @override
  List<Object?> get props => [
        status,
        level,
        arrows,
        lives,
        hintsRemaining,
        hintedArrowId,
        animatingArrowId,
        collidingArrowId,
      ];
}
