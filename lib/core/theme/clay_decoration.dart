import 'package:flutter/material.dart';

/// Helper to generate Neumorphic & Flat 2.0 BoxDecorations.
class ClayDecoration {
  ClayDecoration._();

  /// Create a soft Neumorphic Flat 2.0 box decoration with dual light & dark drop-shadows.
  static BoxDecoration clay({
    required Color color,
    double borderRadius = 24.0,
    double depth = 5.0,
    bool isPressed = false,
    Color? borderOutline,
  }) {
    final lightShadow = Colors.white.withOpacity(0.45);
    final darkShadow = Colors.black.withOpacity(0.18);

    if (isPressed) {
      return BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderOutline != null ? Border.all(color: borderOutline, width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: darkShadow,
            offset: Offset(depth / 2, depth / 2),
            blurRadius: 4,
          ),
        ],
      );
    }

    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      border: borderOutline != null ? Border.all(color: borderOutline, width: 1.5) : null,
      boxShadow: [
        // Top-Left Light Highlight Shadow (Soft Neumorphism)
        BoxShadow(
          color: lightShadow,
          offset: Offset(-depth, -depth),
          blurRadius: depth * 1.8,
          spreadRadius: 1,
        ),
        // Bottom-Right Dark Ambient Shadow
        BoxShadow(
          color: darkShadow,
          offset: Offset(depth, depth * 1.2),
          blurRadius: depth * 2.2,
          spreadRadius: 1,
        ),
      ],
    );
  }

  /// Neumorphic decoration suited for floating circular buttons.
  static BoxDecoration clayCircle({
    required Color color,
    double depth = 5.0,
    bool isPressed = false,
  }) {
    final lightShadow = Colors.white.withOpacity(0.5);
    final darkShadow = Colors.black.withOpacity(0.2);

    return BoxDecoration(
      shape: BoxShape.circle,
      color: color,
      boxShadow: isPressed
          ? [
              BoxShadow(
                color: darkShadow,
                offset: Offset(depth / 2, depth / 2),
                blurRadius: 4,
              )
            ]
          : [
              BoxShadow(
                color: lightShadow,
                offset: Offset(-depth, -depth),
                blurRadius: depth * 1.8,
              ),
              BoxShadow(
                color: darkShadow,
                offset: Offset(depth, depth * 1.2),
                blurRadius: depth * 2.2,
              ),
            ],
    );
  }
}
