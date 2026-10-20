import 'package:audioplayers/audioplayers.dart';
import '../config/app_config.dart';

/// Audio service for playing sound effects.
/// Safe against missing asset files (silently catches exceptions).
class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool isEnabled = true;

  AudioService();

  Future<void> _playSound(String assetPath) async {
    if (!isEnabled || assetPath.isEmpty) return;
    try {
      // Remove 'assets/' prefix if needed by AssetSource
      final relativePath = assetPath.startsWith('assets/')
          ? assetPath.substring(7)
          : assetPath;
      await _player.stop();
      await _player.play(AssetSource(relativePath));
    } catch (_) {
      // Asset might be missing in developer placeholder mode. Graceful fallback.
    }
  }

  void playTap() => _playSound(AppConfig.tapSound);
  void playLaunch() => _playSound(AppConfig.launchSound);
  void playPop() => _playSound(AppConfig.popSound);
  void playCollision() => _playSound(AppConfig.collisionSound);
  void playWin() => _playSound(AppConfig.winSound);
  void playHint() => _playSound(AppConfig.hintSound);

  void dispose() {
    _player.dispose();
  }
}
