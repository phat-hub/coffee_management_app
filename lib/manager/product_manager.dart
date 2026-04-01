import 'package:flutter/material.dart';
import '../model/product.dart';
import '../service/product_service.dart';

class ProductManager with ChangeNotifier {
  final ProductService _service = ProductService();

  List<Product> _products = [];

  List<Product> get products => _products;

  Future<void> fetchProducts() async {
    _products = await _service.fetchProducts();
    notifyListeners();
  }

  Future<void> createProduct(Product product) async {
    await _service.createProduct(product);
    await fetchProducts();
  }

  Future<void> updateProduct(Product product) async {
    await _service.updateProduct(product);
    await fetchProducts();
  }

  Future<void> deleteProduct(String id) async {
    await _service.deleteProduct(id);
    await fetchProducts();
  }
}
