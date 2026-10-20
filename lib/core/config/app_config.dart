// ═══════════════════════════════════════════════════════════════════════════════
// 🎮 ARROWS 3D: PUZZLE MASTER — MASTER CONFIGURATION FILE
// ═══════════════════════════════════════════════════════════════════════════════
//
// ✏️  HOW TO EDIT THIS FILE:
//   - Change ONLY the values on the RIGHT side of the = sign
//   - Colors use hex format: 0xFF followed by 6 hex digits (RRGGBB)
//     Example: 0xFFFF6B9D = Pink, 0xFF4ECDC4 = Mint
//   - File paths point to assets/ folder
//   - Ad IDs are strings in quotes — paste your AdMob IDs between the quotes
//   - true = ON, false = OFF
//
// ⚠️  DO NOT change anything OUTSIDE this file unless you know code!
// ═══════════════════════════════════════════════════════════════════════════════

class AppConfig {
  AppConfig._();

  // ═══════════════════════════════════════════
  // 🌐 NETWORK / OFFLINE MODE
  // ═══════════════════════════════════════════
  /// Set to true  = App REQUIRES internet (shows error screen if offline)
  /// Set to false = App works fully offline (DEFAULT)
  static const bool requiresInternet = false;

  // ═══════════════════════════════════════════
  // 🎨 ARROW COLORS (Hex: 0xAARRGGBB, AA = FF for full opacity)
  // ═══════════════════════════════════════════
  static const int arrowColor1 = 0xFFFF3B70; // Vibrant Neon Coral
  static const int arrowColor2 = 0xFF00E5FF; // High-Voltage Cyan
  static const int arrowColor3 = 0xFFFF7043; // Vivid Electric Orange
  static const int arrowColor4 = 0xFF3D5AFE; // Deep Royal Indigo
  static const int arrowColor5 = 0xFFD500F9; // Intense Violet/Purple
  static const int arrowColor6 = 0xFFF59E0B; // Soft Warm Amber Yellow
  static const int arrowColor7 = 0xFF00E676; // Crisp Spring Mint Green
  static const int arrowColor8 = 0xFFFF1744; // Razor Crimson Red

  /// All arrow colors in a list (arrows cycle through these)
  static const List<int> arrowColors = [
    arrowColor1, arrowColor2, arrowColor3, arrowColor4,
    arrowColor5, arrowColor6, arrowColor7, arrowColor8,
  ];

  // ═══════════════════════════════════════════
  // 🌙 DARK MODE COLORS
  // ═══════════════════════════════════════════
  static const int darkBackground    = 0xFF1A1B2E; // Clay Navy
  static const int darkSurface       = 0xFF252745; // Card Navy
  static const int darkTextPrimary   = 0xFFFFFFFF; // White text
  static const int darkTextSecondary = 0xFFB0B3C6; // Muted text

  // ═══════════════════════════════════════════
  // ☀️ LIGHT MODE COLORS
  // ═══════════════════════════════════════════
  static const int lightBackground    = 0xFFF5F5FA; // Cloud White
  static const int lightSurface       = 0xFFFFFFFF; // Pure White
  static const int lightTextPrimary   = 0xFF1A1B2E; // Dark text
  static const int lightTextSecondary = 0xFF6B6D85; // Gray text

  // ═══════════════════════════════════════════
  // 🎯 GAME UI COLORS
  // ═══════════════════════════════════════════
  static const int heartColor     = 0xFFFF4757; // Red hearts
  static const int hintGlowColor  = 0xFFFFD93D; // Yellow hint glow
  static const int collisionColor = 0xFFFF0033; // Collision red flash
  static const int successColor   = 0xFF00E676; // Win green
  static const int gridLineColor  = 0x15FFFFFF; // Faint grid lines (dark mode)
  static const int gridLineColorLight = 0x15000000; // Faint grid lines (light mode)
  static const int accentColor    = 0xFF5B86E5; // Buttons & highlights

  // ═══════════════════════════════════════════
  // 📢 ADMOB ADS — Paste your REAL Ad Unit IDs below
  // ═══════════════════════════════════════════
  //
  // ⚠️  These are GOOGLE TEST IDs — Replace with YOUR IDs before publishing!
  //
  // ── Android ──
  static const String admobAppIdAndroid     = 'ca-app-pub-3940256099942544~3347511713';
  static const String bannerAdIdAndroid     = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialIdAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String rewardedAdIdAndroid   = 'ca-app-pub-3940256099942544/5224354917';
  //
  // ── iOS ──
  static const String admobAppIdIos     = 'ca-app-pub-3940256099942544~1458002511';
  static const String bannerAdIdIos     = 'ca-app-pub-3940256099942544/2934735716';
  static const String interstitialIdIos = 'ca-app-pub-3940256099942544/4411468910';
  static const String rewardedAdIdIos   = 'ca-app-pub-3940256099942544/1712485313';

