import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:product_demo/core/error/failure.dart';
import 'package:product_demo/core/utils/result.dart';
import 'package:product_demo/features/products/domain/repositories/product_repository.dart';
import 'package:product_demo/features/products/presentation/bloc/product_detail_bloc.dart';
import 'package:product_demo/features/products/presentation/bloc/product_detail_event.dart';
import 'package:product_demo/features/products/presentation/bloc/product_detail_state.dart';

import '../../helpers/fixtures.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository repository;

  setUp(() {
    repository = MockProductRepository();
  });

  group('ProductDetailBloc', () {
    blocTest<ProductDetailBloc, ProductDetailState>(
      'loads a product by id',
      build: () {
        when(() => repository.getProduct(1))
            .thenAnswer((_) async => Success(testProduct(1)));
        return ProductDetailBloc(repository);
      },
      act: (bloc) => bloc.add(const ProductDetailRequested(1)),
      expect: () => [
        const ProductDetailState(status: ProductDetailStatus.loading),
        ProductDetailState(
          status: ProductDetailStatus.loaded,
          product: testProduct(1),
        ),
      ],
    );

    blocTest<ProductDetailBloc, ProductDetailState>(
      'exposes an error when the product cannot be loaded',
      build: () {
        when(() => repository.getProduct(99)).thenAnswer(
          (_) async => const FailureResult(
            NotFoundFailure('That product does not exist.'),
          ),
        );
        return ProductDetailBloc(repository);
      },
      act: (bloc) => bloc.add(const ProductDetailRequested(99)),
      expect: () => const [
        ProductDetailState(status: ProductDetailStatus.loading),
        ProductDetailState(
          status: ProductDetailStatus.error,
          errorMessage: 'That product does not exist.',
        ),
      ],
    );
  });
}
