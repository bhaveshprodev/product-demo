import 'package:equatable/equatable.dart';

import '../../domain/entities/product.dart';

enum ProductDetailStatus { initial, loading, loaded, error }

class ProductDetailState extends Equatable {
  const ProductDetailState({
    this.status = ProductDetailStatus.initial,
    this.product,
    this.errorMessage,
  });

  final ProductDetailStatus status;
  final Product? product;
  final String? errorMessage;

  bool get isLoading => status == ProductDetailStatus.loading;

  ProductDetailState copyWith({
    ProductDetailStatus? status,
    Product? product,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProductDetailState(
      status: status ?? this.status,
      product: product ?? this.product,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, product, errorMessage];
}
