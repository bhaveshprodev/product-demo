import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Small abstraction over secure storage so the data layer does not depend on
/// the plugin directly (and can be faked in tests).
abstract interface class AuthStorage {
  Future<void> writeToken(String token);
  Future<String?> readToken();
  Future<void> writeRefreshToken(String token);
  Future<String?> readRefreshToken();
  Future<void> writeUser(String json);
  Future<String?> readUser();
  Future<void> clear();
}

class SecureAuthStorage implements AuthStorage {
  SecureAuthStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'mercato.access_token';
  static const _refreshTokenKey = 'mercato.refresh_token';
  static const _userKey = 'mercato.user';

  final FlutterSecureStorage _storage;

  @override
  Future<void> writeToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  @override
  Future<String?> readToken() => _storage.read(key: _tokenKey);

  @override
  Future<void> writeRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  @override
  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  @override
  Future<void> writeUser(String json) =>
      _storage.write(key: _userKey, value: json);

  @override
  Future<String?> readUser() => _storage.read(key: _userKey);

  @override
  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userKey);
  }
}
