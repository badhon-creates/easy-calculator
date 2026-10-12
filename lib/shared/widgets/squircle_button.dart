import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_calculator/core/theme/squircle_border.dart';

enum SquircleButtonVariant { number, operator, function }

/// A reusable calculator button component featuring squircle/superellipse geometry.
class SquircleButton extends StatefulWidget {
  const SquircleButton({
    super.key,
    this.text,
    this.icon,
    required this.onTap,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
    this.fontSize = 28.0,
    this.fontWeight = FontWeight.w500,
    this.semanticLabel,
    this.flex = 1,
  }) : assert(
         text != null || icon != null,
         'Either text or icon must be provided',
       );

  final String? text;
  final IconData? icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final double fontSize;
  final FontWeight fontWeight;
  final String? semanticLabel;
  final int flex;

  @override
  State<SquircleButton> createState() => _SquircleButtonState();
}

class _SquircleButtonState extends State<SquircleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    _animController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails _) {
    _animController.reverse();
  }

  void _handleTapCancel() {
    _animController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final borderSide =
        widget.borderColor != null && widget.borderColor != Colors.transparent
        ? BorderSide(color: widget.borderColor!, width: 1.0)
        : BorderSide.none;

    final shape = SquircleBorder(
      side: borderSide,
      radius: 22.0,
      smoothness: 0.85,
    );

    return Semantics(
      button: true,
      label: widget.semanticLabel ?? widget.text,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) =>
              Transform.scale(scale: _scaleAnimation.value, child: child),
          child: Material(
            color: widget.backgroundColor,
            shape: shape,
            clipBehavior: Clip.antiAlias,
            elevation: 0,
            child: Center(
              child: widget.icon != null
                  ? Icon(
                      widget.icon,
                      color: widget.foregroundColor,
                      size: widget.fontSize,
                    )
                  : Text(
                      widget.text!,
                      style: TextStyle(
                        color: widget.foregroundColor,
                        fontSize: widget.fontSize,
                        fontWeight: widget.fontWeight,
                        letterSpacing: -0.5,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
