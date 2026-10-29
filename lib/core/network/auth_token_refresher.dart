import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/auth_storage.dart';

/// Outcome of an attempt to exchange a refresh token for a new access token.
sealed class TokenRefreshResult {
  const TokenRefreshResult();
}

final class TokenRefreshed extends TokenRefreshResult {
  const TokenRefreshed(this.accessToken);

  final String accessToken;
}

/// The refresh token is missing or was rejected. The session cannot be
/// recovered, so the user has to sign in again.
final class TokenRefreshRejected extends TokenRefreshResult {
  const TokenRefreshRejected();
}

/// The refresh could not be attempted (offline, timeout, server error). The
/// stored session may still be valid, so it is not discarded.
final class TokenRefreshUnavailable extends TokenRefreshResult {
  const TokenRefreshUnavailable();
}

/// Exchanges the stored refresh token for a new access token.
///
/// Parallel 401s share a single in-flight request (single-flight), so a burst
/// of failed calls cannot rotate the refresh token several times at once.
class AuthTokenRefresher {
  AuthTokenRefresher(this._dio, this._storage);

  /// Uses a separate, interceptor-free Dio so a 401 from the refresh endpoint
  /// can never recurse back into the auth interceptor.
  factory AuthTokenRefresher.create({
    required String baseUrl,
    required AuthStorage storage,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.connectTimeout,
        responseType: ResponseType.json,
        headers: const {'Accept': 'application/json'},
      ),
    );
    return AuthTokenRefresher(dio, storage);
  }

  final Dio _dio;
  final AuthStorage _storage;

  Future<TokenRefreshResult>? _inFlight;

  Future<TokenRefreshResult> refresh() {
    return _inFlight ??= _performRefresh().whenComplete(() {
      _inFlight = null;
    });
  }

  Future<TokenRefreshResult> _performRefresh() async {
    try {
      final refreshToken = await _storage.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return const TokenRefreshRejected();
      }

      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.refreshPath,
        data: {
          'refreshToken': refreshToken,
          'expiresInMins': ApiConstants.sessionMinutes,
        },
      );

      final data = response.data;
      final accessToken = data?['accessToken'];
      if (accessToken is! String || accessToken.isEmpty) {
        return const TokenRefreshRejected();
      }

      // DummyJSON rotates the refresh token, so persist the new pair
      // together; older responses may omit it, in which case the existing
      // refresh token stays valid.
      final rotatedRefreshToken = data?['refreshToken'];
      await _storage.writeToken(accessToken);
      if (rotatedRefreshToken is String && rotatedRefreshToken.isNotEmpty) {
        await _storage.writeRefreshToken(rotatedRefreshToken);
      }

      return TokenRefreshed(accessToken);
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 400 || status == 401 || status == 403) {
        return const TokenRefreshRejected();
      }
      return const TokenRefreshUnavailable();
    } catch (_) {
      return const TokenRefreshUnavailable();
    }
  }
}
