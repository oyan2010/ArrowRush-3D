import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/clay_card.dart';

/// Stats & Awards Screen showing streak, win rate, and trophies.
class StatsScreen extends StatelessWidget {
  final StorageService storage;

  const StatsScreen({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats & Trophies', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Current Streak',
                    value: '${storage.streakCount} 🔥',
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Win Rate',
                    value: '${storage.winRate.toStringAsFixed(0)}%',
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Trophies & Badges
            Text(
              'Trophies & Badges',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildBadgeCard(
                  context,
                  icon: Icons.star_rounded,
                  title: 'Beginner Master',
                  description: 'Reach Level 20',
                  isUnlocked: storage.currentLevel >= 20,
                ),
                _buildBadgeCard(
                  context,
                  icon: Icons.extension_rounded,
                  title: 'Puzzle Pro',
                  description: 'Reach Level 50',
                  isUnlocked: storage.currentLevel >= 50,
                ),
                _buildBadgeCard(
                  context,
                  icon: Icons.local_fire_department_rounded,
                  title: '7-Day Streak',
                  description: '7 Daily wins',
                  isUnlocked: storage.streakCount >= 7,
                ),
                _buildBadgeCard(
                  context,
                  icon: Icons.emoji_events_rounded,
                  title: 'Level 100 Master',
                  description: 'Clear all 100 levels',
                  isUnlocked: storage.currentLevel >= 100,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required Color color,
  }) {
    return ClayCard(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isUnlocked,
  }) {
    return ClayCard(
      color: isUnlocked
          ? Theme.of(context).colorScheme.surface
          : Theme.of(context).colorScheme.surface.withOpacity(0.4),
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 44,
            color: isUnlocked ? AppColors.hintGlow : Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isUnlocked ? null : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
