import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/ui/app_avatar.dart';
import '../../../../core/ui/brand_mark.dart';
import '../../../../core/ui/status_views.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../domain/entities/product.dart';
import '../bloc/product_list_bloc.dart';
import '../bloc/product_list_event.dart';
import '../bloc/product_list_state.dart';
import '../widgets/product_card.dart';
import '../widgets/product_card_skeleton.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductListBloc>()..add(const ProductListStarted()),
      child: const _ProductsView(),
    );
  }
}

class _ProductsView extends StatefulWidget {
  const _ProductsView();

  @override
  State<_ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<_ProductsView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted || !_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter > 480) return;

    final bloc = context.read<ProductListBloc>();
    if (bloc.state.canLoadMore) {
      bloc.add(const ProductListLoadMoreRequested());
    }
  }

  Future<void> _confirmLogout() async {
    final palette = context.palette;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(Icons.logout_rounded, color: palette.highlight, size: 28),
        title: const Text('Sign out?'),
        content: const Text(
          'Your saved session will be removed from this device. '
          'You can sign back in at any time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Stay signed in'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<AuthBloc>().add(const LogoutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthBloc, User?>((bloc) => bloc.state.user);

    return BlocConsumer<ProductListBloc, ProductListState>(
      listenWhen: (previous, current) =>
          current.refreshError != null &&
          current.refreshError != previous.refreshError,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.refreshError!)));
      },
      builder: (context, state) {
        final palette = context.palette;
        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final compact = width < 700;
              final contentWidth = math.min(width, 1440.0);
              final sideInset = (width - contentWidth) / 2;
              final horizontal = sideInset + (compact ? 18.0 : 32.0);
              final available = contentWidth - (compact ? 36.0 : 64.0);
              final columns = (available / 230).floor().clamp(2, 6);
              final spacing = compact ? 12.0 : 20.0;
              final cardWidth = (available - spacing * (columns - 1)) / columns;
              final textScale = MediaQuery.textScalerOf(context)
                  .scale(1)
                  .clamp(1.0, 1.35);
              final cardHeight = cardWidth + 156 * textScale;

              return RefreshIndicator(
                color: palette.highlight,
                backgroundColor: palette.surface,
                displacement: 30,
                onRefresh: () => context.read<ProductListBloc>().refresh(),
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(
                      child: SafeArea(
                        bottom: false,
                        child: _ProductsHeader(
                          user: user,
                          total: state.total,
                          status: state.status,
                          compact: compact,
                          horizontalPadding: horizontal,
                          onSignOut: _confirmLogout,
                        ),
                      ),
                    ),
                    ..._buildBody(
                      context,
                      state,
                      columns,
                      spacing,
                      cardWidth,
                      cardHeight,
                      horizontal,
                      compact,
                    ),
                    if (state.status == ProductListStatus.loaded &&
                        state.products.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontal,
                            8,
                            horizontal,
                            MediaQuery.paddingOf(context).bottom + 28,
                          ),
                          child: _PaginationFooter(
                            state: state,
                            onRetry: () => context.read<ProductListBloc>().add(
                              const ProductListLoadMoreRequested(),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<Widget> _buildBody(
    BuildContext context,
    ProductListState state,
    int columns,
    double spacing,
    double cardWidth,
    double cardHeight,
    double horizontal,
    bool compact,
  ) {
    final gridPadding = EdgeInsets.fromLTRB(horizontal, 0, horizontal, 12);

    if (state.status == ProductListStatus.initial ||
        state.status == ProductListStatus.loading) {
      return [
        SliverPadding(
          padding: gridPadding,
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              mainAxisExtent: cardHeight,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => const ProductCardSkeleton(),
              childCount: columns * 2,
            ),
          ),
        ),
      ];
    }

    if (state.status == ProductListStatus.error) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorStateView(
            message:
                state.errorMessage ??
                'We could not load the collection. Please try again.',
            onRetry: () => context.read<ProductListBloc>().add(
              const ProductListRetryRequested(),
            ),
          ),
        ),
      ];
    }

    if (state.products.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyStateView(
            title: 'The edit is empty',
            message:
                'There is nothing in the collection right now. '
                'Pull down to refresh or check back soon.',
            onRefresh: () => context.read<ProductListBloc>().add(
              const ProductListRefreshed(),
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: gridPadding,
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: cardHeight,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final Product product = state.products[index];
            return ProductCard(
              product: product,
              onTap: () =>
                  context.push('/products/${product.id}', extra: product),
            );
          }, childCount: state.products.length),
        ),
      ),
    ];
  }
}

