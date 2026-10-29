import 'package:product_demo/features/auth/domain/entities/user.dart';
import 'package:product_demo/features/products/domain/entities/product.dart';
import 'package:product_demo/features/products/domain/entities/product_page.dart';

const testUser = User(
  id: 1,
  username: 'emilys',
  email: 'emily.johnson@x.dummyjson.com',
  firstName: 'Emily',
  lastName: 'Johnson',
  imageUrl: 'https://dummyjson.com/icon/emilys/128',
);

Product testProduct(int id, {String? title}) {
  return Product(
    id: id,
    title: title ?? 'Product $id',
    description: 'A thoughtfully made product for everyday use.',
    category: 'beauty',
    brand: 'Essence',
    thumbnail:
        'https://cdn.dummyjson.com/product-images/beauty/1/thumbnail.jpg',
    images: const [
      'https://cdn.dummyjson.com/product-images/beauty/1/1.jpg',
      'https://cdn.dummyjson.com/product-images/beauty/1/2.jpg',
    ],
    price: 100,
    discountPercentage: 10,
    rating: 4.5,
    stock: 12,
  );
}

ProductPage testPage({
  required List<Product> products,
  int total = 3,
  int skip = 0,
}) {
  return ProductPage(products: products, total: total, skip: skip, limit: 12);
}
