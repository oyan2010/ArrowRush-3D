import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/config/app_config.dart';
import '../../core/services/ad_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/arrow_model.dart';
import '../../data/models/grid_point.dart';
import '../../data/models/level_grid_bounds.dart';
import '../../data/models/level_model.dart';
import '../../data/repositories/level_generator.dart';
import '../../domain/engine/collision_checker.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../widgets/clay_arrow_painter.dart';
import '../widgets/clay_button.dart';
import '../widgets/clay_card.dart';
import '../widgets/heart_counter.dart';
import '../widgets/how_to_play_dialog.dart';
import '../widgets/out_of_lives_modal.dart';

class _ActiveSlither {
  final String arrowId;
  final ArrowModel arrow;
  final List<GridPoint> nodes;
  final AnimationController controller;

  _ActiveSlither({
    required this.arrowId,
    required this.arrow,
    required this.nodes,
    required this.controller,
  });
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final Map<String, _ActiveSlither> _slitheringArrows = {};
  bool _checkedTutorial = false;
  final TransformationController _transformationController = TransformationController();

  @override
  void dispose() {
    for (final s in _slitheringArrows.values) {
      s.controller.dispose();
    }
    _slitheringArrows.clear();
    _transformationController.dispose();
    super.dispose();
  }

  void _checkFirstTimeTutorial(BuildContext context) {
    if (_checkedTutorial) return;
    _checkedTutorial = true;
    final storage = context.read<StorageService>();
    if (!storage.hasSeenTutorial) {
      storage.setHasSeenTutorial(true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showDialog(context: context, builder: (_) => const HowToPlayDialog());
        }
      });
    }
  }

  void _handleArrowTap(BuildContext context, ArrowModel arrow, int rows, int cols) {
    // If this arrow is already slithering, skip
    if (_slitheringArrows.containsKey(arrow.id)) return;

    final bloc = context.read<GameBloc>();
    final state = bloc.state;
    if (state.status != GameStatus.playing || state.level == null) return;

    // Filter active arrows: uncleared and NOT currently slithering
    final activeArrows = state.arrows
        .where((a) => !a.isCleared && !_slitheringArrows.containsKey(a.id))
        .toList();

    final isBlocked = CollisionChecker.isBlocked(arrow, activeArrows, rows, cols);

    if (!isBlocked) {
      // Create dedicated animation controller for multi-arrow parallel slithering (950ms relaxed speed)
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 950),
      );

      final slither = _ActiveSlither(
        arrowId: arrow.id,
        arrow: arrow,
        nodes: List<GridPoint>.from(arrow.pathNodes),
        controller: controller,
      );

      setState(() {
        _slitheringArrows[arrow.id] = slither;
      });

      // Immediately notify bloc so target arrow is marked cleared in state
      bloc.add(TapArrow(arrow.id));

      controller.forward().then((_) {
        if (mounted) {
          setState(() {
            _slitheringArrows.remove(arrow.id);
          });
          controller.dispose();
        }
      });
    } else {
      bloc.add(TapArrow(arrow.id));
    }
  }

  /// True Snake-on-Tracks Slithering Animation:
  /// The body of the arrow [P0, P1, P2... Pn-1] acts as a track.
  /// As progress t increases from 0 to 1, the head (P0) moves forward along exitDirection.
  /// Every body/tail node i follows the track behind P0, turning precisely at every corner
  /// along the arrow's original body path before turning onto the exit ray!
  List<Offset> _slitheredOffsets(
    List<GridPoint> orig,
    ExitDirection dir,
    double t,
  ) {
    final n = orig.length;
    if (n == 0) return const [];

    final stepDir = dir.step;
    final totalDist = n + 14.0;
    final headDist = t * totalDist;

    final result = List<Offset>.filled(n, Offset.zero, growable: false);

    for (int i = 0; i < n; i++) {
      final s = headDist - i;

      if (s >= 0) {
        final r = orig[0].row + stepDir.row * s;
        final c = orig[0].col + stepDir.col * s;
        result[i] = Offset(c, r);
      } else {
        final b = -s;
        final k = b.floor();

        if (k >= n - 1) {
          result[i] = Offset(orig[n - 1].col.toDouble(), orig[n - 1].row.toDouble());
        } else {
          final frac = b - k;
          final pK = orig[k];
          final pK1 = orig[k + 1];
          final r = pK.row + (pK1.row - pK.row) * frac;
          final c = pK.col + (pK1.col - pK.col) * frac;
          result[i] = Offset(c, r);
        }
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.read<StorageService>();

    return BlocConsumer<GameBloc, GameState>(
      listener: (context, state) {
        _checkFirstTimeTutorial(context);
        if (state.status == GameStatus.outOfLives) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => OutOfLivesModal(
              onWatchAd: () {
                Navigator.pop(context);
                context.read<GameBloc>().add(const AddLives(count: 1));
              },
              onRestart: () {
                Navigator.pop(context);
                context.read<GameBloc>().add(const RestartLevel());
              },
            ),
          );
        } else if (state.status == GameStatus.won) {
          _showWinDialog(context, state, storage);
        }
      },
      builder: (context, state) {
        if (state.level == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final level = state.level!;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final shapeCells = LevelGenerator.getValidShapeCells(level.boardShape, level.rows, level.cols);
        final bounds = LevelGridBounds.fromActiveCells(shapeCells, level.rows, level.cols);

        return Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ─────────────────────────────────────────────
                LayoutBuilder(
                  builder: (context, hc) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      child: Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                            onPressed: () => Navigator.pop(context),
                          ),
                          HeartCounter(lives: state.lives),
                          const Spacer(),
                          Text(
                            level.levelIndex > 0
                                ? 'Level ${level.levelIndex}'
                                : '${level.difficultyTier.displayName.toUpperCase()} MODE',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          const Spacer(),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 36),
                            icon: const Icon(Icons.center_focus_strong_rounded, size: 19, color: AppColors.accent),
                            onPressed: () => _transformationController.value = Matrix4.identity(),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 36),
                            icon: const Icon(Icons.help_outline_rounded, size: 20, color: AppColors.accent),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (_) => const HowToPlayDialog(),
                            ),
                          ),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 36),
                                icon: const Icon(Icons.lightbulb_rounded, size: 22, color: AppColors.hintGlow),
                                onPressed: () {
                                  if (state.hintsRemaining > 0) {
                                    context.read<GameBloc>().add(const UseHint());
                                  } else {
                                    AdService.instance.showRewardedAd(
                                      onUserEarnedReward: (_) {
                                        context.read<GameBloc>().add(const AddHints(count: 2));
                                      },
                                    );
                                  }
                                },
                              ),
                              if (state.hintsRemaining > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: CircleAvatar(
                                    radius: 7,
                                    backgroundColor: AppColors.accent,
                                    child: Text(
                                      '${state.hintsRemaining}',
                                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // ── Board ──────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: LayoutBuilder(
                      builder: (ctx, bc) {
                        final cellW = bc.maxWidth / bounds.widthCols;
                        final cellH = bc.maxHeight / bounds.heightRows;
                        final cellSize = math.min(cellW, cellH).clamp(18.0, 52.0);
                        final boardW = bounds.widthCols * cellSize;
                        final boardH = bounds.heightRows * cellSize;

                        return InteractiveViewer(
                          transformationController: _transformationController,
                          minScale: 0.7,
                          maxScale: 3.0,
                          clipBehavior: Clip.none,
                          boundaryMargin: const EdgeInsets.all(24),
                          child: Center(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapDown: (d) {
                                final tp = d.localPosition;
                                final tapRow = bounds.minRow + (tp.dy / cellSize).floor();
                                final tapCol = bounds.minCol + (tp.dx / cellSize).floor();
                                for (final arrow in state.arrows.reversed) {
                                  if (arrow.isCleared) continue;
                                  for (final node in arrow.pathNodes) {
                                    if (node.row == tapRow && node.col == tapCol) {
                                      _handleArrowTap(context, arrow, level.rows, level.cols);
                                      return;
                                    }
                                  }
                                }
                              },
                              child: Container(
                                width: boardW,
                                height: boardH,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1A1F36)
                                      : const Color(0xFFF0F4F8),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Stack(
                                  clipBehavior: Clip.hardEdge,
                                  children: [
                                    // LAYER 1: Grid dots
                                    RepaintBoundary(
                                      child: CustomPaint(
                                        size: Size(boardW, boardH),
                                        painter: _GridDotsPainter(
                                          shapeCells: shapeCells,
                                          bounds: bounds,
                                          cellSize: cellSize,
                                          isDark: isDark,
                                        ),
                                      ),
                                    ),

                                    // LAYER 2: Static active arrows (not currently slithering)
                                    RepaintBoundary(
                                      child: CustomPaint(
                                        size: Size(boardW, boardH),
                                        painter: _BoardArrowsPainter(
                                          arrows: state.arrows
                                              .where((a) => !a.isCleared && !_slitheringArrows.containsKey(a.id))
                                              .toList(),
                                          bounds: bounds,
                                          cellSize: cellSize,
                                          hintedId: state.hintedArrowId,
                                          collidingId: state.collidingArrowId,
                                        ),
                                      ),
                                    ),

                                    // LAYER 3: Parallel Multi-Arrow Slithering Overlays
                                    if (_slitheringArrows.isNotEmpty)
                                      ..._slitheringArrows.values.map((slither) {
                                        return AnimatedBuilder(
                                          key: ValueKey(slither.arrowId),
                                          animation: slither.controller,
                                          builder: (_, __) {
                                            final t = slither.controller.value;
                                            final offsets = _slitheredOffsets(
                                              slither.nodes,
                                              slither.arrow.exitDirection,
                                              t,
                                            );
                                            final opacity = t < 0.80
                                                ? 1.0
                                                : ((1.0 - t) / 0.20).clamp(0.0, 1.0);
                                            return RepaintBoundary(
                                              child: CustomPaint(
                                                size: Size(boardW, boardH),
                                                painter: ClayArrowPainter(
                                                  arrow: slither.arrow,
                                                  cellSize: cellSize,
                                                  bounds: bounds,
                                                  isAnimating: true,
                                                  opacity: opacity,
                                                  overrideOffsets: offsets,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showWinDialog(BuildContext context, GameState state, StorageService storage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClayCard(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: 28,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded, color: AppColors.hintGlow, size: 72),
              const SizedBox(height: 12),
              const Text('CLEARED!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.success)),
              const SizedBox(height: 20),
              ClayButton(
                color: AppColors.accent,
                icon: Icons.navigate_next_rounded,
                text: 'NEXT LEVEL',
                onTap: () {
                  Navigator.pop(context);
                  final lvl = state.level?.levelIndex ?? 1;
                  if (AppConfig.showInterstitialBetweenLevels &&
                      !storage.adsRemoved &&
                      lvl > 0 &&
                      lvl % AppConfig.interstitialFrequency == 0) {
                    AdService.instance.showInterstitialAd(
                      onAdDismissed: () => context.read<GameBloc>().add(const NextLevel()),
                    );
                  } else {
                    context.read<GameBloc>().add(const NextLevel());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridDotsPainter extends CustomPainter {
  final Set<GridPoint> shapeCells;
  final LevelGridBounds bounds;
  final double cellSize;
  final bool isDark;

  const _GridDotsPainter({
    required this.shapeCells,
    required this.bounds,
    required this.cellSize,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dotR = (cellSize * 0.07).clamp(1.5, 3.5);
    final paint = Paint()
      ..color = isDark ? const Color(0xFF3D4A6B) : const Color(0xFFBBCCDD)
      ..style = PaintingStyle.fill;

    for (final pt in shapeCells) {
      final cx = (pt.col - bounds.minCol) * cellSize + cellSize / 2;
      final cy = (pt.row - bounds.minRow) * cellSize + cellSize / 2;
      canvas.drawCircle(Offset(cx, cy), dotR, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridDotsPainter old) =>
      old.shapeCells != shapeCells || old.cellSize != cellSize || old.isDark != isDark;
}

class _BoardArrowsPainter extends CustomPainter {
  final List<ArrowModel> arrows;
  final LevelGridBounds bounds;
  final double cellSize;
  final String? hintedId;
  final String? collidingId;

  const _BoardArrowsPainter({
    required this.arrows,
    required this.bounds,
    required this.cellSize,
    this.hintedId,
    this.collidingId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final arrow in arrows) {
      ClayArrowPainter(
        arrow: arrow,
        cellSize: cellSize,
        bounds: bounds,
        isHinted: hintedId == arrow.id,
        isColliding: collidingId == arrow.id,
      ).paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant _BoardArrowsPainter old) =>
      old.arrows != arrows ||
      old.cellSize != cellSize ||
      old.bounds != bounds ||
      old.hintedId != hintedId ||
      old.collidingId != collidingId;
}
