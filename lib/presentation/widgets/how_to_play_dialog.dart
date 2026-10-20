import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'clay_button.dart';
import 'clay_card.dart';

class HowToPlayDialog extends StatefulWidget {
  const HowToPlayDialog({super.key});

  @override
  State<HowToPlayDialog> createState() => _HowToPlayDialogState();
}

class _HowToPlayDialogState extends State<HowToPlayDialog> {
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'OBJECTIVE',
      'subtitle': 'Untangle the 3D Arrow Grid',
      'description':
          'Tap arrows to release them one by one. Clear all arrows off the board to win the level!',
      'icon': Icons.extension_rounded,
      'color': AppColors.accent,
    },
    {
      'title': 'ARROW DIRECTION',
      'subtitle': 'Watch the Arrowhead',
      'description':
          'Each arrow slides out in the direction its arrowhead points (Up, Down, Left, or Right).',
      'icon': Icons.explore_rounded,
      'color': Colors.amber,
    },
    {
      'title': 'AVOID COLLISIONS',
      'subtitle': 'Clear Unblocked Arrows',
      'description':
          'If an arrow\'s exit path is blocked by another arrow, tapping it will cause a crash and lose a heart!',
      'icon': Icons.warning_amber_rounded,
      'color': AppColors.collision,
    },
    {
      'title': 'USE HINTS',
      'subtitle': 'Need Help?',
      'description':
          'Tap the Lightbulb button at top-right to highlight an arrow that can be cleared safely!',
      'icon': Icons.lightbulb_rounded,
      'color': AppColors.hintGlow,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ClayCard(
        color: surfaceColor,
        borderRadius: 28,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'HOW TO PLAY',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Icon Circle
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (page['color'] as Color).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                page['icon'] as IconData,
                color: page['color'] as Color,
                size: 56,
              ),
            ),
            const SizedBox(height: 16),

            // Title & Subtitle
            Text(
              page['title'] as String,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: page['color'] as Color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              page['subtitle'] as String,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),

            // Description Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                page['description'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
            const SizedBox(height: 20),

            // Page Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (idx) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == idx ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == idx
                        ? AppColors.accent
                        : Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Navigation Button
            ClayButton(
              color: AppColors.accent,
              text: _currentPage < _pages.length - 1 ? 'NEXT' : 'GOT IT!',
              icon: _currentPage < _pages.length - 1
                  ? Icons.arrow_forward_rounded
                  : Icons.check_circle_rounded,
              onTap: () {
                if (_currentPage < _pages.length - 1) {
                  setState(() => _currentPage++);
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
