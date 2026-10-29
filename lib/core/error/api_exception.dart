import 'package:dio/dio.dart';

/// Low-level exception thrown by the network layer.
sealed class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => '$runtimeType($statusCode): $message';
}

final class NetworkException extends ApiException {
  const NetworkException([
    super.message = 'No connection. Check your network and try again.',
  ]);
}

final class UnauthorizedException extends ApiException {
  const UnauthorizedException([
    super.message = 'Your session is no longer valid.',
  ]) : super(statusCode: 401);
}

final class NotFoundException extends ApiException {
  const NotFoundException([
    super.message = 'The requested resource was not found.',
  ]) : super(statusCode: 404);
}

final class ServerException extends ApiException {
  const ServerException([
    super.message = 'The server could not complete the request.',
    int? statusCode,
  ]) : super(statusCode: statusCode);
}

final class RequestCancelledException extends ApiException {
  const RequestCancelledException() : super('The request was cancelled.');
}

final class UnknownException extends ApiException {
  const UnknownException([super.message = 'An unexpected error occurred.']);
}

/// Maps Dio's transport errors into our small, domain-friendly exception set.
extension DioExceptionMapper on DioException {
  ApiException toApiException() {
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.transformTimeout:
        return const NetworkException();
      case DioExceptionType.cancel:
        return const RequestCancelledException();
      case DioExceptionType.badCertificate:
        return const NetworkException(
          'The secure connection could not be verified.',
        );
      case DioExceptionType.badResponse:
        final status = response?.statusCode ?? 0;
        final serverMessage = _readMessage(response?.data);
        if (status == 401 || status == 403) {
          return UnauthorizedException(
            serverMessage ?? 'Your credentials are not valid.',
          );
        }
        if (status == 404) {
          return NotFoundException(
            serverMessage ?? 'The requested resource was not found.',
          );
        }
        return ServerException(
          serverMessage ??
              'The server could not complete the request ($status).',
          status,
        );
      case DioExceptionType.unknown:
        return const NetworkException();
    }
  }

  static String? _readMessage(Object? data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) return message;
    }
    if (data is String && data.trim().isNotEmpty) return data;
    return null;
  }
}
