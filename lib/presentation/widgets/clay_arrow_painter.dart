import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/arrow_model.dart';
import '../../data/models/grid_point.dart';
import '../../data/models/level_grid_bounds.dart';

/// Ultra-minimal 2D flat arrow painter.
/// Supports continuous sub-pixel Offset paths for 120fps snake slithering.
class ClayArrowPainter extends CustomPainter {
  final ArrowModel arrow;
  final double cellSize;
  final LevelGridBounds? bounds;
  final bool isHinted;
  final bool isColliding;
  final bool isAnimating;
  final double opacity;
  final List<GridPoint>? overridePathNodes;
  final List<Offset>? overrideOffsets; // Continuous (col, row) grid coordinates

  const ClayArrowPainter({
    required this.arrow,
    required this.cellSize,
    this.bounds,
    this.isHinted = false,
    this.isColliding = false,
    this.isAnimating = false,
    this.opacity = 1.0,
    this.overridePathNodes,
    this.overrideOffsets,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final minC = bounds?.minCol ?? 0;
    final minR = bounds?.minRow ?? 0;
    final half = cellSize / 2;

    // Pick color using original palette
    Color color;
    if (isColliding) {
      color = AppColors.collision;
    } else if (isHinted) {
      color = AppColors.hintGlow;
    } else {
      color = AppColors.getArrowColor(arrow.colorIndex);
    }
    if (opacity < 1.0) color = color.withOpacity(opacity.clamp(0.0, 1.0));

    final strokeW = (cellSize * 0.22).clamp(2.0, 9.0);

    // Build canvas pixel points
    final List<Offset> points;
    if (overrideOffsets != null && overrideOffsets!.isNotEmpty) {
      points = overrideOffsets!.map((p) {
        return Offset(
          (p.dx - minC) * cellSize + half,
          (p.dy - minR) * cellSize + half,
        );
      }).toList();
    } else {
      final nodes = overridePathNodes ?? arrow.pathNodes;
      if (nodes.isEmpty) return;
      points = nodes.map((n) {
        return Offset(
          (n.col - minC) * cellSize + half,
          (n.row - minR) * cellSize + half,
        );
      }).toList();
    }

    if (points.isEmpty) return;

    // ── Body stroke ────────────────────────────────────────────
    // Draw stroke from TAIL (last point) to HEAD (first point)
    final path = Path();
    path.moveTo(points.last.dx, points.last.dy);
    for (int i = points.length - 2; i >= 0; i--) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = strokeW
        ..isAntiAlias = false,
    );

    // ── Arrowhead triangle at the HEAD (points[0]) ───────────────
    final headPt = points.first;
    final hx = headPt.dx;
    final hy = headPt.dy;

    final tipLen   = strokeW * 2.2;
    final wingHalf = strokeW * 0.9;
    final baseBack = strokeW * 0.5;

    double tx, ty;
    double b1x, b1y;
    double b2x, b2y;

    switch (arrow.exitDirection) {
      case ExitDirection.up:
        tx  = hx;             ty  = hy - tipLen;
        b1x = hx - wingHalf;  b1y = hy + baseBack;
        b2x = hx + wingHalf;  b2y = hy + baseBack;
        break;
      case ExitDirection.down:
        tx  = hx;             ty  = hy + tipLen;
        b1x = hx - wingHalf;  b1y = hy - baseBack;
        b2x = hx + wingHalf;  b2y = hy - baseBack;
        break;
      case ExitDirection.left:
        tx  = hx - tipLen;    ty  = hy;
        b1x = hx + baseBack;  b1y = hy - wingHalf;
        b2x = hx + baseBack;  b2y = hy + wingHalf;
        break;
      case ExitDirection.right:
        tx  = hx + tipLen;    ty  = hy;
        b1x = hx - baseBack;  b1y = hy - wingHalf;
        b2x = hx - baseBack;  b2y = hy + wingHalf;
        break;
    }

    final headPath = Path()
      ..moveTo(tx, ty)
      ..lineTo(b1x, b1y)
      ..lineTo(b2x, b2y)
      ..close();

    canvas.drawPath(
      headPath,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..isAntiAlias = false,
    );
  }

  @override
  bool shouldRepaint(covariant ClayArrowPainter old) {
    return old.arrow != arrow ||
        old.cellSize != cellSize ||
        old.bounds != bounds ||
        old.isHinted != isHinted ||
        old.isColliding != isColliding ||
        old.opacity != opacity ||
        old.overridePathNodes != overridePathNodes ||
        old.overrideOffsets != overrideOffsets;
  }
}
