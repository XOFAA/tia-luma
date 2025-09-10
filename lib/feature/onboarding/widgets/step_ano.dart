import 'package:flutter/material.dart';
import '../viewmodel/onboarding_viewmodel.dart';

class StepAno extends StatefulWidget {
  final OnboardingViewModel viewModel;
  final PageController controller;

  const StepAno({
    super.key,
    required this.viewModel,
    required this.controller,
  });

  @override
  State<StepAno> createState() => _StepAnoState();
}

class _StepAnoState extends State<StepAno> {
  String? anoSelecionado;
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final anos = widget.viewModel.anosDisponiveis;

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
                    const Text("3/4",
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: 0.75,
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
                    const SizedBox(width: 50),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(color: Colors.white70),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          "Em qual série você está estudando?",
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

                // 👉 Campo de seleção
                GestureDetector(
                  onTap: () => setState(() => expanded = !expanded),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xff41075E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xffD288E1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          anoSelecionado ?? "Qual a sua série?",
                          style: TextStyle(
                            color: anoSelecionado == null
                                ? Colors.white70
                                : Colors.white,
                          ),
                        ),
                        Icon(
                          expanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),

                if (expanded)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xff41075E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xffD288E1)),
                      ),
                      child: ListView.builder(
                        itemCount: anos.length,
                        itemBuilder: (context, index) {
                          final ano = anos[index];
                          return ListTile(
                            title: Text(
                              ano,
                              style: const TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              setState(() {
                                anoSelecionado = ano;
                                widget.viewModel.anoEscolar.value = ano;
                                expanded = false;
                              });
                            },
                          );
                        },
                      ),
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
