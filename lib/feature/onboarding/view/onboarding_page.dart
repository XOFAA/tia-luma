import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tia_luma/feature/onboarding/widgets/step_ano.dart';
import 'package:tia_luma/feature/onboarding/widgets/step_escola.dart';
import 'package:tia_luma/feature/onboarding/widgets/step_intro.dart';
import 'package:tia_luma/feature/onboarding/widgets/step_materias.dart';
import 'package:tia_luma/feature/onboarding/widgets/step_nome.dart';
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

  void nextPage() {
    if (_currentPage < 4) {
      // 👉 avança dentro do onboarding normal
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // 👉 última etapa (materias)
       context.go("/loading", extra: viewModel); // 👈 passa junto
    }
  }

  String _buttonText() {
    if (_currentPage == 0) return "VAMOS COMEÇAR";
    if (_currentPage == 4) return "FINALIZAR";
    return "CONTINUAR";
  }

  /// 👉 Retorna o listenable atual (String ou List<String>)
  ValueListenable<Object?> currentListenable() {
    if (_currentPage == 1) return viewModel.nome;
    if (_currentPage == 2) return viewModel.escola;
    if (_currentPage == 3) return viewModel.anoEscolar;
    if (_currentPage == 4) return viewModel.materiasFoco;
    return ValueNotifier("ok");
  }

  bool _isEnabled(Object? value) {
    if (_currentPage == 0) return true;
    if (_currentPage == 1 && value is String) return value.isNotEmpty;
    if (_currentPage == 2 && value is String) return value.isNotEmpty;
    if (_currentPage == 3 && value is String) return value.isNotEmpty;
    if (_currentPage == 4 && value is List<String>) return value.isNotEmpty;
    return false;
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
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    FocusScope.of(context).unfocus();
                  },
                  children: [
                    const StepIntro(),
                    StepNome(viewModel: viewModel, controller: _controller),
                    StepEscola(viewModel: viewModel, controller: _controller),
                    StepAno(viewModel: viewModel, controller: _controller),
                    StepMaterias(viewModel: viewModel, controller: _controller),
                  ],
                ),
              ),

              // 👉 Botão fixo
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ValueListenableBuilder<Object?>(
                    valueListenable: currentListenable(),
                    builder: (context, value, _) {
                      final isEnabled = _isEnabled(value);

                      return ElevatedButton(
                        onPressed: isEnabled ? nextPage : null,
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (states) {
                              if (states.contains(MaterialState.disabled)) {
                                return const Color(0xFFBDBDBD);
                              }
                              return const Color(0xFF00C853);
                            },
                          ),
                          foregroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (states) {
                              if (states.contains(MaterialState.disabled)) {
                                return const Color(0xFF9F9F9F);
                              }
                              return Colors.white;
                            },
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          elevation: MaterialStateProperty.all(6),
                          shadowColor: MaterialStateProperty.all(
                            const Color(0xFF038E4B),
                          ),
                        ),
                        child: Text(
                          _buttonText(),
                          style: const TextStyle(
                            fontFamily: "RubikScribble",
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
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
