import '../../domain/entities/product.dart';

class ProductModel {
  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.brand,
    required this.thumbnail,
    required this.images,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    return ProductModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? 'Untitled product',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Uncategorised',
      brand: json['brand'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      images: rawImages is List
          ? rawImages.whereType<String>().toList(growable: false)
          : const [],
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
    );
  }

  final int id;
  final String title;
  final String description;
  final String category;
  final String brand;
  final String thumbnail;
  final List<String> images;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;

  Product toEntity() => Product(
    id: id,
    title: title,
    description: description,
    category: category,
    brand: brand,
    thumbnail: thumbnail,
    images: images,
    price: price,
    discountPercentage: discountPercentage,
    rating: rating,
    stock: stock,
  );
}
