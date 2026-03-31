import 'package:ct484_project/ui/shared/app_drawer.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Coffee Manager ☕")),
      drawer: const AppDrawer(),
    );
  }
}
