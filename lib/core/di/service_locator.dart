import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/products/data/datasources/product_remote_data_source.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/presentation/bloc/product_detail_bloc.dart';
import '../../features/products/presentation/bloc/product_list_bloc.dart';
import '../constants/api_constants.dart';
import '../network/api_client.dart';
import '../network/auth_token_refresher.dart';
import '../network/session_expiry_notifier.dart';
import '../storage/auth_storage.dart';

final getIt = GetIt.instance;

/// Composition root. Dependencies point inwards:
/// presentation -> domain <- data.
void setupServiceLocator() {
  getIt
    ..registerLazySingleton<AuthStorage>(SecureAuthStorage.new)
    ..registerLazySingleton<SessionExpiryNotifier>(SessionExpiryNotifier.new)
    ..registerLazySingleton<AuthTokenRefresher>(
      () => AuthTokenRefresher.create(
        baseUrl: ApiConstants.baseUrl,
        storage: getIt(),
      ),
    )
    ..registerLazySingleton<ApiClient>(
      () => ApiClient(
        baseUrl: ApiConstants.baseUrl,
        authStorage: getIt(),
        tokenRefresher: getIt(),
        sessionExpiry: getIt(),
      ),
    )
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(getIt()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt(), getIt()),
    )
    ..registerLazySingleton<AuthBloc>(
      () => AuthBloc(getIt(), sessionExpiry: getIt()),
    )
    ..registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSource(getIt()),
    )
    ..registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(getIt()),
    )
    ..registerFactory<ProductListBloc>(() => ProductListBloc(getIt()))
    ..registerFactory<ProductDetailBloc>(() => ProductDetailBloc(getIt()));
}
