import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/services/ad_service.dart';
import 'core/services/audio_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/haptic_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/level_generator.dart';
import 'data/repositories/level_repository.dart';
import 'presentation/bloc/game_bloc.dart';
import 'presentation/bloc/settings_cubit.dart';
import 'presentation/bloc/theme_cubit.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Hive Database
  final storageService = StorageService();
  await storageService.init();

  // Initialize Services
  final audioService = AudioService();
  final hapticService = HapticService();
  final connectivityService = ConnectivityService();
  await AdService.instance.initialize();

  // Initialize Repositories
  final levelRepository = LevelRepository(generator: LevelGenerator());

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: storageService),
        RepositoryProvider.value(value: audioService),
        RepositoryProvider.value(value: hapticService),
        RepositoryProvider.value(value: connectivityService),
        RepositoryProvider.value(value: levelRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit(storageService)),
          BlocProvider(
            create: (_) => SettingsCubit(
              storage: storageService,
              audioService: audioService,
              hapticService: hapticService,
            ),
          ),
          BlocProvider(
            create: (_) => GameBloc(
              levelRepository: levelRepository,
              storage: storageService,
              audioService: audioService,
              hapticService: hapticService,
            ),
          ),
        ],
        child: Arrows3DApp(
          storage: storageService,
          levelRepository: levelRepository,
          connectivityService: connectivityService,
        ),
      ),
    ),
  );
}

class Arrows3DApp extends StatelessWidget {
  final StorageService storage;
  final LevelRepository levelRepository;
  final ConnectivityService connectivityService;

  const Arrows3DApp({
    super.key,
    required this.storage,
    required this.levelRepository,
    required this.connectivityService,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeCubit>().state;

    return MaterialApp(
      title: 'Arrows 3D: Puzzle Master',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: SplashScreen(
        storage: storage,
        levelRepository: levelRepository,
        connectivityService: connectivityService,
      ),
    );
  }
}
