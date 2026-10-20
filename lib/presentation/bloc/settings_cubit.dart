import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/haptic_service.dart';
import '../../core/services/storage_service.dart';

class SettingsState extends Equatable {
  final bool soundEnabled;
  final bool hapticEnabled;
  final bool adsRemoved;

  const SettingsState({
    required this.soundEnabled,
    required this.hapticEnabled,
    required this.adsRemoved,
  });

  SettingsState copyWith({
    bool? soundEnabled,
    bool? hapticEnabled,
    bool? adsRemoved,
  }) {
    return SettingsState(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      adsRemoved: adsRemoved ?? this.adsRemoved,
    );
  }

  @override
  List<Object?> get props => [soundEnabled, hapticEnabled, adsRemoved];
}

class SettingsCubit extends Cubit<SettingsState> {
  final StorageService _storage;
  final AudioService _audioService;
  final HapticService _hapticService;

  SettingsCubit({
    required StorageService storage,
    required AudioService audioService,
    required HapticService hapticService,
  })  : _storage = storage,
        _audioService = audioService,
        _hapticService = hapticService,
        super(SettingsState(
          soundEnabled: storage.isSoundEnabled,
          hapticEnabled: storage.isHapticEnabled,
          adsRemoved: storage.adsRemoved,
        )) {
    _audioService.isEnabled = storage.isSoundEnabled;
    _hapticService.isEnabled = storage.isHapticEnabled;
  }

  void toggleSound() {
    final next = !state.soundEnabled;
    _storage.setSoundEnabled(next);
    _audioService.isEnabled = next;
    emit(state.copyWith(soundEnabled: next));
  }

  void toggleHaptic() {
    final next = !state.hapticEnabled;
    _storage.setHapticEnabled(next);
    _hapticService.isEnabled = next;
    emit(state.copyWith(hapticEnabled: next));
  }

  void toggleAdsRemoved() {
    final next = !state.adsRemoved;
    _storage.setAdsRemoved(next);
    emit(state.copyWith(adsRemoved: next));
  }
}
