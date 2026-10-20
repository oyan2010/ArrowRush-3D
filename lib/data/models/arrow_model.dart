import 'dart:ui';
import 'grid_point.dart';

/// Direction an arrow flies when tapped.
enum ExitDirection {
  up,
  down,
  left,
  right;

  /// Unit step in this direction as a GridPoint offset.
  GridPoint get step {
    switch (this) {
      case ExitDirection.up:
        return const GridPoint(-1, 0);
      case ExitDirection.down:
        return const GridPoint(1, 0);
      case ExitDirection.left:
        return const GridPoint(0, -1);
      case ExitDirection.right:
        return const GridPoint(0, 1);
    }
  }

  /// Opposite direction.
  ExitDirection get opposite {
    switch (this) {
      case ExitDirection.up:
        return ExitDirection.down;
      case ExitDirection.down:
        return ExitDirection.up;
      case ExitDirection.left:
        return ExitDirection.right;
      case ExitDirection.right:
        return ExitDirection.left;
    }
  }
}

/// A single arrow on the game board.
class ArrowModel {
  final String id;
  final List<GridPoint> pathNodes;
  final ExitDirection exitDirection;
  final int colorIndex;
  final bool isCleared;
  final bool isColliding;

  // Cached path map for different cell sizes
  static final Map<String, Path> _pathCache = {};

  const ArrowModel({
    required this.id,
    required this.pathNodes,
    required this.exitDirection,
    required this.colorIndex,
    this.isCleared = false,
    this.isColliding = false,
  });

  /// The tip (head) of the arrow — the cell from which the exit ray is cast.
  GridPoint get tipPoint => pathNodes.first;

  /// Returns a pre-computed or cached Path for rendering at a given [cellSize].
  Path getCachedPath(double cellSize) {
    final key = '${id}_${cellSize.toStringAsFixed(1)}';
    if (_pathCache.containsKey(key)) {
      return _pathCache[key]!;
    }

    final path = Path();
    if (pathNodes.isNotEmpty) {
      final firstPoint = Offset(
        pathNodes.first.col * cellSize + cellSize / 2,
        pathNodes.first.row * cellSize + cellSize / 2,
      );
      path.moveTo(firstPoint.dx, firstPoint.dy);

      for (int i = 1; i < pathNodes.length; i++) {
        final p = Offset(
          pathNodes[i].col * cellSize + cellSize / 2,
          pathNodes[i].row * cellSize + cellSize / 2,
        );
        path.lineTo(p.dx, p.dy);
      }
    }

    _pathCache[key] = path;
    return path;
  }

  /// Create a copy with optional field overrides.
  ArrowModel copyWith({
    bool? isCleared,
    bool? isColliding,
  }) {
    return ArrowModel(
      id: id,
      pathNodes: pathNodes,
      exitDirection: exitDirection,
      colorIndex: colorIndex,
      isCleared: isCleared ?? this.isCleared,
      isColliding: isColliding ?? this.isColliding,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ArrowModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
