import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'manager/auth_manager.dart';
import 'manager/product_manager.dart';

import 'ui/auth/auth_screen.dart';
import 'ui/home/home_screen.dart';
import 'ui/auth/staff_screen.dart';
import 'ui/auth/edit_staff_screen.dart';
import 'ui/auth/create_staff_screen.dart';
import 'ui/auth/view_staff_screen.dart';

import 'ui/home/edit_product_screen.dart';
import 'ui/home/product_management_screen.dart';
import 'ui/home/category_management_screen.dart';

import 'model/user.dart';
import 'model/product.dart';
import 'manager/category_manager.dart';
import 'manager/cart_manager.dart';
import 'ui/order/checkout_screen.dart';
import 'ui/order/order_list_screen.dart';
import 'manager/order_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthManager authManager;
  late final GoRouter router;

  @override
  void initState() {
    super.initState();

    /// tạo 1 instance duy nhất
    authManager = AuthManager();

    /// router tạo 1 lần duy nhất
    router = GoRouter(
      debugLogDiagnostics: true,
      initialLocation: '/auth',
      refreshListenable: authManager,

      redirect: (context, state) {
        final isAuth = authManager.isAuth;
        final isOwner = authManager.isOwner;

        final isAtAuth = state.fullPath == '/auth';

        /// chưa login → về auth
        if (!isAuth && !isAtAuth) {
          return '/auth';
        }

        /// đã login mà vào auth → về home
        if (isAuth && isAtAuth) {
          return '/home';
        }

        /// route chỉ owner được vào
        final ownerRoutes = [
          '/staff',
          '/create-staff',
          '/edit-staff',
          '/view-staff',
          '/products',
          '/create-product',
          '/edit-product',
        ];

        if (ownerRoutes.contains(state.fullPath) && !isOwner) {
          return '/home';
        }

        return null;
      },

      routes: [
        /// AUTH
        GoRoute(
          path: '/auth',
          builder: (context, state) => const SafeArea(child: AuthScreen()),
        ),

        /// LOGOUT
        GoRoute(
          path: '/logout',
          builder: (context, state) {
            return FutureBuilder(
              future: authManager.logout(),
              builder: (context, snapshot) =>
                  const SafeArea(child: AuthScreen()),
            );
          },
        ),

        /// HOME
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

        /// STAFF
        GoRoute(
          path: '/staff',
          builder: (context, state) => const StaffScreen(),
        ),

        /// CREATE STAFF
        GoRoute(
          path: '/create-staff',
          builder: (context, state) =>
              const SafeArea(child: CreateStaffScreen()),
        ),

        /// EDIT STAFF
        GoRoute(
          path: '/edit-staff',
          builder: (context, state) {
            final user = state.extra as User;
            return SafeArea(child: EditStaffScreen(user: user));
          },
        ),

        /// VIEW STAFF
        GoRoute(
          path: '/view-staff',
          builder: (context, state) {
            final user = state.extra as User;
            return SafeArea(child: ViewStaffScreen(user: user));
          },
        ),

        /// PRODUCT LIST
        GoRoute(
          path: '/products',
          builder: (context, state) => const ProductManagementScreen(),
        ),

        /// CREATE PRODUCT
        GoRoute(
          path: '/create-product',
          builder: (context, state) => const EditProductScreen(),
        ),

        /// EDIT PRODUCT
        GoRoute(
          path: '/edit-product',
          builder: (context, state) {
            final product = state.extra as Product;
            return EditProductScreen(product: product);
          },
        ),
        GoRoute(
          path: '/categories',
          builder: (context, state) => const CategoryManagementScreen(),
        ),
        GoRoute(
          path: '/checkout',
          builder: (context, state) => const CheckoutScreen(),
        ),
        GoRoute(
          path: '/orders',
          builder: (context, state) => const OrderListScreen(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authManager),
        ChangeNotifierProvider(create: (_) => ProductManager()),
        ChangeNotifierProvider(create: (_) => CategoryManager()),
        ChangeNotifierProvider(create: (_) => CartManager()),
        ChangeNotifierProvider(create: (_) => OrderManager()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6F4E37)),
        ),
      ),
    );
  }
}
