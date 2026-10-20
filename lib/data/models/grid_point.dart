/// Represents a single cell position on the game grid.
class GridPoint {
  final int row;
  final int col;

  const GridPoint(this.row, this.col);

  GridPoint operator +(GridPoint other) => GridPoint(row + other.row, col + other.col);
  GridPoint operator -(GridPoint other) => GridPoint(row - other.row, col - other.col);

  bool isInBounds(int rows, int cols) =>
      row >= 0 && row < rows && col >= 0 && col < cols;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPoint && row == other.row && col == other.col;

  @override
  int get hashCode => row.hashCode ^ (col.hashCode * 31);

  @override
  String toString() => 'GridPoint($row, $col)';
}
