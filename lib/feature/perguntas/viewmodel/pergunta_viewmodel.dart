import 'package:flutter/foundation.dart';
import '../model/pergunta_model.dart';

class PerguntaViewModel extends ChangeNotifier {
  final List<Pergunta> _perguntas = [];

  List<Pergunta> get perguntas => _perguntas;

  void adicionarPergunta(String texto) {
    if (texto.isEmpty) return;

    final pergunta = Pergunta(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      texto: texto,
      criadaEm: DateTime.now(),
    );

    _perguntas.add(pergunta);
    notifyListeners();
  }
}
