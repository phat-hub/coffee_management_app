import 'pocketbase_client.dart';
import '../model/user.dart';
import '../ui/shared/app_exception.dart';

class AuthService {
  void Function(User? user)? onAuthChange;

  AuthService({this.onAuthChange}) {
    if (onAuthChange != null) {
      getPocketbaseInstance().then((pb) {
        pb.authStore.onChange.listen((event) {
          onAuthChange!(
            event.record == null ? null : User.fromJson(event.record!.toJson()),
          );
        });
      });
    }
  }

  Future<User> login(String email, String password) async {
    final pb = await getPocketbaseInstance();

    try {
      final auth = await pb
          .collection('users')
          .authWithPassword(email, password);

      final user = User.fromJson(auth.record.toJson());

      return user;
    } catch (e) {
      throw AppException('Đăng nhập thất bại');
    }
  }

  Future<void> createStaff(User user, String password) async {
    final pb = await getPocketbaseInstance();

    try {
      /// PHONE TRƯỚC
      final phoneList = await pb
          .collection('users')
          .getFullList(filter: 'phoneNumber="${user.phoneNumber}"');

      if (phoneList.isNotEmpty) {
        throw AppException('Số điện thoại đã tồn tại');
      }

      await pb
          .collection('users')
          .create(
            body: {
              ...user.toJson(),
              'password': password,
              'passwordConfirm': password,
              'role': 'staff',
              'isActive': true,
              'emailVisibility': true,
            },
          );
    } catch (e) {
      /// giữ lỗi custom
      if (e is AppException) rethrow;

      final error = e.toString();

      if (error.contains('email')) {
        throw AppException('Email đã tồn tại');
      }

      throw AppException('Có lỗi xảy ra');
    }
  }

  Future<List<User>> fetchStaff() async {
    final pb = await getPocketbaseInstance();

    final list = await pb
        .collection('users')
        .getFullList(filter: 'role="staff"');

    for (final item in list) {
      print('POCKETBASE RECORD: ${item.toJson()}');
    }

    return list.map((e) => User.fromJson(e.toJson())).toList();
  }

  Future<void> updateStaff(User user) async {
    final pb = await getPocketbaseInstance();

    try {
      ///  tìm user có cùng phone
      final list = await pb
          .collection('users')
          .getFullList(filter: 'phoneNumber="${user.phoneNumber}"');

      ///  nếu có user khác (id khác) thì báo trùng
      final isDuplicate = list.any((e) => e.id != user.id);

      if (isDuplicate) {
        throw AppException('Số điện thoại đã tồn tại');
      }

      ///  update nếu OK
      await pb
          .collection('users')
          .update(
            user.id!,
            body: {
              'name': user.name,
              'phoneNumber': user.phoneNumber,
              'address': user.address,
            },
          );
    } catch (e) {
      if (e is AppException) rethrow;

      throw AppException('Có lỗi xảy ra');
    }
  }

  Future<void> toggleLock(User user) async {
    final pb = await getPocketbaseInstance();

    await pb
        .collection('users')
        .update(user.id!, body: {'isActive': !user.isActive});
  }

  Future<void> logout() async {
    final pb = await getPocketbaseInstance();
    pb.authStore.clear();
  }

  Future<User?> tryAutoLogin() async {
    final pb = await getPocketbaseInstance();

    if (pb.authStore.isValid) {
      final record = pb.authStore.model;

      if (record != null) {
        return User.fromJson(record.toJson());
      }
    }

    return null;
  }
}
