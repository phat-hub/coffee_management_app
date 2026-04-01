import 'dart:io';

class Product {
  final String? id;
  final String title;
  final double price;
  final File? imageFile;
  final String imageUrl;
  final String categoryId;
  final String categoryName;

  Product({
    this.id,
    required this.title,
    required this.price,
    required this.categoryId,
    this.categoryName = '',
    this.imageFile,
    this.imageUrl = '',
  });

  bool get hasImage => imageFile != null || imageUrl.isNotEmpty;

  Product copyWith({
    String? id,
    String? title,
    double? price,
    File? imageFile,
    String? imageUrl,
    String? categoryId,
    String? categoryName,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      imageFile: imageFile ?? this.imageFile,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'price': price, 'categoryId': categoryId};
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
    );
  }
}
