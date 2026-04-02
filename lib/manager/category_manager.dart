import 'package:flutter/material.dart';
import '../model/category.dart';
import '../service/category_service.dart';
import '../ui/shared/app_exception.dart';

class CategoryManager with ChangeNotifier {
  final CategoryService _service = CategoryService();

  List<Category> _categories = [];

  List<Category> get categories => _categories;

  Future<void> fetchCategories() async {
    _categories = await _service.fetchCategories();
    notifyListeners();
  }

  Future<void> createCategory(Category category) async {
    if (isDuplicateName(category.title)) {
      throw AppException("Danh mục đã tồn tại");
    }

    await _service.createCategory(category);
    await fetchCategories();
  }

  Future<void> updateCategory(Category category) async {
    if (isDuplicateName(category.title, excludeId: category.id)) {
      throw AppException("Danh mục đã tồn tại");
    }

    await _service.updateCategory(category);
    await fetchCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _service.deleteCategory(id);
    await fetchCategories();
  }

  bool isDuplicateName(String title, {String? excludeId}) {
    return _categories.any((c) {
      final sameName =
          c.title.toLowerCase().trim() == title.toLowerCase().trim();

      /// nếu đang edit thì bỏ qua chính nó
      final isNotSelf = excludeId == null || c.id != excludeId;

      return sameName && isNotSelf;
    });
  }
}
