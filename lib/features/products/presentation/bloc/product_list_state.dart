import 'package:equatable/equatable.dart';

import '../../domain/entities/product.dart';

enum ProductListStatus { initial, loading, loaded, error }

class ProductListState extends Equatable {
  const ProductListState({
    this.status = ProductListStatus.initial,
    this.products = const [],
    this.total = 0,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.errorMessage,
    this.refreshError,
    this.loadMoreError,
  });

  final ProductListStatus status;
  final List<Product> products;
  final int total;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final String? errorMessage;

  /// Set when a pull-to-refresh fails but previously loaded products are still
  /// visible. The page surfaces this through a snackbar.
  final String? refreshError;

  final String? loadMoreError;

  bool get isEmpty => status == ProductListStatus.loaded && products.isEmpty;

  bool get canLoadMore =>
      status == ProductListStatus.loaded &&
      !isLoadingMore &&
      !hasReachedMax &&
      !isRefreshing;

  ProductListState copyWith({
    ProductListStatus? status,
    List<Product>? products,
    int? total,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? errorMessage,
    String? refreshError,
    String? loadMoreError,
    bool clearProducts = false,
    bool clearError = false,
    bool clearRefreshError = false,
    bool clearLoadMoreError = false,
  }) {
    return ProductListState(
      status: status ?? this.status,
      products: clearProducts ? const [] : (products ?? this.products),
      total: total ?? this.total,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      refreshError: clearRefreshError
          ? null
          : (refreshError ?? this.refreshError),
      loadMoreError: clearLoadMoreError
          ? null
          : (loadMoreError ?? this.loadMoreError),
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    total,
    isRefreshing,
    isLoadingMore,
    hasReachedMax,
    errorMessage,
    refreshError,
    loadMoreError,
  ];
}
