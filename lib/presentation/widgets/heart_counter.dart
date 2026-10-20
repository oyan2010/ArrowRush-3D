import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';

/// Row of 3D animated hearts representing remaining lives.
class HeartCounter extends StatelessWidget {
  final int lives;
  final int maxLives;

  const HeartCounter({
    super.key,
    required this.lives,
    this.maxLives = AppConfig.maxLivesPerLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxLives, (index) {
        final isFilled = index < lives;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3.0),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 300),
            scale: isFilled ? 1.0 : 0.8,
            child: AppConfig.heartIconPath.isNotEmpty
                ? Image.asset(
                    AppConfig.heartIconPath,
                    width: 32,
                    height: 32,
                    color: isFilled ? null : Colors.grey.withOpacity(0.5),
                  )
                : Icon(
                    isFilled ? Icons.favorite : Icons.favorite_border,
                    color: isFilled ? AppColors.heart : Colors.grey.withOpacity(0.4),
                    size: 32,
                  ),
          ),
        );
      }),
    );
  }
}
