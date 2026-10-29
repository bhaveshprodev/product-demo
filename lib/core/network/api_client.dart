import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../error/api_exception.dart';
import '../storage/auth_storage.dart';
import 'auth_interceptor.dart';

/// Thin wrapper around Dio. It owns configuration, auth and error mapping;
/// repositories only deal with decoded JSON.
class ApiClient {
  ApiClient({
    required String baseUrl,
    required AuthStorage authStorage,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.connectTimeout,
      responseType: ResponseType.json,
      headers: const {'Accept': 'application/json'},
    );
    _dio.interceptors.add(AuthInterceptor(authStorage));
    if (kDebugMode) _dio.interceptors.add(_LogInterceptor());
  }

  final Dio _dio;

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _guard(
      () => _dio.get<dynamic>(path, queryParameters: queryParameters),
    );
  }

  Future<dynamic> post(String path, {Object? data}) {
    return _guard(() => _dio.post<dynamic>(path, data: data));
  }

  Future<dynamic> _guard(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      return response.data;
    } on DioException catch (error) {
      throw error.toApiException();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const UnknownException();
    }
  }
}

/// Logs only method, path, status and duration — never headers or bodies,
/// because the auth header contains the access token.
class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['startedAt'] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _log(response.requestOptions, response.statusCode);
    handler.next(response);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    _log(error.requestOptions, error.response?.statusCode);
    handler.next(error);
  }

  void _log(RequestOptions options, int? status) {
    final startedAt = options.extra['startedAt'] as int?;
    final elapsed = startedAt == null
        ? ''
        : ' ${DateTime.now().millisecondsSinceEpoch - startedAt}ms';
    developer.log(
      '${options.method} ${options.uri}$elapsed -> ${status ?? 'failed'}',
      name: 'api',
    );
  }
}
