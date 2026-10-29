import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';
import '../models/product_page_model.dart';

class ProductRemoteDataSource {
  const ProductRemoteDataSource(this._client);

  final ApiClient _client;

  Future<ProductPageModel> fetchProducts({
    required int skip,
    required int limit,
  }) async {
    final data = await _client.get(
      ApiConstants.productsPath,
      queryParameters: {
        'limit': limit,
        'skip': skip,
        'select':
            'title,description,category,brand,thumbnail,images,'
            'price,discountPercentage,rating,stock',
      },
    );

    if (data is! Map<String, dynamic>) {
      throw const ServerException('Unexpected response from the server.');
    }

    return ProductPageModel.fromJson(data);
  }

  Future<ProductModel> fetchProduct(int id) async {
    final data = await _client.get('${ApiConstants.productsPath}/$id');

    if (data is! Map<String, dynamic>) {
      throw const ServerException('Unexpected response from the server.');
    }

    return ProductModel.fromJson(data);
  }
}
