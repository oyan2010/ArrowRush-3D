import 'package:flutter/material.dart';
import '../../core/theme/clay_decoration.dart';

/// Claymorphic 3D Container Card widget.
class ClayCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const ClayCard({
    super.key,
    required this.child,
    required this.color,
    this.borderRadius = 24.0,
    this.padding = const EdgeInsets.all(20.0),
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: ClayDecoration.clay(
        color: color,
        borderRadius: borderRadius,
        depth: 6.0,
      ),
      child: child,
    );
  }
}
