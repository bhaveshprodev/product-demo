import '../../../../core/utils/result.dart';
import '../entities/product.dart';
import '../entities/product_page.dart';

abstract interface class ProductRepository {
  Future<Result<ProductPage>> getProducts({
    required int skip,
    required int limit,
  });

  Future<Result<Product>> getProduct(int id);
}
