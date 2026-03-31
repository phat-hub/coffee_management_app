import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'manager/auth_manager.dart';
import 'ui/auth/auth_screen.dart';
import 'ui/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthManager(),
      child: Consumer<AuthManager>(
        builder: (context, auth, _) {
          final router = GoRouter(
            refreshListenable: auth,
            initialLocation: '/auth',
            routes: [
              GoRoute(
                path: '/auth',
                builder: (context, state) => const AuthScreen(),
              ),
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
            redirect: (context, state) {
              final loggedIn = auth.isAuth;
              final goingToAuth = state.matchedLocation == '/auth';

              if (!loggedIn && !goingToAuth) return '/auth';
              if (loggedIn && goingToAuth) return '/home';

              return null;
            },
          );

          return MaterialApp.router(
            routerConfig: router,
            debugShowCheckedModeBanner: false,

            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6F4E37),
              ),
            ),
          );
        },
      ),
    );
  }
}
