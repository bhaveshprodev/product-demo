import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
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

  bool get hasDiscount => discountPercentage > 0;

  bool get isInStock => stock > 0;

  double get discountedPrice => hasDiscount
      ? double.parse(
          (price * (1 - discountPercentage / 100)).toStringAsFixed(2),
        )
      : price;

  List<String> get gallery => images.where((image) => image.isNotEmpty).isEmpty
      ? [thumbnail]
      : images.where((image) => image.isNotEmpty).toList();

  String get primaryImage => gallery.first;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    category,
    brand,
    thumbnail,
    images,
    price,
    discountPercentage,
    rating,
    stock,
  ];
}