  /// Master switch: set to false to completely disable ALL ads
  static const bool adsEnabled = true;

  /// Show banner ad on the home screen?
  static const bool showHomeBanner = true;

  /// Show interstitial ad between levels?
  static const bool showInterstitialBetweenLevels = true;

  /// Show interstitial every N levels (e.g., 3 = every 3rd level)
  static const int interstitialFrequency = 3;

  // ═══════════════════════════════════════════
  // 🔊 SOUND EFFECTS — Place your audio files in assets/sounds/
  // ═══════════════════════════════════════════
  //
  // Supported formats: .mp3, .wav, .ogg
  // If a file is missing, the app won't crash — it just plays no sound.
  //
  static const String launchSound    = 'assets/sounds/launch.mp3';
  static const String popSound       = 'assets/sounds/pop.mp3';
  static const String collisionSound = 'assets/sounds/collision.mp3';
  static const String winSound       = 'assets/sounds/win.mp3';
  static const String tapSound       = 'assets/sounds/tap.mp3';
  static const String hintSound      = 'assets/sounds/hint.mp3';

  // ═══════════════════════════════════════════
  // 🖼️ CUSTOM ICONS — Leave empty '' to use built-in Material icons
  // ═══════════════════════════════════════════
  //
  // 📐 RECOMMENDED ICON SIZES:
  //   • In-game icons (heart, hint, settings): 48×48 px (1x), 96×96 px (2x), 144×144 px (3x)
  //   • Trophy / badge icons:                  64×64 px (1x), 128×128 px (2x), 192×192 px (3x)
  //   • Format: PNG with transparent background
  //   • Place files in: assets/icons/
  //
  // Set to '' (empty) to use the default Material icon instead.
  //
  static const String heartIconPath    = ''; // Default: ❤️ Icons.favorite
  static const String hintIconPath     = ''; // Default: 💡 Icons.lightbulb
  static const String settingsIconPath = ''; // Default: ⚙️ Icons.settings
  static const String trophyIconPath   = ''; // Default: 🏆 Icons.emoji_events
  static const String replayIconPath   = ''; // Default: 🔄 Icons.replay
  static const String homeIconPath     = ''; // Default: 🏠 Icons.home
  static const String playIconPath     = ''; // Default: ▶️ Icons.play_arrow

  // ═══════════════════════════════════════════
  // ❤️ LIVES & HINTS
  // ═══════════════════════════════════════════
  static const int maxLivesPerLevel     = 3;   // Hearts per level
  static const int livesFromRewardedAd  = 1;   // +1 life after watching ad
  static const int freeHintEveryNLevels = 4;   // 1 free hint every 4 levels
  static const int hintsFromRewardedAd  = 2;   // +2 hints after watching ad
  static const int startingHints        = 3;   // Hints when player first installs

  // ═══════════════════════════════════════════
  // 📐 LEVEL DIFFICULTY — Grid sizes & arrow counts
  // ═══════════════════════════════════════════
  //
  // Levels 1–20: Beginner (Densely packed)
  static const int beginnerMinRows   = 5;
  static const int beginnerMaxRows   = 6;
  static const int beginnerMinCols   = 5;
  static const int beginnerMaxCols   = 6;
  static const int beginnerMinArrows = 6;
  static const int beginnerMaxArrows = 12;

  // Levels 21–50: Intermediate (Dense)
  static const int intermediateMinRows   = 7;
  static const int intermediateMaxRows   = 8;
  static const int intermediateMinCols   = 7;
  static const int intermediateMaxCols   = 8;
  static const int intermediateMinArrows = 14;
  static const int intermediateMaxArrows = 24;

  // Levels 51–80: Advanced (Ultra Dense)
  static const int advancedMinRows   = 9;
  static const int advancedMaxRows   = 10;
  static const int advancedMinCols   = 9;
  static const int advancedMaxCols   = 10;
  static const int advancedMinArrows = 24;
  static const int advancedMaxArrows = 42;

  // Levels 81–100+: Nightmare (Maximum Grid Packing)
  static const int nightmareMinRows   = 11;
  static const int nightmareMaxRows   = 13;
  static const int nightmareMinCols   = 11;
  static const int nightmareMaxCols   = 13;
  static const int nightmareMinArrows = 36;
  static const int nightmareMaxArrows = 65;

  /// Total number of levels in the game
  static const int totalLevels = 100;

  // ═══════════════════════════════════════════
  // 🏆 DAILY STREAK
  // ═══════════════════════════════════════════
  /// Hours within which the player must win a level to keep streak
  static const int streakHoursWindow = 24;

  // ═══════════════════════════════════════════
  // 🎨 TYPOGRAPHY
  // ═══════════════════════════════════════════
  /// Google Font family name (e.g., 'Outfit', 'Poppins', 'Inter')
  static const String fontFamily = 'Outfit';
}
