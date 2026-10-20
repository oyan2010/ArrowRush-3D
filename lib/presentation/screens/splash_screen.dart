import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/level_repository.dart';
import '../widgets/clay_card.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  final StorageService storage;
  final LevelRepository levelRepository;
  final ConnectivityService connectivityService;

  const SplashScreen({
    super.key,
    required this.storage,
    required this.levelRepository,
    required this.connectivityService,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 1.0, curve: Curves.easeInOut)),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 2400), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => HomeScreen(
              storage: widget.storage,
              levelRepository: widget.levelRepository,
              connectivityService: widget.connectivityService,
            ),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 3D Neumorphic App Icon Box
                      ClayCard(
                        color: surfaceColor,
                        borderRadius: 36,
                        padding: const EdgeInsets.all(20),
                        child: Image.asset(
                          'assets/icons/app_icon.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.accent.withOpacity(0.15),
                              ),
                              child: const Icon(
                                Icons.navigation_rounded,
                                size: 72,
                                color: AppColors.accent,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Title
                      const Text(
                        'ARROWS 3D',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Text(
                        'PUZZLE MASTER',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Animated Loading Bar
                      SizedBox(
                        width: 180,
                        height: 8,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _progressAnimation.value,
                            backgroundColor: AppColors.accent.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
