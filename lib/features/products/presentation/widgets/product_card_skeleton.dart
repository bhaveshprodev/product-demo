import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/ui/shimmer.dart';

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.line),
      ),
      child: Shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AspectRatio(aspectRatio: 1, child: SkeletonBox(radius: 0)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonBox(width: 64, height: 8, radius: 4),
                    SizedBox(height: 12),
                    SkeletonBox(height: 12, radius: 5),
                    SizedBox(height: 8),
                    SkeletonBox(width: 110, height: 12, radius: 5),
                    Spacer(),
                    Row(
                      children: [
                        SkeletonBox(width: 74, height: 10, radius: 4),
                        Spacer(),
                        SkeletonBox(width: 52, height: 16, radius: 5),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
