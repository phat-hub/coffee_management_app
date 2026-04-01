import 'package:flutter/material.dart';
import '../model/category.dart';
import '../service/category_service.dart';

class CategoryManager with ChangeNotifier {
  final CategoryService _service = CategoryService();

  List<Category> _categories = [];

  List<Category> get categories => _categories;

  Future<void> fetchCategories() async {
    _categories = await _service.fetchCategories();
    notifyListeners();
  }

  Future<void> createCategory(Category category) async {
    await _service.createCategory(category);
    await fetchCategories();
  }

  Future<void> updateCategory(Category category) async {
    await _service.updateCategory(category);
    await fetchCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _service.deleteCategory(id);
    await fetchCategories();
  }
}
