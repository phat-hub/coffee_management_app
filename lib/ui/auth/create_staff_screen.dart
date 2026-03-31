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
  final _formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final address = TextEditingController();
  final password = TextEditingController();

  bool _obscurePassword = true;
  bool loading = false;

  /// Regex
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  final phoneRegex = RegExp(r'^(0|\+84)[0-9]{9}$');

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

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
      /// bắt lỗi email trùng từ PocketBase
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm nhân viên')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// NAME
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Họ và tên'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Không được để trống tên';
                  }
                  return null;
                },
              ),

              /// PHONE
              TextFormField(
                controller: phone,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Không được để trống';
                  }

                  if (!phoneRegex.hasMatch(value)) {
                    return 'Số điện thoại không hợp lệ';
                  }

                  return null;
                },
              ),

              /// EMAIL
              TextFormField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Không được để trống';
                  }
                  if (!emailRegex.hasMatch(value)) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),

              /// ADDRESS
              TextFormField(
                controller: address,
                decoration: const InputDecoration(labelText: 'Địa chỉ'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Không được để trống';
                  }
                  return null;
                },
              ),

              /// PASSWORD
              TextFormField(
                controller: password,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Không được để trống';
                  }
                  if (value.length < 8) {
                    return 'Mật khẩu phải ≥ 8 ký tự';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(onPressed: submit, child: const Text('Tạo')),
            ],
          ),
        ),
      ),
    );
  }
}
