class OrderItem {
  final String productId;
  final String title;
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'quantity': quantity,
    };
  }
}

class Order {
  final String? id;
  final String staffName;
  final String staffPhone;
  final DateTime createdAt;
  final List<OrderItem> items;
  final double totalPrice;

  Order({
    this.id,
    required this.staffName,
    required this.staffPhone,
    required this.createdAt,
    required this.items,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'staffName': staffName,
      'staffPhone': staffPhone,
      'createdAt': createdAt.toIso8601String(),
      'totalPrice': totalPrice,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}
