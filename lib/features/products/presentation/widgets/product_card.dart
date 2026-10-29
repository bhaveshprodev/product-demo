import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/ui/app_network_image.dart';
import '../../../../core/ui/hover_lift.dart';
import '../../../../core/ui/rating_stars.dart';
import '../../../../core/ui/status_views.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return HoverLift(
      child: Material(
        color: palette.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: palette.line),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'product-image-${product.id}',
                      child: AppNetworkImage(
                        url: product.primaryImage,
                        cacheKey: 'product-${product.id}',
                      ),
                    ),
                    if (product.hasDiscount)
                      Positioned(
                        left: 12,
                        top: 12,
                        child: SoftPill(
                          label: '-${product.discountPercentage.round()}%',
                          background: palette.highlight,
                          foreground:
                              Theme.of(context).brightness == Brightness.light
                              ? Colors.white
                              : const Color(0xFF0E1A15),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                        ),
                      ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: palette.surface.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_outward_rounded,
                          size: 17,
                          color: palette.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final contentWidth = constraints.maxWidth - 28;
                    final tight = contentWidth < 130;
                    final veryTight = contentWidth < 120;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.category.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: palette.muted,
                              fontSize: 9.5,
                              letterSpacing: 1.1,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Row(
                            children: [
                              RatingStars(rating: product.rating, size: 13),
                              const Spacer(),
                              if (!tight)
                                Text(
                                  '${product.stock} left',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: palette.muted,
                                    fontSize: 10,
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                flex: 3,
                                child: Text(
                                  formatPrice(product.discountedPrice),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontSize: tight ? 15 : 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                              ),
                              if (product.hasDiscount && !veryTight) ...[
                                const SizedBox(width: 6),
                                Flexible(
                                  flex: 2,
                                  child: Text(
                                    formatPrice(product.price),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        theme.textTheme.bodySmall?.copyWith(
                                      color: palette.muted,
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
