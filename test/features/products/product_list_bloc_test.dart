import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:product_demo/core/error/failure.dart';
import 'package:product_demo/core/utils/result.dart';
import 'package:product_demo/features/products/domain/repositories/product_repository.dart';
import 'package:product_demo/features/products/presentation/bloc/product_list_bloc.dart';
import 'package:product_demo/features/products/presentation/bloc/product_list_event.dart';
import 'package:product_demo/features/products/presentation/bloc/product_list_state.dart';

import '../../helpers/fixtures.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository repository;

  setUp(() {
    repository = MockProductRepository();
  });

  group('ProductListBloc', () {
    final firstPageProducts = [testProduct(1), testProduct(2)];
    final secondPageProducts = [testProduct(3)];

    blocTest<ProductListBloc, ProductListState>(
      'loads the first page with a loading state',
      build: () {
        when(() => repository.getProducts(skip: 0, limit: 12)).thenAnswer(
          (_) async => Success(testPage(products: firstPageProducts, total: 3)),
        );
        return ProductListBloc(repository);
      },
      act: (bloc) => bloc.add(const ProductListStarted()),
      expect: () => [
        const ProductListState(status: ProductListStatus.loading),
        ProductListState(
          status: ProductListStatus.loaded,
          products: firstPageProducts,
          total: 3,
        ),
      ],
    );

    blocTest<ProductListBloc, ProductListState>(
      'shows an error when the first page fails',
      build: () {
        when(() => repository.getProducts(skip: 0, limit: 12)).thenAnswer(
          (_) async => const FailureResult(NetworkFailure('No connection.')),
        );
        return ProductListBloc(repository);
      },
      act: (bloc) => bloc.add(const ProductListStarted()),
      expect: () => [
        const ProductListState(status: ProductListStatus.loading),
        const ProductListState(
          status: ProductListStatus.error,
          errorMessage: 'No connection.',
        ),
      ],
    );

    blocTest<ProductListBloc, ProductListState>(
      'appends the next page and stops at the end',
      build: () {
        when(() => repository.getProducts(skip: 2, limit: 12)).thenAnswer(
          (_) async => Success(
            testPage(products: secondPageProducts, total: 3, skip: 2),
          ),
        );
        return ProductListBloc(repository);
      },
      seed: () => ProductListState(
        status: ProductListStatus.loaded,
        products: firstPageProducts,
        total: 3,
      ),
      act: (bloc) => bloc.add(const ProductListLoadMoreRequested()),
      expect: () => [
        ProductListState(
          status: ProductListStatus.loaded,
          products: firstPageProducts,
          total: 3,
          isLoadingMore: true,
        ),
        ProductListState(
          status: ProductListStatus.loaded,
          products: [...firstPageProducts, ...secondPageProducts],
          total: 3,
          hasReachedMax: true,
        ),
      ],
    );

    blocTest<ProductListBloc, ProductListState>(
      'keeps existing items when pagination fails',
      build: () {
        when(() => repository.getProducts(skip: 2, limit: 12)).thenAnswer(
          (_) async =>
              const FailureResult(ServerFailure('Pagination exploded')),
        );
        return ProductListBloc(repository);
      },
      seed: () => ProductListState(
        status: ProductListStatus.loaded,
        products: firstPageProducts,
        total: 3,
      ),
      act: (bloc) => bloc.add(const ProductListLoadMoreRequested()),
      expect: () => [
        ProductListState(
          status: ProductListStatus.loaded,
          products: firstPageProducts,
          total: 3,
          isLoadingMore: true,
        ),
        ProductListState(
          status: ProductListStatus.loaded,
          products: firstPageProducts,
          total: 3,
          loadMoreError: 'Pagination exploded',
        ),
      ],
    );

    blocTest<ProductListBloc, ProductListState>(
      'refresh replaces the collection',
      build: () {
        when(() => repository.getProducts(skip: 0, limit: 12)).thenAnswer(
          (_) async => Success(
            testPage(products: [testProduct(10), testProduct(11)], total: 2),
          ),
        );
        return ProductListBloc(repository);
      },
      seed: () => ProductListState(
        status: ProductListStatus.loaded,
        products: firstPageProducts,
        total: 3,
      ),
      act: (bloc) => bloc.add(const ProductListRefreshed()),
      expect: () => [
        ProductListState(
          status: ProductListStatus.loaded,
          products: firstPageProducts,
          total: 3,
          isRefreshing: true,
        ),
        ProductListState(
          status: ProductListStatus.loaded,
          products: [testProduct(10), testProduct(11)],
          total: 2,
          hasReachedMax: true,
        ),
      ],
    );

    blocTest<ProductListBloc, ProductListState>(
      'refresh failure keeps the old list and exposes a message',
      build: () {
        when(() => repository.getProducts(skip: 0, limit: 12)).thenAnswer(
          (_) async => const FailureResult(NetworkFailure('Still offline')),
        );
        return ProductListBloc(repository);
      },
      seed: () => ProductListState(
        status: ProductListStatus.loaded,
        products: firstPageProducts,
        total: 3,
      ),
      act: (bloc) => bloc.add(const ProductListRefreshed()),
      expect: () => [
        ProductListState(
          status: ProductListStatus.loaded,
          products: firstPageProducts,
          total: 3,
          isRefreshing: true,
        ),
        ProductListState(
          status: ProductListStatus.loaded,
          products: firstPageProducts,
          total: 3,
          refreshError: 'Still offline',
        ),
      ],
    );

    blocTest<ProductListBloc, ProductListState>(
      'does not request another page once the end is reached',
      build: () => ProductListBloc(repository),
      seed: () => ProductListState(
        status: ProductListStatus.loaded,
        products: [testProduct(1), testProduct(2), testProduct(3)],
        total: 3,
        hasReachedMax: true,
      ),
      act: (bloc) => bloc.add(const ProductListLoadMoreRequested()),
      expect: () => const <ProductListState>[],
      verify: (_) => verifyNever(
        () => repository.getProducts(
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ),
    );

    test('refresh future completes even when the request fails', () async {
      when(
        () => repository.getProducts(skip: 0, limit: 12),
      ).thenAnswer((_) async => const FailureResult(NetworkFailure('Offline')));
      final bloc = ProductListBloc(repository)..add(const ProductListStarted());

      await bloc.stream.firstWhere(
        (state) => state.status == ProductListStatus.error,
      );
      await bloc.refresh().timeout(const Duration(seconds: 1));
      await bloc.close();
    });
  });
}
