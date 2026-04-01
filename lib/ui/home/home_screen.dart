import 'package:ct484_project/ui/shared/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../manager/product_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;

  final NumberFormat currencyFormat = NumberFormat("#,##0", "vi_VN");

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await context.read<ProductManager>().fetchProducts();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductManager>().products;

    return Scaffold(
      appBar: AppBar(title: const Text("Coffee Manager"), centerTitle: true),

      drawer: const AppDrawer(),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
          ? const Center(
              child: Text("Chưa có sản phẩm", style: TextStyle(fontSize: 18)),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (_, index) {
                  final product = products[index];

                  return Card(
                    elevation: 6,
                    shadowColor: Colors.brown.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(18),
                            ),
                            child: Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 60,
                                ),
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      product.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    RichText(
                                      maxLines: 2,
                                      text: TextSpan(
                                        style: const TextStyle(
                                          color: Colors.brown,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          height: 1.2,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: currencyFormat.format(
                                              product.price,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: ' VNĐ',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              SizedBox(
                                width: 40,
                                height: 40,
                                child: Material(
                                  color: Colors.brown.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      // TODO: xử lý giỏ hàng sau
                                    },
                                    child: const Icon(
                                      Icons.shopping_cart_outlined,
                                      color: Colors.brown,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
