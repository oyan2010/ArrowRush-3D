import '../../data/models/arrow_model.dart';
import 'collision_checker.dart';

/// Calculates hints for the player by finding an arrow that can be cleared safely.
class HintCalculator {
  const HintCalculator._();

  /// Finds the first arrow in [arrows] that is not cleared and has an unobstructed exit path.
  /// Returns `null` if no safe arrow exists (or all are cleared).
  static ArrowModel? findSafeArrow(
    List<ArrowModel> arrows,
    int rows,
    int cols,
  ) {
    for (final arrow in arrows) {
      if (arrow.isCleared) continue;
      if (CollisionChecker.isPathClear(arrow, arrows, rows, cols)) {
        return arrow;
      }
    }
    return null;
  }
}
