import 'package:equatable/equatable.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class LoadLevel extends GameEvent {
  final int levelIndex;
  const LoadLevel(this.levelIndex);

  @override
  List<Object?> get props => [levelIndex];
}

class TapArrow extends GameEvent {
  final String arrowId;
  const TapArrow(this.arrowId);

  @override
  List<Object?> get props => [arrowId];
}

class UseHint extends GameEvent {
  const UseHint();
}

class AddLives extends GameEvent {
  final int count;
  const AddLives({this.count = 1});

  @override
  List<Object?> get props => [count];
}

class RestartLevel extends GameEvent {
  const RestartLevel();
}

class NextLevel extends GameEvent {
  const NextLevel();
}

class AddHints extends GameEvent {
  final int count;
  const AddHints({this.count = 2});

  @override
  List<Object?> get props => [count];
}

class LoadCustomLevel extends GameEvent {
  final dynamic levelModel;
  const LoadCustomLevel(this.levelModel);

  @override
  List<Object?> get props => [levelModel];
}
