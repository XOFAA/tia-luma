import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

      // 👉 Home (sem precisar de extra)
      GoRoute(
        path: "/home",
        builder: (context, state) => const HomePage(),
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
