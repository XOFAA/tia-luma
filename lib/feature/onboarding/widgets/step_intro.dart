import 'package:flutter/material.dart';

class StepIntro extends StatelessWidget {
  const StepIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white70),
              color: Colors.white.withOpacity(0.1),
            ),
            child: const Text(
              "Olá! Eu sou a Tia Luma!\n"
              "Sou sua professora particular virtual!\n"
              "Estou aqui para te ajudar nos estudos de forma divertida e didática.\n"
              "Vamos começar nossa jornada juntos!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: "Nunito",
              ),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: Image.asset(
              "assets/images/professora.png",
              height: 455,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
