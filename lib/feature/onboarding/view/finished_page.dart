import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/onboarding_viewmodel.dart'; // importa o viewmodel
import '../../../core/models/usuario_model.dart'; // importa o Usuario

class FinishedPage extends StatelessWidget {
  final OnboardingViewModel viewModel;

  const FinishedPage({super.key, required this.viewModel});

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
              Image.asset("assets/images/loading.png", height: 220),
              const SizedBox(height: 32),
              const Text(
                "Tudo pronto!\nEstarei com você em todas as suas atividades e dúvidas, converse comigo sempre que tiver uma dúvida!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Nunito",
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 220,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    // 👉 salva o usuário
                    final Usuario usuario = await viewModel.salvarUsuario();

                    if (context.mounted) {
                      // 👉 vai pra Home passando o usuario
                      context.go("/home", extra: usuario);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    shadowColor: const Color(0xFF038E4B),
                  ),
                  child: const Text(
                    "ENTENDIDO",
                    style: TextStyle(
                      fontFamily: "RubikScribble",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
