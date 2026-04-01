import 'package:ct484_project/ui/shared/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../manager/product_manager.dart';
import '../../manager/category_manager.dart';
import '../../model/product.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final currencyFormat = NumberFormat("#,##0", "vi_VN");

  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await context.read<ProductManager>().fetchProducts();
      await context.read<CategoryManager>().fetchCategories();
    });
  }

  Future<void> _confirmDelete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Xác nhận xóa'),
            ],
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa sản phẩm "${product.title}" không?',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(false);
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(ctx).pop(true);
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await context.read<ProductManager>().deleteProduct(product.id!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Xóa sản phẩm thành công'),
          duration: const Duration(milliseconds: 1000),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductManager>().products;
    final categories = context.watch<CategoryManager>().categories;

    final filteredProducts = _selectedCategoryId == null
        ? products
        : products
              .where((item) => item.categoryId == _selectedCategoryId)
              .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý sản phẩm'), centerTitle: true),

      drawer: const AppDrawer(),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/create-product');
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
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
          ),

          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(
                    child: Text(
                      'Chưa có sản phẩm',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : Builder(
                    builder: (_) {
                      final Map<String, List<Product>> groupedProducts = {};

                      for (final product in filteredProducts) {
                        groupedProducts.putIfAbsent(
                          product.categoryName,
                          () => [],
                        );

                        groupedProducts[product.categoryName]!.add(product);
                      }

                      return ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: groupedProducts.entries.map((entry) {
                          final categoryName = entry.key;
                          final categoryProducts = entry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.brown.shade50,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.category,
                                      color: Colors.brown,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      categoryName,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.brown,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${categoryProducts.length} món',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              ...categoryProducts.map((product) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Card(
                                    elevation: 5,
                                    shadowColor: Colors.brown.withOpacity(0.15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(12),
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          product.imageUrl,
                                          width: 65,
                                          height: 65,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                Icons.image_not_supported,
                                                size: 40,
                                              ),
                                        ),
                                      ),
                                      title: Text(
                                        product.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '${currencyFormat.format(product.price)} VNĐ',
                                          style: const TextStyle(
                                            color: Colors.brown,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              context.push(
                                                '/edit-product',
                                                extra: product,
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              _confirmDelete(product);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),

                              const SizedBox(height: 20),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
