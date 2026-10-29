import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/auth_storage.dart';

/// Attaches the bearer token to every request except login.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  final AuthStorage _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.path != ApiConstants.loginPath) {
      final token = await _storage.readToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }
}
