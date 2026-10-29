import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/ui/app_network_image.dart';
import '../../../../core/ui/rating_stars.dart';
import '../../../../core/ui/shimmer.dart';
import '../../../../core/ui/status_views.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/product.dart';
import '../bloc/product_detail_bloc.dart';
import '../bloc/product_detail_event.dart';
import '../bloc/product_detail_state.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({
    super.key,
    required this.productId,
    this.initialProduct,
  });

  final int productId;
  final Product? initialProduct;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ProductDetailBloc>()..add(ProductDetailRequested(productId)),
      child: _ProductDetailView(
        productId: productId,
        initialProduct: initialProduct,
      ),
    );
  }
}

class _ProductDetailView extends StatefulWidget {
  const _ProductDetailView({required this.productId, this.initialProduct});

  final int productId;
  final Product? initialProduct;

  @override
  State<_ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<_ProductDetailView> {
  int _selectedImage = 0;

  void _retry() => context.read<ProductDetailBloc>().add(
    ProductDetailRequested(widget.productId),
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductDetailBloc, ProductDetailState>(
      listenWhen: (previous, current) =>
          previous.status != ProductDetailStatus.error &&
          current.status == ProductDetailStatus.error &&
          (current.product ?? widget.initialProduct) != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? 'Could not refresh this product.',
              ),
            ),
          );
      },
      builder: (context, state) {
        final product = state.product ?? widget.initialProduct;

        if (product == null) {
          if (state.status == ProductDetailStatus.error) {
            return _buildError(context, state.errorMessage);
          }
          return const _DetailLoading();
        }

        return _DetailContent(
          product: product,
          selectedImage: _selectedImage.clamp(0, product.gallery.length - 1),
          onSelectImage: (index) => setState(() => _selectedImage = index),
        );
      },
    );
  }

  Widget _buildError(BuildContext context, String? message) {
    return Scaffold(
      appBar: _detailAppBar(context, null),
      body: Center(
        child: SingleChildScrollView(
          child: ErrorStateView(
            title: 'This product slipped away',
            message:
                message ?? 'We could not load this product. Please try again.',
            onRetry: _retry,
          ),
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.product,
    required this.selectedImage,
    required this.onSelectImage,
  });

  final Product product;
  final int selectedImage;
  final ValueChanged<int> onSelectImage;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 980;
    final pagePadding = wide ? 40.0 : 18.0;

    return Scaffold(
      appBar: _detailAppBar(context, product),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          pagePadding,
          wide ? 10 : 4,
          pagePadding,
          MediaQuery.paddingOf(context).bottom + 48,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1220),
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 11,
                        child: _Gallery(
                          product: product,
                          selectedImage: selectedImage,
                          onSelectImage: onSelectImage,
                        ),
                      ),
                      const SizedBox(width: 54),
                      Expanded(
                        flex: 9,
                        child: _Details(product: product, wide: true),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Gallery(
                        product: product,
                        selectedImage: selectedImage,
                        onSelectImage: onSelectImage,
                      ),
                      const SizedBox(height: 28),
                      _Details(product: product, wide: false),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

PreferredSizeWidget _detailAppBar(BuildContext context, Product? product) {
  final theme = Theme.of(context);
  final isLight = theme.brightness == Brightness.light;
  final palette = context.palette;
  return AppBar(
    systemOverlayStyle: (isLight
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light)
        .copyWith(statusBarColor: Colors.transparent),
    leadingWidth: 74,
    leading: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
      child: IconButton(
        tooltip: 'Back',
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/products');
          }
        },
        style: IconButton.styleFrom(
          backgroundColor: palette.surface,
          side: BorderSide(color: palette.line),
        ),
        icon: const Icon(Icons.arrow_back_rounded, size: 20),
      ),
    ),
    title: Text(
      product == null
          ? 'PRODUCT DETAILS'
          : 'PRODUCT / ${product.category.toUpperCase()}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.labelSmall?.copyWith(
        color: palette.muted,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _Gallery extends StatelessWidget {
  const _Gallery({
    required this.product,
    required this.selectedImage,
    required this.onSelectImage,
  });

  final Product product;
  final int selectedImage;
  final ValueChanged<int> onSelectImage;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final gallery = product.gallery;
    final current = gallery.isEmpty ? '' : gallery[selectedImage];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: palette.line),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'product-image-${product.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: AppNetworkImage(
                        key: ValueKey(current),
                        url: current,
                        cacheKey: 'product-${product.id}',
                      ),
                    ),
                  ),
                ),
                if (product.hasDiscount)
                  Positioned(
                    top: 18,
                    left: 18,
                    child: SoftPill(
                      label: '${product.discountPercentage.round()}% OFF',
                      icon: Icons.local_offer_outlined,
                      background: palette.highlight,
                      foreground:
                          Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : const Color(0xFF0E1A15),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                Positioned(
                  right: 18,
                  bottom: 18,
                  child: SoftPill(
                    label: '${selectedImage + 1} / ${gallery.length}',
                    icon: Icons.photo_library_outlined,
                    background: palette.surface.withValues(alpha: 0.9),
                    foreground: palette.ink,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (gallery.length > 1) ...[
          const SizedBox(height: 14),
          SizedBox(
            height: 68,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: gallery.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final selected = index == selectedImage;
                return Semantics(
                  button: true,
                  selected: selected,
                  label: 'View image ${index + 1}',
                  child: GestureDetector(
                    onTap: () => onSelectImage(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 68,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? palette.highlight
                              : Colors.transparent,
                          width: 1.6,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AppNetworkImage(url: gallery[index]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.product, required this.wide});

  final Product product;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SoftPill(
              label: product.category.toUpperCase(),
              background: palette.highlightSoft,
              foreground: palette.highlight,
            ),
            if (product.brand.isNotEmpty) ...[
              const SizedBox(width: 10),
              Text(
                'BY ${product.brand.toUpperCase()}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: palette.muted,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        Text(
          product.title,
          style: theme.textTheme.displaySmall?.copyWith(
            fontSize: wide ? 46 : 34,
            height: 1.08,
            letterSpacing: wide ? -1.3 : -0.8,
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            RatingStars(rating: product.rating, size: 18),
            _MetaDot(color: palette.muted),
            Text(
              product.isInStock
                  ? '${product.stock} in stock'
                  : 'Currently sold out',
              style: theme.textTheme.bodySmall?.copyWith(
                color: product.isInStock ? palette.success : palette.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
            _MetaDot(color: palette.muted),
            Text(
              'Product #${product.id}',
              style: theme.textTheme.bodySmall?.copyWith(color: palette.muted),
            ),
          ],
        ),
        const SizedBox(height: 26),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatPrice(product.discountedPrice),
              style: theme.textTheme.displaySmall?.copyWith(
                fontSize: wide ? 46 : 38,
                height: 1,
                letterSpacing: -1,
              ),
            ),
            if (product.hasDiscount) ...[
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text(
                  formatPrice(product.price),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: palette.muted,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
            ],
            const Spacer(),
            if (product.hasDiscount && wide)
              SoftPill(
                label:
                    'SAVE ${formatPrice(product.price - product.discountedPrice)}',
                background: palette.accentSoft,
                foreground: palette.accent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
          ],
        ),
        if (product.hasDiscount && !wide) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: SoftPill(
              label:
                  'You save ${formatPrice(product.price - product.discountedPrice)}',
              background: palette.accentSoft,
              foreground: palette.accent,
            ),
          ),
        ],
        const SizedBox(height: 28),
        Divider(color: palette.line, height: 1),
        const SizedBox(height: 28),
        Text(
          'About this piece',
          style: theme.textTheme.titleLarge?.copyWith(
            fontFamily: 'Fraunces',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          product.description.isEmpty
              ? 'No description is available for this product yet.'
              : product.description,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: palette.muted,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _Fact(
              icon: Icons.sell_outlined,
              label: 'BRAND',
              value: product.brand.isEmpty ? 'Unbranded' : product.brand,
            ),
            _Fact(
              icon: Icons.category_outlined,
              label: 'CATEGORY',
              value: _titleCase(product.category),
            ),
            _Fact(
              icon: Icons.inventory_2_outlined,
              label: 'AVAILABILITY',
              value: product.isInStock ? '${product.stock} units' : 'Sold out',
            ),
          ],
        ),
      ],
    );
  }

  String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value
        .split(RegExp(r'[\s-]+'))
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}

class _MetaDot extends StatelessWidget {
  const _MetaDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: palette.muted),
          const SizedBox(height: 10),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: palette.muted,
              fontSize: 9,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLoading extends StatelessWidget {
  const _DetailLoading();

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 980;
    final pagePadding = wide ? 40.0 : 18.0;

    return Scaffold(
      appBar: _detailAppBar(context, null),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(pagePadding, 8, pagePadding, 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1220),
            child: Shimmer(
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 11,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: SkeletonBox(radius: 32),
                          ),
                        ),
                        const SizedBox(width: 54),
                        Expanded(
                          flex: 9,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              SkeletonBox(width: 100, height: 24, radius: 99),
                              SizedBox(height: 26),
                              SkeletonBox(height: 38, radius: 10),
                              SizedBox(height: 12),
                              SkeletonBox(width: 280, height: 38, radius: 10),
                              SizedBox(height: 28),
                              SkeletonBox(width: 160, height: 16, radius: 6),
                              SizedBox(height: 36),
                              SkeletonBox(width: 120, height: 40, radius: 8),
                              SizedBox(height: 36),
                              SkeletonBox(height: 12, radius: 5),
                              SizedBox(height: 10),
                              SkeletonBox(height: 12, radius: 5),
                              SizedBox(height: 10),
                              SkeletonBox(width: 260, height: 12, radius: 5),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        AspectRatio(
                          aspectRatio: 1,
                          child: SkeletonBox(radius: 32),
                        ),
                        SizedBox(height: 28),
                        SkeletonBox(width: 100, height: 24, radius: 99),
                        SizedBox(height: 22),
                        SkeletonBox(height: 32, radius: 9),
                        SizedBox(height: 10),
                        SkeletonBox(width: 240, height: 32, radius: 9),
                        SizedBox(height: 24),
                        SkeletonBox(width: 170, height: 16, radius: 6),
                        SizedBox(height: 32),
                        SkeletonBox(width: 130, height: 38, radius: 8),
                        SizedBox(height: 32),
                        SkeletonBox(height: 12, radius: 5),
                        SizedBox(height: 10),
                        SkeletonBox(height: 12, radius: 5),
                        SizedBox(height: 10),
                        SkeletonBox(width: 220, height: 12, radius: 5),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
