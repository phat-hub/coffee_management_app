import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/auth_manager.dart';
import '../../model/user.dart';
import 'package:go_router/go_router.dart';

class EditStaffScreen extends StatefulWidget {
  final User user;

  const EditStaffScreen({super.key, required this.user});

  @override
  State<EditStaffScreen> createState() => _EditStaffScreenState();
}

class _EditStaffScreenState extends State<EditStaffScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController name;
  late TextEditingController phone;
  late TextEditingController address;

  final phoneRegex = RegExp(r'^(0|\+84)[0-9]{9}$');

  bool loading = false;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.user.name);
    phone = TextEditingController(text: widget.user.phoneNumber);
    address = TextEditingController(text: widget.user.address);
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final updated = widget.user.copyWith(
        name: name.text.trim(),
        phoneNumber: phone.text.trim(),
        address: address.text.trim(),
      );

      await context.read<AuthManager>().updateStaff(updated);

      context.go('/staff');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sửa nhân viên')),
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
                    return 'Không được để trống';
                  }
                  return null;
                },
              ),

              /// PHONE
              TextFormField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
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

              /// ADDRESS
              TextFormField(
                controller: address,
                decoration: const InputDecoration(labelText: 'Địa chỉ'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Không được để trống';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: submit,
                      child: const Text('Cập nhật'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
