import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:product_demo/core/error/failure.dart';
import 'package:product_demo/core/utils/result.dart';
import 'package:product_demo/features/auth/domain/repositories/auth_repository.dart';
import 'package:product_demo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:product_demo/features/auth/presentation/bloc/auth_event.dart';
import 'package:product_demo/features/auth/presentation/bloc/auth_state.dart';

import '../../helpers/fixtures.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
  });

  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'restores a stored session',
      build: () {
        when(() => repository.restoreSession())
            .thenAnswer((_) async => const Success(testUser));
        return AuthBloc(repository);
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => const [
        AuthState(status: AuthStatus.checking),
        AuthState(status: AuthStatus.authenticated, user: testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'lands on unauthenticated when there is no session',
      build: () {
        when(() => repository.restoreSession())
            .thenAnswer((_) async => const Success(null));
        return AuthBloc(repository);
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => const [
        AuthState(status: AuthStatus.checking),
        AuthState(status: AuthStatus.unauthenticated),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'authenticates with valid credentials',
      build: () {
        when(() => repository.login(username: 'emilys', password: 'emilyspass'))
            .thenAnswer((_) async => const Success(testUser));
        return AuthBloc(repository);
      },
      act: (bloc) => bloc.add(
        const LoginSubmitted(username: 'emilys', password: 'emilyspass'),
      ),
      expect: () => const [
        AuthState(status: AuthStatus.authenticating),
        AuthState(status: AuthStatus.authenticated, user: testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'surfaces the API message when login fails',
      build: () {
        when(
          () => repository.login(username: 'emilys', password: 'wrong'),
        ).thenAnswer(
          (_) async =>
              const FailureResult(UnauthorizedFailure('Invalid credentials')),
        );
        return AuthBloc(repository);
      },
      act: (bloc) =>
          bloc.add(const LoginSubmitted(username: 'emilys', password: 'wrong')),
      expect: () => const [
        AuthState(status: AuthStatus.authenticating),
        AuthState(
          status: AuthStatus.failure,
          errorMessage: 'Invalid credentials',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'clears the session on logout',
      build: () {
        when(() => repository.logout()).thenAnswer((_) async {});
        return AuthBloc(repository);
      },
      seed: () =>
          const AuthState(status: AuthStatus.authenticated, user: testUser),
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => const [AuthState(status: AuthStatus.unauthenticated)],
      verify: (_) => verify(() => repository.logout()).called(1),
    );
  });
}
