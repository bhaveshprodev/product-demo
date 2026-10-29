import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/product_repository.dart';
import 'product_detail_event.dart';
import 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  ProductDetailBloc(this._repository) : super(const ProductDetailState()) {
    on<ProductDetailRequested>(_onRequested);
  }

  final ProductRepository _repository;

  Future<void> _onRequested(
    ProductDetailRequested event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(state.copyWith(status: ProductDetailStatus.loading, clearError: true));

    final result = await _repository.getProduct(event.productId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProductDetailStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (product) => emit(
        state.copyWith(
          status: ProductDetailStatus.loaded,
          product: product,
          clearError: true,
        ),
      ),
    );
  }
}
