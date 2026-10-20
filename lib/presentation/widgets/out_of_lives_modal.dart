import 'package:flutter/material.dart';
import '../../core/services/ad_service.dart';
import '../../core/theme/app_colors.dart';
import 'clay_button.dart';
import 'clay_card.dart';

/// Dialog shown when lives reach 0.
class OutOfLivesModal extends StatelessWidget {
  final VoidCallback onWatchAd;
  final VoidCallback onRestart;

  const OutOfLivesModal({
    super.key,
    required this.onWatchAd,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClayCard(
        color: surfaceColor,
        borderRadius: 28,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.heart_broken_rounded,
              color: AppColors.heart,
              size: 72,
            ),
            const SizedBox(height: 16),
            Text(
              'Out of Lives!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Watch a quick ad to get +1 Heart and keep playing this level!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ClayButton(
              color: AppColors.heart,
              icon: Icons.ondemand_video_rounded,
              text: 'Watch Ad (+1 ❤️)',
              onTap: () {
                AdService.instance.showRewardedAd(
                  onUserEarnedReward: (_) => onWatchAd(),
                );
              },
            ),
            const SizedBox(height: 12),
            ClayButton(
              color: Colors.grey.shade600,
              icon: Icons.replay_rounded,
              text: 'Restart Level',
              onTap: onRestart,
            ),
          ],
        ),
      ),
    );
  }
}
