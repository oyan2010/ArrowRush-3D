import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/config/app_config.dart';
import '../../core/services/ad_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/level_model.dart';
import '../../data/repositories/level_repository.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../widgets/clay_button.dart';
import '../widgets/clay_card.dart';
import '../widgets/how_to_play_dialog.dart';
import '../widgets/offline_banner.dart';
import 'game_screen.dart';
import 'settings_dialog.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storage;
  final LevelRepository levelRepository;
  final ConnectivityService connectivityService;

  const HomeScreen({
    super.key,
    required this.storage,
    required this.levelRepository,
    required this.connectivityService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum GameMode { campaign, random, daily }

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  bool _isOnline = true;

  GameMode _selectedMode = GameMode.campaign;
  DifficultyTier _selectedHardness = DifficultyTier.intermediate;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _loadBannerAd();
  }

  Future<void> _checkConnection() async {
    final ok = await widget.connectivityService.isNetworkAvailable();
    if (mounted) setState(() => _isOnline = ok);
  }

  void _loadBannerAd() {
    if (!AppConfig.adsEnabled || !AppConfig.showHomeBanner || widget.storage.adsRemoved || kIsWeb) return;
    _bannerAd = BannerAd(
      adUnitId: AdService.instance.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isBannerLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLevelIdx = widget.storage.currentLevel;
    final campaignLevelModel = widget.levelRepository.getLevel(currentLevelIdx);
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Top Neumorphic Header Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Streak Badge
                      ClayCard(
                        color: surfaceColor,
                        borderRadius: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Row(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.storage.streakCount} Streak',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),

                      Row(
                        children: [
                          // How to Play Tutorial
                          IconButton(
                            icon: const Icon(Icons.help_outline_rounded, color: AppColors.accent, size: 28),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => const HowToPlayDialog(),
                              );
                            },
                          ),
                          // Stats / Trophies
                          IconButton(
                            icon: const Icon(Icons.emoji_events_rounded, color: AppColors.hintGlow, size: 30),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StatsScreen(storage: widget.storage),
                                ),
                              );
                            },
                          ),
                          // Settings
                          IconButton(
                            icon: const Icon(Icons.settings_rounded, size: 28),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => const SettingsDialog(),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),

                        // Title Banner
                        Text(
                          'ARROWS 3D',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Neumorphic Puzzle Master',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Mode Selector Segmented Buttons
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              _buildModeTab('CAMPAIGN', GameMode.campaign),
                              _buildModeTab('RANDOM', GameMode.random),
                              _buildModeTab('DAILY', GameMode.daily),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Mode Specific Content Card
                        if (_selectedMode == GameMode.campaign)
                          _buildCampaignCard(context, surfaceColor, campaignLevelModel, currentLevelIdx)
                        else if (_selectedMode == GameMode.random)
                          _buildRandomCard(context, surfaceColor)
                        else
                          _buildDailyCard(context, surfaceColor),
                      ],
                    ),
                  ),
                ),

                // AdMob Banner Placement
                if (_isBannerLoaded && _bannerAd != null)
                  SizedBox(
                    height: _bannerAd!.size.height.toDouble(),
                    width: _bannerAd!.size.width.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
              ],
            ),
          ),

          // Network overlay banner if offline
          if (!_isOnline)
            OfflineBanner(onRetry: _checkConnection),
        ],
      ),
    );
  }

  Widget _buildModeTab(String label, GameMode mode) {
    final isSelected = _selectedMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.0,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCampaignCard(BuildContext context, Color surfaceColor, LevelModel levelModel, int currentLevelIdx) {
    return ClayCard(
      color: surfaceColor,
      borderRadius: 32,
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              levelModel.difficultyTier.displayName.toUpperCase(),
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Level $currentLevelIdx',
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${levelModel.arrows.length} Intertwined Arrows • ${levelModel.rows}x${levelModel.cols} Grid',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),

          ClayButton(
            color: AppColors.accent,
            height: 64,
            icon: Icons.play_arrow_rounded,
            text: 'PLAY CAMPAIGN',
            onTap: () async {
              context.read<GameBloc>().add(LoadLevel(currentLevelIdx));
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GameScreen()),
              );
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRandomCard(BuildContext context, Color surfaceColor) {
    return ClayCard(
      color: surfaceColor,
      borderRadius: 32,
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const Text(
            'SELECT HARDNESS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 16),

          // Hardness Selection Pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: DifficultyTier.values.map((tier) {
              final isSel = _selectedHardness == tier;
              return ChoiceChip(
                label: Text(tier.displayName.toUpperCase()),
                selected: isSel,
                selectedColor: AppColors.accent,
                labelStyle: TextStyle(
                  color: isSel ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                onSelected: (_) => setState(() => _selectedHardness = tier),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          Text(
            'Fresh random untangle puzzle generated for $selectedHardnessDisplayName.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 28),

          ClayButton(
            color: AppColors.accent,
            height: 64,
            icon: Icons.shuffle_rounded,
            text: 'GENERATE PUZZLE',
            onTap: () async {
              final randomLevel = widget.levelRepository.getRandomLevel(_selectedHardness);
              context.read<GameBloc>().add(LoadCustomLevel(randomLevel));
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GameScreen()),
              );
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
    );
  }

  String get selectedHardnessDisplayName => _selectedHardness.displayName;

  Widget _buildDailyCard(BuildContext context, Color surfaceColor) {
    final now = DateTime.now();
    final dateStr = '${_monthName(now.month)} ${now.day}, ${now.year}';

    return ClayCard(
      color: surfaceColor,
      borderRadius: 32,
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.orange,
            child: Icon(Icons.calendar_today_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'DAILY CHALLENGE',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateStr,
            style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const Text(
            'Untangle today\'s unique daily puzzle to keep your daily streak alive!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 28),

          ClayButton(
            color: Colors.orange,
            height: 64,
            icon: Icons.star_rounded,
            text: 'PLAY DAILY PUZZLE',
            onTap: () async {
              final dailyLevel = widget.levelRepository.getDailyChallenge();
              context.read<GameBloc>().add(LoadCustomLevel(dailyLevel));
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GameScreen()),
              );
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
