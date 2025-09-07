import 'package:flutter/material.dart';
import 'package:tia_luma/feature/perguntas/view/pergunta_page.dart';
import '../../../core/models/usuario_model.dart';

class HomePage extends StatelessWidget {
  final Usuario usuario;

  const HomePage({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Olá, ${usuario.nome}! 👋"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text("${usuario.anoEscolar} Vamos estudar hoje ?"),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          PerguntaPage(
            userId: usuario.id!, // 🔑 passa só o id do usuário
          ),
        ],
      ),
    );
  }
}
