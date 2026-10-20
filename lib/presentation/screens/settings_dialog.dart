import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/theme_cubit.dart';
import '../widgets/clay_card.dart';

/// Settings Modal with functional Dark Mode, Sound, Vibration, and Remove Ads switches.
class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final settingsState = context.watch<SettingsCubit>().state;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Dark Mode Switch
          _buildSettingTile(
            context,
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            title: 'Dark Theme',
            subtitle: isDark ? 'Clay Navy Mode' : 'Cloud White Mode',
            value: isDark,
            onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
          ),

          const SizedBox(height: 12),

          // Sounds Switch
          _buildSettingTile(
            context,
            icon: settingsState.soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            title: 'Sound Effects',
            subtitle: 'Launch, pop, and error sounds',
            value: settingsState.soundEnabled,
            onChanged: (_) => context.read<SettingsCubit>().toggleSound(),
          ),

          const SizedBox(height: 12),

          // Vibration Switch
          _buildSettingTile(
            context,
            icon: settingsState.hapticEnabled ? Icons.vibration_rounded : Icons.smartphone_rounded,
            title: 'Vibrations & Haptics',
            subtitle: 'Haptic response on tap and collision',
            value: settingsState.hapticEnabled,
            onChanged: (_) => context.read<SettingsCubit>().toggleHaptic(),
          ),

          const SizedBox(height: 12),

          // Remove Ads Switch
          _buildSettingTile(
            context,
            icon: settingsState.adsRemoved ? Icons.block_rounded : Icons.no_sim_rounded,
            title: 'Remove Ads',
            subtitle: settingsState.adsRemoved
                ? 'Ads Disabled (Ad-free mode active)'
                : 'Turn on to disable all banner & interstitial ads',
            value: settingsState.adsRemoved,
            onChanged: (val) {
              context.read<SettingsCubit>().toggleAdsRemoved();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    val
                        ? '🚫 Ads Removed successfully! Enjoy ad-free gameplay.'
                        : '📢 Ads Re-enabled.',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ClayCard(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
