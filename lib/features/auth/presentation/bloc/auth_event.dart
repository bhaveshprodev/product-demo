import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

final class LoginSubmitted extends AuthEvent {
  const LoginSubmitted({required this.username, required this.password});

  final String username;
  final String password;

  @override
  List<Object?> get props => [username, password];
}

final class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Emitted when the network layer could not renew the access token and the
/// stored session has been discarded.
final class SessionExpired extends AuthEvent {
  const SessionExpired();
}
