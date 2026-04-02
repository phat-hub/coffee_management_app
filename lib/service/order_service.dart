import '../model/order.dart';
import 'pocketbase_client.dart';

class OrderService {
  Future<void> createOrder(Order order) async {
    final pb = await getPocketbaseInstance();

    await pb
        .collection('orders')
        .create(
          body: {...order.toJson(), 'createdBy': pb.authStore.record?.id},
        );
  }

  Future<List<Order>> fetchOrders() async {
    final pb = await getPocketbaseInstance();

    final list = await pb
        .collection('orders')
        .getFullList(
          sort: '-createdAt', //  mới nhất trước
        );

    return list.map((e) {
      final items = (e.getListValue('items')).map((item) {
        return OrderItem(
          productId: item['productId'],
          title: item['title'],
          price: (item['price'] ?? 0).toDouble(),
          quantity: item['quantity'] ?? 0,
        );
      }).toList();

      return Order(
        id: e.id,
        staffName: e.getStringValue('staffName'),
        staffPhone: e.getStringValue('staffPhone'),
        createdAt: DateTime.parse(e.getStringValue('createdAt')),
        items: items,
        totalPrice: e.getDoubleValue('totalPrice'),
      );
    }).toList();
  }
}
