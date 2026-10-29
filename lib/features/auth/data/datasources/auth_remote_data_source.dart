import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../core/network/api_client.dart';
import '../models/login_response_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._client);

  final ApiClient _client;

  Future<LoginResponseModel> login({
    required String username,
    required String password,
  }) async {
    final data = await _client.post(
      ApiConstants.loginPath,
      data: {
        'username': username,
        'password': password,
        'expiresInMins': ApiConstants.sessionMinutes,
      },
    );

    if (data is! Map<String, dynamic>) {
      throw const ServerException('Unexpected response from the server.');
    }

    return LoginResponseModel.fromJson(data);
  }
}
