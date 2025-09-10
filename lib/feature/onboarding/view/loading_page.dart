import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/onboarding_viewmodel.dart';

class LoadingPage extends StatefulWidget {
  final OnboardingViewModel viewModel;

  const LoadingPage({super.key, required this.viewModel});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();

    // aguarda 2 segundos e vai para Finished
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go("/finished", extra: widget.viewModel); // 👈 passa viewModel
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [Color(0xFF6C287E), Color(0xFF411960), Color(0xFF0E0822)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/loading.png", height: 180),
              const SizedBox(height: 32),
              const Text(
                "Aguarde enquanto a Tia Luma está criando\nseu ambiente de estudos...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Nunito",
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
