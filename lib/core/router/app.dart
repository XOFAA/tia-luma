import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tia_luma/core/models/usuario_model.dart';
import 'package:tia_luma/feature/onboarding/viewmodel/onboarding_viewmodel.dart';
import '../../feature/onboarding/view/onboarding_page.dart';
import '../../feature/home/view/home_page.dart';
import '../../feature/onboarding/view/loading_page.dart';   // 👈 importa
import '../../feature/onboarding/view/finished_page.dart'; // 👈 importa

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    routes: [
      // 👉 Onboarding inicial
      GoRoute(
        path: "/",
        builder: (context, state) => const OnboardingPage(),
      ),

      // 👉 Home (recebe usuário)
      GoRoute(
        path: "/home",
        builder: (context, state) {
          final usuario = state.extra as Usuario;
          return HomePage(usuario: usuario);
        },
      ),

      // 👉 Loading
   GoRoute(
  path: "/loading",
  builder: (context, state) {
    final vm = state.extra as OnboardingViewModel;
    return LoadingPage(viewModel: vm);
  },
),
GoRoute(
  path: "/finished",
  builder: (context, state) {
    final vm = state.extra as OnboardingViewModel;
    return FinishedPage(viewModel: vm);
  },
),



    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}
