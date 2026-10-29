import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_demo/core/theme/app_theme.dart';
import 'package:product_demo/features/products/domain/entities/product.dart';
import 'package:product_demo/features/products/presentation/widgets/product_card.dart';

void main() {
  testWidgets('product card fits a narrow two-column grid cell', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const product = Product(
      id: 1,
      title: 'A product with a fairly long name',
      description: '',
      category: 'beauty',
      brand: 'Essence',
      thumbnail: '',
      images: [],
      price: 129.99,
      discountPercentage: 10,
      rating: 4.5,
      stock: 99,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 136,
              height: 292,
              child: ProductCard(product: product, onTap: () {}),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('A product with a fairly long name'), findsOneWidget);
    expect(find.text('99 left'), findsNothing);
  });
}
