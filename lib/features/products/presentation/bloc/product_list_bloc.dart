import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_list_event.dart';
import 'product_list_state.dart';

class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  ProductListBloc(this._repository) : super(const ProductListState()) {
    on<ProductListStarted>(_onStart);
    on<ProductListRetryRequested>(_onRetry);
    on<ProductListRefreshed>(_onRefresh);
    on<ProductListLoadMoreRequested>(_onLoadMore);
  }

  final ProductRepository _repository;

  /// Exposed for [RefreshIndicator]; the event's completer is resolved when the
  /// request finishes, including on failure.
  Future<void> refresh() {
    final completer = Completer<void>();
    add(ProductListRefreshed(completer: completer));
    return completer.future;
  }

  Future<void> _onStart(
    ProductListStarted event,
    Emitter<ProductListState> emit,
  ) async {
    if (state.status == ProductListStatus.loading) return;
    await _loadFirstPage(emit);
  }

  Future<void> _onRetry(
    ProductListRetryRequested event,
    Emitter<ProductListState> emit,
  ) async {
    if (state.status == ProductListStatus.loading || state.isRefreshing) {
      return;
    }
    await _loadFirstPage(emit);
  }

  Future<void> _loadFirstPage(Emitter<ProductListState> emit) async {
    emit(
      state.copyWith(
        status: ProductListStatus.loading,
        clearProducts: true,
        total: 0,
        isRefreshing: false,
        isLoadingMore: false,
        hasReachedMax: false,
        clearError: true,
        clearRefreshError: true,
        clearLoadMoreError: true,
      ),
    );

    final result = await _repository.getProducts(
      skip: 0,
      limit: ApiConstants.pageSize,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProductListStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (page) => emit(
        ProductListState(
          status: ProductListStatus.loaded,
          products: page.products,
          total: page.total,
          hasReachedMax: !page.hasMore || page.products.isEmpty,
        ),
      ),
    );
  }

  Future<void> _onRefresh(
    ProductListRefreshed event,
    Emitter<ProductListState> emit,
  ) async {
    if (state.isRefreshing || state.status == ProductListStatus.loading) {
      event.completer?.complete();
      return;
    }

    final hadProducts = state.products.isNotEmpty;
    emit(
      state.copyWith(
        isRefreshing: true,
        clearRefreshError: true,
        clearLoadMoreError: true,
      ),
    );

    try {
      final result = await _repository.getProducts(
        skip: 0,
        limit: ApiConstants.pageSize,
      );

      result.fold(
        (failure) {
          if (hadProducts) {
            emit(
              state.copyWith(
                status: ProductListStatus.loaded,
                isRefreshing: false,
                refreshError: failure.message,
              ),
            );
          } else {
            emit(
              state.copyWith(
                status: ProductListStatus.error,
                isRefreshing: false,
                errorMessage: failure.message,
                clearProducts: true,
              ),
            );
          }
        },
        (page) => emit(
          ProductListState(
            status: ProductListStatus.loaded,
            products: page.products,
            total: page.total,
            hasReachedMax: !page.hasMore || page.products.isEmpty,
          ),
        ),
      );
    } finally {
      event.completer?.complete();
    }
  }

  Future<void> _onLoadMore(
    ProductListLoadMoreRequested event,
    Emitter<ProductListState> emit,
  ) async {
    if (!state.canLoadMore) return;

    emit(state.copyWith(isLoadingMore: true, clearLoadMoreError: true));

    final result = await _repository.getProducts(
      skip: state.products.length,
      limit: ApiConstants.pageSize,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingMore: false, loadMoreError: failure.message),
      ),
      (page) {
        final existingIds = state.products.map((product) => product.id).toSet();
        final newItems = page.products
            .where((product) => !existingIds.contains(product.id))
            .toList(growable: false);
        final merged = [...state.products, ...newItems];

        emit(
          state.copyWith(
            products: merged,
            total: page.total,
            isLoadingMore: false,
            clearLoadMoreError: true,
            hasReachedMax:
                page.products.isEmpty ||
                newItems.isEmpty ||
                merged.length >= page.total,
          ),
        );
      },
    );
  }
}
