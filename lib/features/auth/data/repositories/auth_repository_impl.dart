import 'dart:convert';

import '../../../../core/error/api_exception.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._storage);

  final AuthRemoteDataSource _remote;
  final AuthStorage _storage;

  @override
  Future<Result<User>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _remote.login(
        username: username,
        password: password,
      );

      // Persist both tokens in the platform keychain/keystore. The refresh
      // token lets the auth interceptor mint a new access token on a 401
      // without asking for credentials again. The user profile is cached
      // alongside them so a cold start does not need a second round trip.
      await _storage.writeToken(response.accessToken);
      await _storage.writeRefreshToken(response.refreshToken);
      await _storage.writeUser(jsonEncode(response.user.toJson()));

      return Success(response.user.toEntity());
    } on ApiException catch (error) {
      return FailureResult(error.toFailure());
    } catch (_) {
      return const FailureResult(UnknownFailure());
    }
  }

  @override
  Future<Result<User?>> restoreSession() async {
    try {
      final token = await _storage.readToken();
      if (token == null || token.isEmpty) {
        await _storage.clear();
        return const Success(null);
      }

      final userJson = await _storage.readUser();
      if (userJson == null || userJson.isEmpty) {
        await _storage.clear();
        return const Success(null);
      }

      final decoded = jsonDecode(userJson);
      if (decoded is! Map<String, dynamic>) {
        await _storage.clear();
        return const Success(null);
      }

      return Success(UserModel.fromJson(decoded).toEntity());
    } catch (_) {
      // A corrupt or inaccessible store should drop the user on the login
      // screen rather than crash the app at launch.
      await _storage.clear();
      return const Success(null);
    }
  }

  @override
  Future<void> logout() => _storage.clear();
}
