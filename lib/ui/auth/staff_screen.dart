import 'package:ct484_project/ui/shared/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../manager/auth_manager.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AuthManager>().fetchStaff();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthManager>();

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý nhân viên')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-staff'),
        child: const Icon(Icons.add),
      ),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: auth.staffs.length,
        itemBuilder: (context, index) {
          final user = auth.staffs[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(user.name),
              subtitle: Text(user.phoneNumber),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () {
                      context.push('/view-staff', extra: user);
                    },
                  ),

                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      context.push('/edit-staff', extra: user);
                    },
                  ),

                  IconButton(
                    icon: Icon(
                      user.isActive ? Icons.lock_open : Icons.lock,
                      color: user.isActive ? Colors.green : Colors.red,
                    ),
                    onPressed: () {
                      context.read<AuthManager>().toggleLock(user);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
