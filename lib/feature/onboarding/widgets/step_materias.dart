import 'package:flutter/material.dart';
import '../viewmodel/onboarding_viewmodel.dart';

class StepMaterias extends StatefulWidget {
  final OnboardingViewModel viewModel;
  final PageController controller;

  const StepMaterias({
    super.key,
    required this.viewModel,
    required this.controller,
  });

  @override
  State<StepMaterias> createState() => _StepMateriasState();
}

class _StepMateriasState extends State<StepMaterias> {
  @override
  Widget build(BuildContext context) {
    final materias = widget.viewModel.materiasDisponiveis;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👉 Barra de progresso
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white70),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          widget.controller.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "4/4",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: 1.0,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.purpleAccent,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 👉 Personagem + fala
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset("assets/images/face.png", height: 100),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(color: Colors.white70),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          "Qual conteúdo você deseja aprender mais?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: "Nunito",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 👉 Grid de matérias
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.9,
                        ),
                    itemCount: materias.length,
                    itemBuilder: (context, index) {
                      final materia = materias[index];
                      final selecionado = widget.viewModel.materiasFoco.value
                          .contains(materia);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            widget.viewModel.toggleMateria(materia);
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: selecionado
                                ? Colors.green.withOpacity(0.2)
                                : const Color(0xff41075E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selecionado
                                  ? Colors.greenAccent
                                  : const Color(0xffD288E1),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 👉 Ajustar nomes dos ícones conforme seus assets
                              Image.asset(
                                "assets/images/quimica.png", // 👈 único ícone
                                height: 40,
                              ),

                              const SizedBox(height: 8),
                              Text(
                                materia,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: "Nunito",
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
