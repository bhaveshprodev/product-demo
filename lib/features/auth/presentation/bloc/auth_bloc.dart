import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/session_expiry_notifier.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository, {SessionExpiryNotifier? sessionExpiry})
    : super(const AuthState()) {
    _sessionExpirySubscription = sessionExpiry?.onExpired.listen((_) {
      add(const SessionExpired());
    });
    on<AuthCheckRequested>(_onCheckRequested);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<SessionExpired>(_onSessionExpired);
  }

  final AuthRepository _repository;
  StreamSubscription<void>? _sessionExpirySubscription;

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.checking, clearError: true));

    final result = await _repository.restoreSession();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(
        user == null
            ? state.copyWith(
                status: AuthStatus.unauthenticated,
                clearUser: true,
                clearError: true,
              )
            : state.copyWith(
                status: AuthStatus.authenticated,
                user: user,
                clearError: true,
              ),
      ),
    );
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status == AuthStatus.authenticating) return;

    emit(
      state.copyWith(
        status: AuthStatus.authenticating,
        clearError: true,
        clearUser: true,
      ),
    );

    final result = await _repository.login(
      username: event.username.trim(),
      password: event.password,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.failure,
          clearUser: true,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.logout();
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        clearError: true,
      ),
    );
  }

  Future<void> _onSessionExpired(
    SessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status == AuthStatus.unauthenticated) return;
    await _repository.logout();
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        errorMessage: 'Your session expired. Please sign in again.',
      ),
    );
  }

  @override
  Future<void> close() async {
    await _sessionExpirySubscription?.cancel();
    return super.close();
  }
}
