import 'dart:io';

class Product {
  final String? id;
  final String title;
  final double price;
  final File? imageFile;
  final String imageUrl;

  Product({
    this.id,
    required this.title,
    required this.price,
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
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      imageFile: imageFile ?? this.imageFile,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'price': price};
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
