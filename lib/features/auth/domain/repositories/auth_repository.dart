import '../../../../core/utils/result.dart';
import '../entities/user.dart';

abstract interface class AuthRepository {
  /// Authenticates with DummyJSON and persists the session token securely.
  Future<Result<User>> login({
    required String username,
    required String password,
  });

  /// Reads a previously persisted session. Returns `null` when signed out.
  Future<Result<User?>> restoreSession();

  Future<void> logout();
}
