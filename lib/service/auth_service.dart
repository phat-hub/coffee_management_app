import 'pocketbase_client.dart';
import '../model/user.dart';

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

    final auth = await pb.collection('users').authWithPassword(email, password);

    final user = User.fromJson(auth.record.toJson());

    if (!user.isActive) {
      throw Exception('Tài khoản đã bị khóa');
    }

    return user;
  }

  Future<void> createStaff(User user, String password) async {
    final pb = await getPocketbaseInstance();

    await pb
        .collection('users')
        .create(
          body: {
            ...user.toJson(),
            'password': password,
            'passwordConfirm': password,
            'role': 'staff',
            'isActive': true,
          },
        );
  }

  Future<List<User>> fetchStaff() async {
    final pb = await getPocketbaseInstance();

    final list = await pb
        .collection('users')
        .getFullList(filter: 'role="staff"');

    return list.map((e) => User.fromJson(e.toJson())).toList();
  }

  Future<void> updateStaff(User user) async {
    final pb = await getPocketbaseInstance();
    await pb.collection('users').update(user.id!, body: user.toJson());
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
}
