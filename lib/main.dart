import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'manager/auth_manager.dart';
import 'ui/auth/auth_screen.dart';
import 'ui/home/home_screen.dart';
import 'ui/auth/staff_screen.dart';
import 'ui/auth/edit_staff_screen.dart';
import 'ui/auth/create_staff_screen.dart';
import 'model/user.dart';

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

    ///  Chỉ tạo 1 lần duy nhất
    authManager = AuthManager();

    ///  Router cũng chỉ tạo 1 lần
    router = GoRouter(
      debugLogDiagnostics: true,
      initialLocation: '/auto-login',
      refreshListenable: authManager,

      redirect: (context, state) {
        final isAuth = authManager.isAuth;
        final isOwner = authManager.isOwner;

        final isAtAuth = state.fullPath == '/auth';
        final isAtAutoLogin = state.fullPath == '/auto-login';

        ///  Chưa login → về auth
        if (!isAuth && !isAtAuth && !isAtAutoLogin) {
          return '/auth';
        }

        ///  Đã login mà vào auth → về home
        if (isAuth && (isAtAuth || isAtAutoLogin)) {
          return '/home';
        }

        ///  Staff không được vào route owner
        final ownerRoutes = ['/staff', '/create-staff', '/edit-staff'];

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

        /// AUTO LOGIN
        GoRoute(
          path: '/auto-login',
          builder: (context, state) {
            return FutureBuilder(
              future: authManager.tryAutoLogin(),
              builder: (context, snapshot) {
                return const SafeArea(
                  child: Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
                );
              },
            );
          },
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

        /// STAFF LIST
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: authManager)],
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
