import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The Mercato monogram: a soft forest-green tile with a serif "m" and a small
/// clay dot.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 44, this.inverted = false});

  final double size;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final foreground = inverted ? AppColors.forestDeep : AppColors.cream;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: inverted
                    ? const [AppColors.cream, AppColors.sand]
                    : const [AppColors.forest, AppColors.forestDeep],
              ),
              borderRadius: BorderRadius.circular(size * 0.3),
              boxShadow: inverted
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.forestDeep.withValues(alpha: 0.22),
                        blurRadius: size * 0.4,
                        offset: Offset(0, size * 0.14),
                      ),
                    ],
            ),
            alignment: Alignment.center,
            child: Text(
              'm',
              style: TextStyle(
                fontFamily: 'Fraunces',
                fontSize: size * 0.62,
                height: 0.95,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
          Positioned(
            right: -size * 0.06,
            top: -size * 0.06,
            child: Container(
              width: size * 0.22,
              height: size * 0.22,
              decoration: BoxDecoration(
                color: AppColors.clay,
                shape: BoxShape.circle,
                border: Border.all(
                  color: inverted ? AppColors.forestDeep : AppColors.cream,
                  width: size * 0.035,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.inverted = false, this.subtitle});

  final bool inverted;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = inverted ? AppColors.cream : theme.colorScheme.onSurface;
    final muted = inverted
        ? AppColors.cream.withValues(alpha: 0.65)
        : theme.textTheme.bodySmall?.color;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandMark(inverted: inverted),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mercato',
              style: theme.textTheme.titleLarge?.copyWith(
                fontFamily: 'Fraunces',
                fontWeight: FontWeight.w600,
                color: color,
                height: 1,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: muted,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
