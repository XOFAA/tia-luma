import 'package:flutter/material.dart';
import 'package:tia_luma/feature/gamification/viewmodel/gamification_viewmodel.dart';
import 'package:tia_luma/feature/gamification/widget/fase_box.dart';

class GamificationPage extends StatefulWidget {
  const GamificationPage({super.key});

  @override
  State<GamificationPage> createState() => _GamificationPageState();
}

class _GamificationPageState extends State<GamificationPage> {
  final viewModel = GamificationViewModel();

  Alignment _getAlignment(int index) {
    // padrão: centro → esquerda → centro → direita
    if (index % 2 == 0) {
      return Alignment.center;
    } else if (index % 4 == 1) {
      return const Alignment(0.5, 0); // levemente à esquerda
    } else if (index % 4 == 2) {
      return Alignment.center;
    } else {
      return const Alignment(0.6, 0); // levemente à direita
    }
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header usuário + moedas
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundImage: AssetImage("assets/images/avatar.png"),
                      radius: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Olá, Luiz!",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const Spacer(),
                    Row(
                      children: const [
                        Icon(Icons.star, color: Colors.yellow),
                        SizedBox(width: 4),
                        Text("18",
                            style: TextStyle(color: Colors.white, fontSize: 16)),
                        SizedBox(width: 12),
                        Icon(Icons.battery_full, color: Colors.purpleAccent),
                        SizedBox(width: 4),
                        Text("18",
                            style: TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
        
                const SizedBox(height: 20),
        
                // Select de matéria
                ValueListenableBuilder<String>(
                  valueListenable: viewModel.materiaSelecionada,
                  builder: (context, materia, _) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xffD288E1)),
                      ),
                      child: DropdownButton<String>(
                        value: materia,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.black87),
                        dropdownColor: Colors.white,
                        items: viewModel.materias.map((m) {
                          return DropdownMenuItem(
                            value: m,
                            child: Row(
                              children: [
                                Image.asset("assets/images/quimica.png",
                                    height: 24),
                                const SizedBox(width: 8),
                                Text(m,
                                    style:
                                        const TextStyle(color: Colors.black87)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            viewModel.materiaSelecionada.value = value;
                          }
                        },
                      ),
                    );
                  },
                ),
        
                const SizedBox(height: 16),
        
                // Card Azul (Unidade atual)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xff0094FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Image.asset("assets/images/quimica.png", height: 30),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("QUÍMICA 1, SEÇÃO 1, UNIDADE 2",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                            Text("Introdução",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ],
                        ),
                      ),
                      const Icon(Icons.menu_book, color: Colors.white),
                    ],
                  ),
                ),
        
                const SizedBox(height: 24),
        
                // Lista de fases em zig-zag
                Expanded(
                  child: ValueListenableBuilder<String>(
                    valueListenable: viewModel.materiaSelecionada,
                    builder: (context, materia, _) {
                      final fases = viewModel.fases[materia]!;
        
                      return ListView.builder(
                        itemCount: fases.length,
                        itemBuilder: (context, index) {
                          final fase = fases[index];
        
                          final alignment = _getAlignment(index);
        
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Align(
                              alignment: alignment,
                              child: FaseBox(
                                desbloqueada: fase.desbloqueada,
                                atual: fase.atual,
                                onTap: () {
                                  viewModel.concluirFase(materia, fase.id);
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // FloatingActionButton Tia Luma
    floatingActionButton: SizedBox(
  width: MediaQuery.of(context).size.width * 0.20,  // 20% da largura da tela
  height: MediaQuery.of(context).size.width * 0.20, // mantém quadrado
  child: FloatingActionButton(
    onPressed: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Abrir chat da Tia Luma")),
      );
    },
    backgroundColor: Colors.transparent,
    elevation: 0,
    child: Image.asset(
      "assets/images/floatbutton.png",
     fit: BoxFit.cover,
    ),
  ),
),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
