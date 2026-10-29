import '../../domain/entities/product_page.dart';
import 'product_model.dart';

class ProductPageModel {
  const ProductPageModel({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductPageModel.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'];
    return ProductPageModel(
      products: rawProducts is List
          ? rawProducts
                .whereType<Map<String, dynamic>>()
                .map(ProductModel.fromJson)
                .toList(growable: false)
          : const [],
      total: (json['total'] as num?)?.toInt() ?? 0,
      skip: (json['skip'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 0,
    );
  }

  final List<ProductModel> products;
  final int total;
  final int skip;
  final int limit;

  ProductPage toEntity() => ProductPage(
    products: products
        .map((product) => product.toEntity())
        .toList(growable: false),
    total: total,
    skip: skip,
    limit: limit,
  );
}
