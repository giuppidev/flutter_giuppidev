import 'package:flutter/material.dart';
import 'package:flutter_giuppidev/pages/courses.dart';
import 'package:flutter_giuppidev/pages/login.dart';
import 'package:flutter_giuppidev/pages/splashscreen.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config.dart' show supabaseKeys;

final _router = GoRouter(initialLocation: "/", routes: [
  GoRoute(
    path: "/",
    builder: (context, state) => const SplashScreen(),
  ),
  GoRoute(
    path: "/login",
    builder: (context, state) => const LoginPage(),
  ),
  GoRoute(
    path: "/courses",
    builder: (context, state) => const CoursesPage(),
  )
]);

Future<void> main() async {
  await Supabase.initialize(
    url: supabaseKeys['url']!,
    anonKey: supabaseKeys['anon']!,
    authFlowType: AuthFlowType.pkce,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: "Flutter hello",
    );
  }
}

final supabase = Supabase.instance.client;
