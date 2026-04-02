import '../model/category.dart';
import 'pocketbase_client.dart';
import '../ui/shared/app_exception.dart';

class CategoryService {
  Future<List<Category>> fetchCategories() async {
    final pb = await getPocketbaseInstance();

    final list = await pb.collection('categories').getFullList();

    return list.map((e) => Category.fromJson(e.toJson())).toList();
  }

  Future<void> createCategory(Category category) async {
    final pb = await getPocketbaseInstance();

    await pb
        .collection('categories')
        .create(
          body: {...category.toJson(), 'createdBy': pb.authStore.record!.id},
        );
  }

  Future<void> updateCategory(Category category) async {
    final pb = await getPocketbaseInstance();

    await pb
        .collection('categories')
        .update(category.id!, body: category.toJson());
  }

  Future<void> deleteCategory(String id) async {
    final pb = await getPocketbaseInstance();

    //  kiểm tra có product thuộc category này không
    final products = await pb
        .collection('products')
        .getFullList(filter: 'categoryId = "$id"');

    if (products.isNotEmpty) {
      throw AppException(
        'Không thể xóa danh mục vì có sản phẩm thuộc danh mục này',
      );
    }

    await pb.collection('categories').delete(id);
  }
}
