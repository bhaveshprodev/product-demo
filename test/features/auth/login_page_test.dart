import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:product_demo/core/theme/app_theme.dart';
import 'package:product_demo/core/utils/result.dart';
import 'package:product_demo/features/auth/domain/repositories/auth_repository.dart';
import 'package:product_demo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:product_demo/features/auth/presentation/pages/login_page.dart';

import '../../helpers/fixtures.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  testWidgets('login page submits the prefilled demo credentials', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repository = MockAuthRepository();
    when(() => repository.login(username: 'emilys', password: 'emilyspass'))
        .thenAnswer((_) async => const Success(testUser));

    final bloc = AuthBloc(repository);

    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: MaterialApp(theme: AppTheme.light, home: const LoginPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.textContaining('DummyJSON'), findsNothing);
    expect(find.textContaining('Demo'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();

    verify(() => repository.login(username: 'emilys', password: 'emilyspass'))
        .called(1);

    // Let the bloc finish its async event handler before the test tears down.
    await tester.pumpAndSettle();
  });

  testWidgets('login page lays out on a narrow phone', (tester) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final bloc = AuthBloc(MockAuthRepository());

    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: MaterialApp(theme: AppTheme.light, home: const LoginPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
