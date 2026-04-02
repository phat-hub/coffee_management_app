import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/auth_manager.dart';
import '../../model/user.dart';
import 'package:go_router/go_router.dart';

class CreateStaffScreen extends StatefulWidget {
  const CreateStaffScreen({super.key});

  @override
  State<CreateStaffScreen> createState() => _CreateStaffScreenState();
}

class _CreateStaffScreenState extends State<CreateStaffScreen> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final address = TextEditingController();
  final password = TextEditingController();

  bool _obscurePassword = true;
  bool loading = false;

  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  final phoneRegex = RegExp(r'^(0|\+84)[0-9]{9}$');

  /// 🔥 VALIDATE KHÔNG GÂY GIẬT
  String? _validate() {
    if (name.text.trim().isEmpty) return 'Không được để trống tên';

    if (phone.text.isEmpty) return 'Không được để trống số điện thoại';
    if (!phoneRegex.hasMatch(phone.text)) return 'Số điện thoại không hợp lệ';

    if (email.text.isEmpty) return 'Không được để trống email';
    if (!emailRegex.hasMatch(email.text)) return 'Email không hợp lệ';

    if (address.text.isEmpty) return 'Không được để trống địa chỉ';

    if (password.text.isEmpty) return 'Không được để trống mật khẩu';
    if (password.text.length < 8) return 'Mật khẩu phải ≥ 8 ký tự';

    return null;
  }

  Future<void> submit() async {
    final error = _validate();

    if (error != null) {
      FocusScope.of(context).unfocus(); //  tắt bàn phím

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error),
            behavior: SnackBarBehavior.floating, //  màu mặc định
          ),
        );

      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => loading = true);

    try {
      final user = User(
        name: name.text.trim(),
        phoneNumber: phone.text.trim(),
        email: email.text.trim(),
        address: address.text.trim(),
        role: 'staff',
        isActive: true,
      );

      await context.read<AuthManager>().createStaff(user, password.text);

      context.go('/staff');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 🔥 giữ UI cố định

      appBar: AppBar(title: const Text('Thêm nhân viên')),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Họ và tên'),
            ),

            TextField(
              controller: phone,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
              keyboardType: TextInputType.phone,
            ),

            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),

            TextField(
              controller: address,
              decoration: const InputDecoration(labelText: 'Địa chỉ'),
            ),

            TextField(
              controller: password,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: submit, child: const Text('Tạo')),
          ],
        ),
      ),
    );
  }
}
