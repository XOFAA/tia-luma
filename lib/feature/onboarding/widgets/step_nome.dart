import 'package:flutter/material.dart';
import '../viewmodel/onboarding_viewmodel.dart';

class StepNome extends StatefulWidget {
  final OnboardingViewModel viewModel;
  final PageController controller;

  const StepNome({
    super.key,
    required this.viewModel,
    required this.controller,
  });

  @override
  State<StepNome> createState() => _StepNomeState();
}

class _StepNomeState extends State<StepNome> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text("1/4",
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: 0.33,
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
                          "Como posso te chamar?",
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xff41075E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xffD288E1)),
                  ),
                  child: TextField(
                    controller: _controller,
                    onChanged: (val) {
                      widget.viewModel.nome.value = val; // 👈 atualiza ValueNotifier
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Qual é o seu nome?",
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
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
