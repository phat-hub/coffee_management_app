import 'package:flutter/material.dart';
import '../../model/user.dart';

class ViewStaffScreen extends StatefulWidget {
  final User user;

  const ViewStaffScreen({super.key, required this.user});

  @override
  State<ViewStaffScreen> createState() => _ViewStaffScreenState();
}

class _ViewStaffScreenState extends State<ViewStaffScreen> {
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin nhân viên')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                infoRow('Họ tên', user.name),
                infoRow('Số điện thoại', user.phoneNumber),
                infoRow('Email', user.email),
                infoRow('Địa chỉ', user.address),
                infoRow('Vai trò', user.role),
                infoRow(
                  'Trạng thái',
                  user.isActive ? 'Đang hoạt động' : 'Đã khóa',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
