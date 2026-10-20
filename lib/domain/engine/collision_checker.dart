import '../../data/models/arrow_model.dart';
import '../../data/models/grid_point.dart';

/// Checks whether an arrow's exit path is clear of other active arrows.
class CollisionChecker {
  const CollisionChecker._();

  /// Returns `true` if [target]'s exit ray is blocked by any non-cleared arrow
  /// in [others]. The ray traces from tip+1 step in [target.exitDirection]
  /// to the grid boundary.
  static bool isBlocked(
    ArrowModel target,
    List<ArrowModel> others,
    int rows,
    int cols,
  ) {
    // Build a set of all occupied cells from active (non-cleared) other arrows
    final occupiedCells = <GridPoint>{};
    for (final arrow in others) {
      if (arrow.id == target.id || arrow.isCleared) continue;
      occupiedCells.addAll(arrow.pathNodes);
    }

    // Raycast from tip in exit direction to grid edge
    final step = target.exitDirection.step;
    var current = target.tipPoint + step;

    while (current.isInBounds(rows, cols)) {
      if (occupiedCells.contains(current)) {
        return true; // Blocked!
      }
      current = current + step;
    }

    return false; // Clear path
  }

  /// Returns `true` if [target] can be safely cleared (path is NOT blocked).
  static bool isPathClear(
    ArrowModel target,
    List<ArrowModel> others,
    int rows,
    int cols,
  ) {
    return !isBlocked(target, others, rows, cols);
  }
}
