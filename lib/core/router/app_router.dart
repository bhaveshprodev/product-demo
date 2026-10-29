import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/products/domain/entities/product.dart';
import '../../features/products/presentation/pages/product_detail_page.dart';
import '../../features/products/presentation/pages/products_page.dart';
import '../theme/app_palette.dart';
import '../ui/status_views.dart';

abstract final class AppRouter {
  static GoRouter create({required AuthBloc authBloc}) {
    final refreshListenable = _AuthRefreshListenable(authBloc.stream);

    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: refreshListenable,
      redirect: (context, state) {
        final status = authBloc.state.status;
        final location = state.matchedLocation;
        final isChecking =
            status == AuthStatus.initial || status == AuthStatus.checking;
        final isAuthenticated = status == AuthStatus.authenticated;

        if (isChecking) {
          return location == '/splash' ? null : '/splash';
        }

        if (!isAuthenticated) {
          return location == '/login' ? null : '/login';
        }

        if (location == '/login' || location == '/splash' || location == '/') {
          return '/products';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(
          path: '/products',
          builder: (context, state) => const ProductsPage(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '');
                if (id == null) return const _InvalidProductPage();
                final extra = state.extra;
                return ProductDetailPage(
                  productId: id,
                  initialProduct: extra is Product ? extra : null,
                );
              },
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: SafeArea(
          child: Center(
            child: ErrorStateView(
              title: 'Page not found',
              message: 'The page you were looking for does not exist.',
              onRetry: () => context.go('/products'),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class _InvalidProductPage extends StatelessWidget {
  const _InvalidProductPage();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ErrorStateView(
          title: 'Unknown product',
          message: 'This product link does not look right.',
          onRetry: () => context.go('/products'),
        ),
      ),
      backgroundColor: palette.canvas,
    );
  }
}
