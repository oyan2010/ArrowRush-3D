import 'package:flutter/services.dart';

/// Service managing device haptics and vibration.
class HapticService {
  bool isEnabled = true;

  HapticService();

  void tapFeedback() {
    if (!isEnabled) return;
    HapticFeedback.lightImpact();
  }

  void collisionFeedback() {
    if (!isEnabled) return;
    HapticFeedback.heavyImpact();
  }

  void successFeedback() {
    if (!isEnabled) return;
    HapticFeedback.mediumImpact();
  }
}
