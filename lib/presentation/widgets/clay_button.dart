import 'package:flutter/material.dart';
import '../../core/theme/clay_decoration.dart';

/// Claymorphic 3D interactive button with spring animation feedback.
class ClayButton extends StatefulWidget {
  final Widget? child;
  final String? text;
  final IconData? icon;
  final Color color;
  final Color textColor;
  final VoidCallback? onTap;
  final double height;
  final double? width;
  final double borderRadius;

  const ClayButton({
    super.key,
    this.child,
    this.text,
    this.icon,
    required this.color,
    this.textColor = Colors.white,
    this.onTap,
    this.height = 54.0,
    this.width,
    this.borderRadius = 20.0,
  });

  @override
  State<ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: widget.height,
        width: widget.width,
        decoration: ClayDecoration.clay(
          color: widget.color,
          borderRadius: widget.borderRadius,
          isPressed: _isPressed,
          depth: _isPressed ? 2.0 : 6.0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Center(
          child: widget.child ??
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: widget.textColor, size: 24),
                    const SizedBox(width: 8),
                  ],
                  if (widget.text != null)
                    Text(
                      widget.text!,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
        ),
      ),
    );
  }
}
