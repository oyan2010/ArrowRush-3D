import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/config/app_config.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/haptic_service.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/arrow_model.dart';
import '../../data/models/level_model.dart';
import '../../data/repositories/level_repository.dart';
import '../../domain/engine/collision_checker.dart';
import '../../domain/engine/hint_calculator.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final LevelRepository _levelRepository;
  final StorageService _storage;
  final AudioService _audioService;
  final HapticService _hapticService;

  GameBloc({
    required LevelRepository levelRepository,
    required StorageService storage,
    required AudioService audioService,
    required HapticService hapticService,
  })  : _levelRepository = levelRepository,
        _storage = storage,
        _audioService = audioService,
        _hapticService = hapticService,
        super(GameState(hintsRemaining: storage.hintsCount)) {
    on<LoadLevel>(_onLoadLevel);
    on<LoadCustomLevel>(_onLoadCustomLevel);
    on<TapArrow>(_onTapArrow);
    on<UseHint>(_onUseHint);
    on<AddLives>(_onAddLives);
    on<AddHints>(_onAddHints);
    on<RestartLevel>(_onRestartLevel);
    on<NextLevel>(_onNextLevel);
  }

  void _onLoadCustomLevel(LoadCustomLevel event, Emitter<GameState> emit) {
    final level = event.levelModel;
    emit(GameState(
      status: GameStatus.playing,
      level: level,
      arrows: List.from(level.arrows),
      lives: AppConfig.maxLivesPerLevel,
      hintsRemaining: _storage.hintsCount,
    ));
  }

  void _onLoadLevel(LoadLevel event, Emitter<GameState> emit) {
    final level = _levelRepository.getLevel(event.levelIndex);
    _storage.setCurrentLevel(event.levelIndex);

    emit(GameState(
      status: GameStatus.playing,
      level: level,
      arrows: List.from(level.arrows),
      lives: AppConfig.maxLivesPerLevel,
      hintsRemaining: _storage.hintsCount,
    ));
  }

  Future<void> _onTapArrow(TapArrow event, Emitter<GameState> emit) async {
    if (state.status != GameStatus.playing || state.level == null) return;

    final targetIndex = state.arrows.indexWhere((a) => a.id == event.arrowId);
    if (targetIndex == -1) return;

    final target = state.arrows[targetIndex];
    if (target.isCleared) return;

    _hapticService.tapFeedback();
    _audioService.playTap();

    final isBlocked = CollisionChecker.isBlocked(
      target,
      state.arrows,
      state.level!.rows,
      state.level!.cols,
    );

    if (isBlocked) {
      _hapticService.collisionFeedback();
      _audioService.playCollision();

      final newLives = state.lives - 1;
      final updatedArrows = List<ArrowModel>.from(state.arrows);
      updatedArrows[targetIndex] = target.copyWith(isColliding: true);

      emit(state.copyWith(
        lives: newLives,
        arrows: updatedArrows,
        collidingArrowId: target.id,
        clearHint: true,
      ));

      await Future.delayed(const Duration(milliseconds: 400));
      if (!emit.isDone) {
        final resetArrows = List<ArrowModel>.from(state.arrows);
        final currentIdx = resetArrows.indexWhere((a) => a.id == target.id);
        if (currentIdx != -1) {
          resetArrows[currentIdx] = resetArrows[currentIdx].copyWith(isColliding: false);
        }
        emit(state.copyWith(
          arrows: resetArrows,
          clearColliding: true,
          status: newLives <= 0 ? GameStatus.outOfLives : GameStatus.playing,
        ));

        if (newLives <= 0) {
          _storage.recordLoss();
        }
      }
    } else {
      _audioService.playLaunch();
      _hapticService.successFeedback();

      final updatedArrows = List<ArrowModel>.from(state.arrows);
      updatedArrows[targetIndex] = target.copyWith(isCleared: true);

      emit(state.copyWith(
        arrows: updatedArrows,
        animatingArrowId: target.id,
        clearHint: true,
      ));

      final remainingActive = updatedArrows.where((a) => !a.isCleared).length;
      if (remainingActive == 0) {
        _audioService.playWin();
        _storage.recordWin();

        if (state.level!.levelIndex > 0 && state.level!.levelIndex % AppConfig.freeHintEveryNLevels == 0) {
          final newHints = state.hintsRemaining + 1;
          _storage.setHintsCount(newHints);
        }

        emit(state.copyWith(
          status: GameStatus.won,
          hintsRemaining: _storage.hintsCount,
        ));
      }
    }
  }

  void _onUseHint(UseHint event, Emitter<GameState> emit) {
    if (state.status != GameStatus.playing || state.level == null) return;
    if (state.hintsRemaining <= 0) return;

    final safeArrow = HintCalculator.findSafeArrow(
      state.arrows,
      state.level!.rows,
      state.level!.cols,
    );

    if (safeArrow != null) {
      _audioService.playHint();
      _hapticService.tapFeedback();

      final newHints = state.hintsRemaining - 1;
      _storage.setHintsCount(newHints);

      emit(state.copyWith(
        hintsRemaining: newHints,
        hintedArrowId: safeArrow.id,
      ));
    }
  }

  void _onAddLives(AddLives event, Emitter<GameState> emit) {
    final newLives = state.lives + event.count;
    emit(state.copyWith(
      lives: newLives,
      status: GameStatus.playing,
    ));
  }

  void _onAddHints(AddHints event, Emitter<GameState> emit) {
    final newHints = state.hintsRemaining + event.count;
    _storage.setHintsCount(newHints);
    emit(state.copyWith(hintsRemaining: newHints));
    add(const UseHint());
  }

  void _onRestartLevel(RestartLevel event, Emitter<GameState> emit) {
    if (state.level == null) return;
    if (state.level!.levelIndex <= 0) {
      // Re-load the current custom/challenge level
      add(LoadCustomLevel(state.level!));
    } else {
      add(LoadLevel(state.level!.levelIndex));
    }
  }

  void _onNextLevel(NextLevel event, Emitter<GameState> emit) {
    final currentIdx = state.level?.levelIndex ?? 1;
    if (currentIdx <= 0) {
      // Challenge Mode / Random Mode: Generate a fresh custom level in the same tier!
      final tier = state.level?.difficultyTier ?? DifficultyTier.intermediate;
      final nextCustomLevel = _levelRepository.getRandomLevel(tier);
      add(LoadCustomLevel(nextCustomLevel));
    } else {
      add(LoadLevel(currentIdx + 1));
    }
  }
}
