import 'package:flutter/material.dart';

/// Subtle pointer hover lift for desktop and web. On touch devices the child
/// behaves exactly as normal.
class HoverLift extends StatefulWidget {
  const HoverLift({super.key, required this.child, this.borderRadius = 24});

  final Widget child;
  final double borderRadius;

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hovered ? -5 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.11),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ]
              : const [],
        ),
        child: widget.child,
      ),
    );
  }
}
