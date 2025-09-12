import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tia_luma/core/models/usuario_model.dart';
import 'package:tia_luma/feature/chat/view/chat_page.dart';
import 'package:tia_luma/feature/onboarding/viewmodel/onboarding_viewmodel.dart';
import '../../feature/onboarding/view/onboarding_page.dart';
import '../../feature/home/view/home_page.dart';
import '../../feature/onboarding/view/loading_page.dart';
import '../../feature/onboarding/view/finished_page.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

final GoRouter _router = GoRouter(
    routes: [
      // 👉 Onboarding inicial
      GoRoute(
        path: "/",
        builder: (context, state) => const OnboardingPage(),
      ),

      // 👉 Home
GoRoute(
  path: "/home",
  builder: (context, state) {
    final usuario = state.extra as Usuario; // recebe o usuario passado lá do FinishedPage
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

      // 👉 Finished
      GoRoute(
        path: "/finished",
        builder: (context, state) {
          final vm = state.extra as OnboardingViewModel;
          return FinishedPage(viewModel: vm);
        },
      ),

      // 👉 ChatPage
      GoRoute(
        path: "/chat",
        builder: (context, state) {
          final userId = state.extra as String;
          return ChatPage(userId: userId);
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
