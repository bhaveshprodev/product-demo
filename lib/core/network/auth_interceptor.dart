import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/auth_storage.dart';
import 'auth_token_refresher.dart';
import 'session_expiry_notifier.dart';

/// Attaches the bearer token to every request except the auth endpoints.
///
/// On a `401` it refreshes the access token once and replays the original
/// request. Concurrent failures await the same refresh (see
/// [AuthTokenRefresher]). If the refresh token is rejected, the session is
/// cleared and [SessionExpiryNotifier] tells the app to return to login.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(
    this._storage,
    this._refresher,
    this._sessionExpiry,
    this._dio,
  );

  static const _retriedKey = 'auth.retried';

  final AuthStorage _storage;
  final AuthTokenRefresher _refresher;
  final SessionExpiryNotifier _sessionExpiry;
  final Dio _dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isAuthPath(options.path)) {
      final token = await _storage.readToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    if (err.response?.statusCode != 401 ||
        _isAuthPath(options.path) ||
        options.extra[_retriedKey] == true) {
      handler.next(err);
      return;
    }

    var accessToken = await _storage.readToken();

    // A parallel request may already have refreshed while this one was in
    // flight; in that case reuse the new token instead of rotating again.
    final failedToken = _bearerToken(options.headers);
    final alreadyRefreshed =
        accessToken != null &&
        accessToken.isNotEmpty &&
        failedToken != null &&
        accessToken != failedToken;

    if (!alreadyRefreshed) {
      final result = await _refresher.refresh();
      switch (result) {
        case TokenRefreshed(accessToken: final refreshed):
          accessToken = refreshed;
        case TokenRefreshRejected():
          await _storage.clear();
          _sessionExpiry.notifyExpired();
          handler.next(err);
          return;
        case TokenRefreshUnavailable():
          handler.next(err);
          return;
      }
    }

    if (accessToken.isEmpty) {
      handler.next(err);
      return;
    }

    try {
      final response = await _dio.fetch<dynamic>(
        options.copyWith(
          headers: {...options.headers, 'Authorization': 'Bearer $accessToken'},
          extra: {...options.extra, _retriedKey: true},
        ),
      );
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _isAuthPath(String path) {
    return path == ApiConstants.loginPath || path == ApiConstants.refreshPath;
  }

  String? _bearerToken(Map<String, dynamic> headers) {
    final header = headers['Authorization'] ?? headers['authorization'];
    if (header is! String) return null;
    const prefix = 'Bearer ';
    return header.startsWith(prefix) ? header.substring(prefix.length) : null;
  }
}
