import 'arrow_model.dart';
import 'grid_point.dart';

/// Calculates tight bounding box around active cells or arrows in a level grid.
class LevelGridBounds {
  final int minCol;
  final int maxCol;
  final int minRow;
  final int maxRow;

  const LevelGridBounds({
    required this.minCol,
    required this.maxCol,
    required this.minRow,
    required this.maxRow,
  });

  int get widthCols => (maxCol >= minCol) ? maxCol - minCol + 1 : 1;
  int get heightRows => (maxRow >= minRow) ? maxRow - minRow + 1 : 1;

  /// Calculate bounding box from a set of active shape GridPoints
  factory LevelGridBounds.fromActiveCells(Set<GridPoint> cells, int defaultRows, int defaultCols) {
    if (cells.isEmpty) {
      return LevelGridBounds(
        minCol: 0,
        maxCol: defaultCols - 1,
        minRow: 0,
        maxRow: defaultRows - 1,
      );
    }

    int minC = 999, maxC = -999, minR = 999, maxR = -999;
    for (final pt in cells) {
      if (pt.col < minC) minC = pt.col;
      if (pt.col > maxC) maxC = pt.col;
      if (pt.row < minR) minR = pt.row;
      if (pt.row > maxR) maxR = pt.row;
    }

    return LevelGridBounds(
      minCol: minC,
      maxCol: maxC,
      minRow: minR,
      maxRow: maxR,
    );
  }

  /// Calculate bounding box from all active arrow nodes in a level
  factory LevelGridBounds.fromArrows(List<ArrowModel> arrows, int defaultRows, int defaultCols) {
    if (arrows.isEmpty) {
      return LevelGridBounds(
        minCol: 0,
        maxCol: defaultCols - 1,
        minRow: 0,
        maxRow: defaultRows - 1,
      );
    }

    int minC = 999, maxC = -999, minR = 999, maxR = -999;
    for (final arrow in arrows) {
      for (final pt in arrow.pathNodes) {
        if (pt.col < minC) minC = pt.col;
        if (pt.col > maxC) maxC = pt.col;
        if (pt.row < minR) minR = pt.row;
        if (pt.row > maxR) maxR = pt.row;
      }
    }

    return LevelGridBounds(
      minCol: minC,
      maxCol: maxC,
      minRow: minR,
      maxRow: maxR,
    );
  }
}
