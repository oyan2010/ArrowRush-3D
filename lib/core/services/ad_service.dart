import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/app_config.dart';

/// Service managing AdMob Banner, Interstitial, and Rewarded ads.
class AdService {
  static final AdService instance = AdService._();
  AdService._();

  bool _isInitialized = false;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  Future<void> initialize() async {
    if (!AppConfig.adsEnabled || kIsWeb) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      _loadInterstitialAd();
      _loadRewardedAd();
    } catch (e) {
      debugPrint('AdMob initialization error: $e');
    }
  }

  String get bannerAdUnitId {
    if (Platform.isAndroid) return AppConfig.bannerAdIdAndroid;
    if (Platform.isIOS) return AppConfig.bannerAdIdIos;
    return AppConfig.bannerAdIdAndroid;
  }

  String get interstitialAdUnitId {
    if (Platform.isAndroid) return AppConfig.interstitialIdAndroid;
    if (Platform.isIOS) return AppConfig.interstitialIdIos;
    return AppConfig.interstitialIdAndroid;
  }

  String get rewardedAdUnitId {
    if (Platform.isAndroid) return AppConfig.rewardedAdIdAndroid;
    if (Platform.isIOS) return AppConfig.rewardedAdIdIos;
    return AppConfig.rewardedAdIdAndroid;
  }

  void _loadInterstitialAd() {
    if (!_isInitialized || !AppConfig.adsEnabled || kIsWeb) return;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitialAd({VoidCallback? onAdDismissed}) {
    if (_interstitialAd != null && AppConfig.adsEnabled) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd();
          onAdDismissed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadInterstitialAd();
          onAdDismissed?.call();
        },
      );
      _interstitialAd!.show();
    } else {
      onAdDismissed?.call();
      _loadInterstitialAd();
    }
  }

  void _loadRewardedAd() {
    if (!_isInitialized || !AppConfig.adsEnabled || kIsWeb) return;
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
        },
      ),
    );
  }

  void showRewardedAd({
    required Function(RewardItem reward) onUserEarnedReward,
    VoidCallback? onAdFailed,
  }) {
    if (_rewardedAd != null && AppConfig.adsEnabled) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadRewardedAd();
          onAdFailed?.call();
        },
      );
      _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        onUserEarnedReward(reward);
      });
    } else {
      // Fallback in dev/test mode if ad fails to load: grant reward anyway
      onUserEarnedReward(RewardItem(1, 'fallback_reward'));
      _loadRewardedAd();
    }
  }
}
