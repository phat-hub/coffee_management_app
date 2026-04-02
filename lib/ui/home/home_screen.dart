import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../manager/product_manager.dart';
import '../../manager/category_manager.dart';
import '../../manager/cart_manager.dart';
import '../../model/product.dart';
import '../shared/app_drawer.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;

  final NumberFormat currencyFormat = NumberFormat("#,##0", "vi_VN");
  final TextEditingController _searchController = TextEditingController();

  String _searchKeyword = '';
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await context.read<ProductManager>().fetchProducts();
      await context.read<CategoryManager>().fetchCategories();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// --- Modal thêm sản phẩm vào giỏ hàng ---
  void _showAddToCartModal(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        int quantity = 1;

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${currencyFormat.format(product.price)} VNĐ',
                                style: const TextStyle(
                                  color: Colors.brown,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Số lượng'),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (quantity > 1) {
                                  setState(() {
                                    quantity--;
                                  });
                                }
                              },
                              icon: const Icon(Icons.remove),
                            ),
                            Text(quantity.toString()),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  quantity++;
                                });
                              },
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CartManager>().addProduct(
                          product,
                          quantity: quantity,
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Thêm vào giỏ hàng'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// --- Modal chi tiết giỏ hàng ---
  void _showCartDetailsModal() {
    final cart = context.read<CartManager>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
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
                            '${currencyFormat.format(item.product.price)} VNĐ',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  final newQty = item.quantity - 1;
                                  cart.updateQuantity(item.product, newQty);
                                  setState(() {});
                                },
                                icon: const Icon(Icons.remove),
                              ),
                              Text(item.quantity.toString()),
                              IconButton(
                                onPressed: () {
                                  cart.updateQuantity(
                                    item.product,
                                    item.quantity + 1,
                                  );
                                  setState(() {});
                                },
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
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
                            if (cart.items.isEmpty) {
                              Navigator.pop(context); // đóng modal trước

                              Future.delayed(
                                const Duration(milliseconds: 200),
                                () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Vui lòng chọn sản phẩm'),
                                    ),
                                  );
                                },
                              );

                              return;
                            }

                            Navigator.pop(context);
                            context.push('/checkout');
                          },
                          child: const Text('Tiếp'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductManager>().products;
    final categories = context.watch<CategoryManager>().categories;

    final filteredProducts = products.where((product) {
      final matchCategory =
          _selectedCategoryId == null ||
          product.categoryId == _selectedCategoryId;

      final matchKeyword = product.title.toLowerCase().contains(
        _searchKeyword.toLowerCase(),
      );

      return matchCategory && matchKeyword;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Coffee Manager"), centerTitle: true),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// SEARCH + FILTER
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm sản phẩm...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchKeyword = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        decoration: InputDecoration(
                          labelText: 'Lọc theo danh mục',
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Tất cả danh mục'),
                          ),
                          ...categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category.id,
                              child: Text(category.title),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                /// PRODUCT GRID
                Expanded(
                  child: filteredProducts.isEmpty
                      ? const Center(
                          child: Text(
                            "Không tìm thấy sản phẩm",
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GridView.builder(
                            itemCount: filteredProducts.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
                                  childAspectRatio: 0.72,
                                ),
                            itemBuilder: (_, index) {
                              final product = filteredProducts[index];

                              return Card(
                                elevation: 6,
                                shadowColor: Colors.brown.withOpacity(0.15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// IMAGE FIXED SIZE
                                    SizedBox(
                                      height: 150,
                                      width: double.infinity,
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(18),
                                            ),
                                        child: Image.network(
                                          product.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Center(
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  size: 60,
                                                ),
                                              ),
                                        ),
                                      ),
                                    ),

                                    /// INFO
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    product.title,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),

                                                  /// PRICE ONE LINE
                                                  FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      '${currencyFormat.format(product.price)} VNĐ',
                                                      style: const TextStyle(
                                                        color: Colors.brown,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(width: 8),

                                            /// CART BUTTON
                                            SizedBox(
                                              width: 42,
                                              height: 42,
                                              child: Material(
                                                color: Colors.brown.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  onTap: () {
                                                    _showAddToCartModal(
                                                      product,
                                                    );
                                                  },
                                                  child: const Icon(
                                                    Icons
                                                        .shopping_cart_outlined,
                                                    color: Colors.brown,
                                                    size: 22,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),

      /// --- Bottom Cart Bar ---
      bottomNavigationBar: Consumer<CartManager>(
        builder: (context, cart, _) {
          if (cart.totalItems == 0) return const SizedBox.shrink();

          return GestureDetector(
            onTap: _showCartDetailsModal,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.brown.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shopping_cart),
                      const SizedBox(width: 8),
                      Text('${cart.totalItems} sản phẩm'),
                    ],
                  ),
                  Text(
                    '${currencyFormat.format(cart.totalPrice)} VNĐ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