class _ProductsHeader extends StatelessWidget {
  const _ProductsHeader({
    required this.user,
    required this.total,
    required this.status,
    required this.compact,
    required this.horizontalPadding,
    required this.onSignOut,
  });

  final User? user;
  final int total;
  final ProductListStatus status;
  final bool compact;
  final double horizontalPadding;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final isLoading =
        status == ProductListStatus.initial ||
        status == ProductListStatus.loading;
    final hasFailed = status == ProductListStatus.error;
    final countLabel = total > 0
        ? '${formatCount(total)} objects in the edit'
        : isLoading
        ? 'Loading the edit'
        : hasFailed
        ? 'The edit is unavailable'
        : 'The edit is empty';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        18,
        horizontalPadding,
        compact ? 24 : 34,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const BrandWordmark(subtitle: 'CURATED EVERYDAY GOODS'),
              const Spacer(),
              _ProfileMenu(user: user, compact: compact, onSignOut: onSignOut),
            ],
          ),
          SizedBox(height: compact ? 34 : 54),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 22, height: 1, color: palette.accent),
                        const SizedBox(width: 9),
                        Text(
                          user == null
                              ? 'THE DAILY EDIT'
                              : 'HELLO, ${user!.firstName.toUpperCase()}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: palette.muted,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Discover',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: compact ? 48 : 68,
                        height: 0.98,
                        letterSpacing: compact ? -1.6 : -2.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 540),
                      child: Text(
                        'A considered collection of everyday things — '
                        'picked for how they look, feel and last.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: palette.muted,
                          height: 1.6,
                          fontSize: compact ? 14 : 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 32),
                _CatalogueStat(
                  total: total,
                  isLoading: isLoading,
                  hasFailed: hasFailed,
                ),
              ],
            ],
          ),
          const SizedBox(height: 22),
          SoftPill(
            label: countLabel,
            icon: Icons.inventory_2_outlined,
          ),
        ],
      ),
    );
  }
}

class _CatalogueStat extends StatelessWidget {
  const _CatalogueStat({
    required this.total,
    required this.isLoading,
    required this.hasFailed,
  });

  final int total;
  final bool isLoading;
  final bool hasFailed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final value = total > 0
        ? '${formatCount(total)} pieces'
        : isLoading
        ? 'Fetching…'
        : hasFailed
        ? 'Unavailable'
        : 'Nothing yet';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 22, 16),
      decoration: BoxDecoration(
        color: palette.highlightSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: palette.surface.withValues(alpha: 0.65),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_mosaic_outlined,
              size: 19,
              color: palette.highlight,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CATALOGUE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: palette.muted,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _AccountAction { signOut }

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu({
    required this.user,
    required this.compact,
    required this.onSignOut,
  });

  final User? user;
  final bool compact;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final initials = user?.initials ?? 'M';
    final name = user?.fullName ?? 'Guest';

    return PopupMenuButton<_AccountAction>(
      tooltip: 'Account',
      offset: const Offset(0, 52),
      onSelected: (action) {
        if (action == _AccountAction.signOut) onSignOut();
      },
      itemBuilder: (context) => [
        PopupMenuItem<_AccountAction>(
          enabled: false,
          height: 62,
          child: Row(
            children: [
              AppAvatar(
                imageUrl: user?.imageUrl ?? '',
                initials: initials,
                size: 36,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (user != null)
                    Text(
                      user!.email,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.muted,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<_AccountAction>(
          value: _AccountAction.signOut,
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 18),
              SizedBox(width: 10),
              Text('Sign out'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: EdgeInsets.fromLTRB(6, 6, compact ? 8 : 12, 6),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: AppRadii.pill,
          border: Border.all(color: palette.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppAvatar(imageUrl: user?.imageUrl ?? '', initials: initials),
            if (!compact) ...[
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: palette.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({required this.state, required this.onRetry});

  final ProductListState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    if (state.isLoadingMore) {
      return SizedBox(
        height: 64,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: palette.highlight,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Loading more',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.loadMoreError != null) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
        decoration: BoxDecoration(
          color: palette.accentSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.accent.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, size: 18, color: palette.accent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                state.loadMoreError!,
                style: theme.textTheme.bodySmall?.copyWith(color: palette.ink),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (state.hasReachedMax) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            Expanded(child: Divider(color: palette.line)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'You’ve seen the whole edit · ${state.products.length} pieces',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.muted,
                  fontSize: 11,
                ),
              ),
            ),
            Expanded(child: Divider(color: palette.line)),
          ],
        ),
      );
    }

    return const SizedBox(height: 56);
  }
}
