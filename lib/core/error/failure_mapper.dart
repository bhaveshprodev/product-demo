import 'api_exception.dart';
import 'failure.dart';

extension ApiExceptionToFailure on ApiException {
  Failure toFailure() {
    return switch (this) {
      NetworkException() => NetworkFailure(message),
      UnauthorizedException() => UnauthorizedFailure(message),
      NotFoundException() => NotFoundFailure(message),
      ServerException() => ServerFailure(message),
      RequestCancelledException() => const UnknownFailure(),
      UnknownException() => const UnknownFailure(),
    };
  }
}
