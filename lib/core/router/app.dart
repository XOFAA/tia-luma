import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tia_luma/core/models/usuario_model.dart';
import '../../feature/onboarding/view/onboarding_page.dart';
import '../../feature/home/view/home_page.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(path: "/", builder: (context, state) => const OnboardingPage()),
      GoRoute(
        path: "/home",
        builder: (context, state) {
          final usuario = state.extra as Usuario; // 👈 pega o usuário
          return HomePage(usuario: usuario);
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}
