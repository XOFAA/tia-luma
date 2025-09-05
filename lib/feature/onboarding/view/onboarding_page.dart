import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../home/view/home_page.dart';
import '../viewmodel/onboarding_viewmodel.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  final viewModel = OnboardingViewModel();

  int _currentPage = 0;

  void nextPage() async {
    if (_currentPage < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await viewModel.salvarUsuario();
      if (mounted) {
        context.go("/home"); // navega para home
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: [
          // Etapa 1 - Nome
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Qual é o seu nome?"),
                TextField(
                  onChanged: (val) => viewModel.nome = val,
                ),
              ],
            ),
          ),
          // Etapa 2 - Ano Escolar
          Center(
            child: DropdownButton<String>(
              value: viewModel.anoEscolar.isEmpty ? null : viewModel.anoEscolar,
              hint: const Text("Selecione seu ano escolar"),
              items: ["6º ano", "7º ano", "8º ano", "9º ano", "1º EM", "2º EM", "3º EM"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => viewModel.anoEscolar = val!),
            ),
          ),
          // Etapa 3 - Matérias
          Center(
            child: Wrap(
              spacing: 10,
              children: viewModel.materiasDisponiveis.map((materia) {
                final selecionado = viewModel.materiasFoco.contains(materia);
                return ChoiceChip(
                  label: Text(materia),
                  selected: selecionado,
                  onSelected: (_) => setState(() {
                    viewModel.toggleMateria(materia);
                  }),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: nextPage,
          child: Text(_currentPage == 2 ? "Finalizar" : "Próximo"),
        ),
      ),
    );
  }
}
