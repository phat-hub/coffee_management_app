import 'package:flutter/material.dart';
import '../model/order.dart';
import '../service/order_service.dart';
import '../model/stats_period.dart';
import '../model/stats_result.dart';

class OrderManager with ChangeNotifier {
  final OrderService _service = OrderService();
  List<Order> _orders = [];

  List<Order> get orders => _orders;

  Future<void> fetchOrders() async {
    _orders = await _service.fetchOrders();

    //  backup sort nếu backend không sort
    _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    notifyListeners();
  }

  Future<void> createOrder(Order order) async {
    await _service.createOrder(order);
    await fetchOrders();
  }

  StatsResult getStats({
    required StatsPeriod period,
    required DateTime selectedDate,
  }) {
    double totalRevenue = 0;
    Map<String, int> productMap = {};

    for (var order in _orders) {
      final date = order.createdAt;

      bool match = false;

      switch (period) {
        case StatsPeriod.day:
          match =
              date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;
          break;

        case StatsPeriod.month:
          match =
              date.year == selectedDate.year &&
              date.month == selectedDate.month;
          break;

        case StatsPeriod.year:
          match = date.year == selectedDate.year;
          break;
      }

      if (!match) continue;

      /// --- cộng doanh thu ---
      totalRevenue += order.totalPrice;

      /// --- cộng số lượng từng sản phẩm ---
      for (var item in order.items) {
        productMap[item.title] = (productMap[item.title] ?? 0) + item.quantity;
      }
    }

    return StatsResult(totalRevenue: totalRevenue, productQuantity: productMap);
  }
}
