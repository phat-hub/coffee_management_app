import 'package:ct484_project/ui/shared/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../manager/product_manager.dart';
import '../../manager/category_manager.dart';

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
                                  childAspectRatio: 0.78,
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
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(18),
                                            ),
                                        child: Image.network(
                                          product.imageUrl,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
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

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  product.title,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${currencyFormat.format(product.price)} VNĐ',
                                                  style: const TextStyle(
                                                    color: Colors.brown,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
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
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                onTap: () {},
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
                ),
              ],
            ),
    );
  }
}
