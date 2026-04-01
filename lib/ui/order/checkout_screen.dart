import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../manager/cart_manager.dart';
import '../../manager/auth_manager.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartManager>();
    final authManager = context.watch<AuthManager>();
    final user = authManager.user;
    final currencyFormat = NumberFormat("#,##0", "vi_VN");
    final now = DateTime.now();

    // Thông tin cứng (Tên quán)
    const cafeName = "Coffee Manager Shop";

    // Nếu user != null thì lấy từ user, nếu null fallback
    final staffName = user?.name ?? "Nhân viên";
    final phoneNumber = user?.phoneNumber ?? "0000000000";

    return Scaffold(
      appBar: AppBar(title: const Text("Thanh toán"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- THÔNG TIN ---
            Text('Tên quán: $cafeName', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text('Nhân viên: $staffName', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text('SĐT: $phoneNumber', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              'Thời gian: ${DateFormat('dd/MM/yyyy HH:mm').format(now)}',
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(height: 20, thickness: 2),

            /// --- DANH SÁCH SẢN PHẨM ---
            Expanded(
              child: cart.items.isEmpty
                  ? const Center(child: Text('Không có sản phẩm'))
                  : ListView.builder(
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        return ListTile(
                          leading: SizedBox(
                            width: 50,
                            height: 50,
                            child: Image.network(
                              item.product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                          ),
                          title: Text(item.product.title),
                          subtitle: Text(
                            '${item.quantity} x ${currencyFormat.format(item.product.price)} VNĐ',
                          ),
                          trailing: Text(
                            '${currencyFormat.format(item.totalPrice)} VNĐ',
                          ),
                        );
                      },
                    ),
            ),

            /// --- TỔNG TIỀN + NÚT THANH TOÁN ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng: ${currencyFormat.format(cart.totalPrice)} VNĐ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: xử lý thanh toán
                  },
                  child: const Text('Thanh toán'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
