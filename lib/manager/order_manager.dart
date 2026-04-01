import 'package:flutter/material.dart';
import '../model/order.dart';
import '../service/order_service.dart';

class OrderManager with ChangeNotifier {
  final OrderService _service = OrderService();
  List<Order> _orders = [];

  List<Order> get orders => _orders;

  Future<void> fetchOrders() async {
    _orders = await _service.fetchOrders();
    notifyListeners();
  }

  Future<void> createOrder(Order order) async {
    await _service.createOrder(order);
    await fetchOrders();
  }
}
