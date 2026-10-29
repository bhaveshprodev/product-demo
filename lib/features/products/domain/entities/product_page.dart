import 'package:equatable/equatable.dart';

import 'product.dart';

class ProductPage extends Equatable {
  const ProductPage({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  bool get hasMore => skip + products.length < total;

  @override
  List<Object?> get props => [products, total, skip, limit];
}
