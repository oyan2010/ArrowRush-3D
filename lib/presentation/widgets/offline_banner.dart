import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import 'clay_card.dart';

/// Screen overlay displayed if AppConfig.requiresInternet is true and offline.
class OfflineBanner extends StatelessWidget {
  final VoidCallback onRetry;

  const OfflineBanner({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.requiresInternet) return const SizedBox.shrink();

    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Container(
      color: Colors.black.withOpacity(0.8),
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ClayCard(
          color: surfaceColor,
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: Colors.orange,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Internet Required',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'This app configuration requires an active internet connection to play.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Connection'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
