import '../../../../core/error/api_exception.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_page.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._remote);

  final ProductRemoteDataSource _remote;

  @override
  Future<Result<ProductPage>> getProducts({
    required int skip,
    required int limit,
  }) async {
    try {
      final page = await _remote.fetchProducts(skip: skip, limit: limit);
      return Success(page.toEntity());
    } on ApiException catch (error) {
      return FailureResult(error.toFailure());
    } catch (_) {
      return const FailureResult(UnknownFailure());
    }
  }

  @override
  Future<Result<Product>> getProduct(int id) async {
    try {
      final product = await _remote.fetchProduct(id);
      return Success(product.toEntity());
    } on ApiException catch (error) {
      return FailureResult(error.toFailure());
    } catch (_) {
      return const FailureResult(UnknownFailure());
    }
  }
}
