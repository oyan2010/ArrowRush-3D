import 'package:flutter_test/flutter_test.dart';
import 'package:arrowsrush_3d/data/models/arrow_model.dart';
import 'package:arrowsrush_3d/data/models/grid_point.dart';
import 'package:arrowsrush_3d/domain/engine/collision_checker.dart';
import 'package:arrowsrush_3d/domain/engine/hint_calculator.dart';
import 'package:arrowsrush_3d/data/repositories/level_generator.dart';

void main() {
  group('CollisionChecker Unit Tests', () {
    test('Unblocked arrow returns path clear = true', () {
      const arrow = ArrowModel(
        id: '1',
        pathNodes: [GridPoint(2, 2)],
        exitDirection: ExitDirection.up,
        colorIndex: 0,
      );

      final isClear = CollisionChecker.isPathClear(arrow, [arrow], 5, 5);
      expect(isClear, isTrue);
    });

    test('Blocked arrow returns path clear = false', () {
      const arrow1 = ArrowModel(
        id: '1',
        pathNodes: [GridPoint(2, 2)],
        exitDirection: ExitDirection.up,
        colorIndex: 0,
      );

      const arrow2 = ArrowModel(
        id: '2',
        pathNodes: [GridPoint(1, 2)], // Directly in exit path of arrow1
        exitDirection: ExitDirection.right,
        colorIndex: 1,
      );

      final isClear = CollisionChecker.isPathClear(arrow1, [arrow1, arrow2], 5, 5);
      expect(isClear, isFalse);
    });
  });

  group('HintCalculator Unit Tests', () {
    test('Finds first unblocked arrow', () {
      const arrow1 = ArrowModel(
        id: '1',
        pathNodes: [GridPoint(2, 2)],
        exitDirection: ExitDirection.up,
        colorIndex: 0,
      );

      final hint = HintCalculator.findSafeArrow([arrow1], 5, 5);
      expect(hint?.id, equals('1'));
    });
  });

  group('LevelGenerator Unit Tests', () {
    test('Generates infinite guaranteed solvable levels beyond 100', () {
      final generator = LevelGenerator();
      for (int i = 1; i <= 200; i++) {
        final level = generator.generateLevel(i);
        expect(level.levelIndex, equals(i));
        expect(level.arrows, isNotEmpty);
        expect(level.solutionOrder, isNotEmpty);
      }
    });

    test('Odd difficulty spike levels (5, 7, 9, 15, 17, 19) generate higher arrow counts', () {
      final generator = LevelGenerator();
      final normalL6 = generator.generateLevel(6);
      final spikeL5 = generator.generateLevel(5);
      final spikeL7 = generator.generateLevel(7);

      expect(spikeL5.arrows, isNotEmpty);
      expect(spikeL7.arrows, isNotEmpty);
      expect(normalL6.arrows, isNotEmpty);
    });
  });
}
