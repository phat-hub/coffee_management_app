import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

import '../model/product.dart';
import '../ui/shared/app_exception.dart';
import 'pocketbase_client.dart';

class ProductService {
  String _getImageUrl(PocketBase pb, RecordModel model) {
    final fileName = model.getStringValue('image');
    return pb.files.getUrl(model, fileName).toString();
  }

  Future<List<Product>> fetchProducts() async {
    final pb = await getPocketbaseInstance();

    final list = await pb
        .collection('products')
        .getFullList(expand: 'categoryId');

    return list.map((e) {
      final expand = e.expand['categoryId']?.first;

      return Product.fromJson({
        ...e.toJson(),
        'imageUrl': _getImageUrl(pb, e),
        'categoryName': expand?.getStringValue('title') ?? '',
      });
    }).toList();
  }

  Future<void> createProduct(Product product) async {
    final pb = await getPocketbaseInstance();

    await _validateDuplicateName(product.title, currentId: null);

    await pb
        .collection('products')
        .create(
          body: {...product.toJson(), 'createdBy': pb.authStore.record!.id},
          files: [
            http.MultipartFile.fromBytes(
              'image',
              await product.imageFile!.readAsBytes(),
              filename: product.imageFile!.path.split('/').last,
            ),
          ],
        );
  }

  Future<void> updateProduct(Product product) async {
    final pb = await getPocketbaseInstance();

    await _validateDuplicateName(product.title, currentId: product.id);

    await pb
        .collection('products')
        .update(
          product.id!,
          body: product.toJson(),
          files: product.imageFile != null
              ? [
                  http.MultipartFile.fromBytes(
                    'image',
                    await product.imageFile!.readAsBytes(),
                    filename: product.imageFile!.path.split('/').last,
                  ),
                ]
              : [],
        );
  }

  Future<void> deleteProduct(String id) async {
    final pb = await getPocketbaseInstance();
    await pb.collection('products').delete(id);
  }

  Future<void> _validateDuplicateName(String title, {String? currentId}) async {
    final pb = await getPocketbaseInstance();

    final list = await pb.collection('products').getFullList();

    final normalizedTitle = title.trim().toLowerCase();

    final isDuplicate = list.any((item) {
      final itemTitle = item.getStringValue('title').trim().toLowerCase();

      final isSameName = itemTitle == normalizedTitle;

      if (!isSameName) return false;

      if (currentId == null) return true;

      return item.id != currentId;
    });

    if (isDuplicate) {
      throw AppException('Tên sản phẩm đã tồn tại');
    }
  }
}
