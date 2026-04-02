import 'dart:async';
import 'package:ct484_project/ui/shared/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../manager/order_manager.dart';
import '../../model/order.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  bool _isLoading = true;

  String _searchText = '';
  Timer? _debounce;

  final currencyFormat = NumberFormat.currency(
    locale: "vi_VN",
    symbol: "₫",
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await context.read<OrderManager>().fetchOrders();
      if (mounted) setState(() => _isLoading = false);
    });
  }

  List<Order> _filterOrders(List<Order> orders) {
    if (_searchText.isEmpty) return orders;

    return orders.where((order) {
      return order.staffName.toLowerCase().contains(_searchText) ||
          order.staffPhone.contains(_searchText);
    }).toList();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderManager>().orders;
    final filteredOrders = _filterOrders(orders);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách đơn hàng"),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// 🔍 SEARCH
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm theo tên hoặc SĐT...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      if (_debounce?.isActive ?? false) {
                        _debounce!.cancel();
                      }

                      _debounce = Timer(const Duration(milliseconds: 300), () {
                        setState(() {
                          _searchText = value.toLowerCase();
                        });
                      });
                    },
                  ),
                ),

                /// 📋 LIST
                Expanded(
                  child: filteredOrders.isEmpty
                      ? const Center(
                          child: Text(
                            "Không tìm thấy đơn hàng",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 3,
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                collapsedBackgroundColor: Colors.brown[50],
                                backgroundColor: Colors.brown[50],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                title: Text(
                                  order.staffName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      'SĐT: ${order.staffPhone}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      'Thời gian: ${DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      'Tổng tiền: ${currencyFormat.format(order.totalPrice)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                children: order.items.map((item) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: Colors.grey,
                                          width: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: Text(item.title)),
                                        Text(
                                          '${item.quantity} x ${currencyFormat.format(item.price)}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          currencyFormat.format(
                                            item.quantity * item.price,
                                          ),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
