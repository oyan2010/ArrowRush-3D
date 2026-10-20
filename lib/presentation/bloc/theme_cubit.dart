import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/storage_service.dart';

/// Manages Dark/Light mode state.
class ThemeCubit extends Cubit<bool> {
  final StorageService _storage;

  ThemeCubit(this._storage) : super(_storage.isDarkMode);

  void toggleTheme() {
    final next = !state;
    _storage.setDarkMode(next);
    emit(next);
  }

  void setDarkMode(bool isDark) {
    _storage.setDarkMode(isDark);
    emit(isDark);
  }
}
