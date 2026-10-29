import 'package:equatable/equatable.dart';

sealed class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();

  @override
  List<Object?> get props => [];
}

final class ProductDetailRequested extends ProductDetailEvent {
  const ProductDetailRequested(this.productId);

  final int productId;

  @override
  List<Object?> get props => [productId];
}
