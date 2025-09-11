import 'package:flutter/material.dart';
import 'package:tia_luma/feature/gamification/model/fase_model.dart';

class GamificationViewModel {
  final materias = ["Matemática", "História"];
  final materiaSelecionada = ValueNotifier<String>("Matemática");

  /// Cada matéria começa com a 1ª fase desbloqueada e atual
  final Map<String, List<Fase>> fases = {
    "Matemática": [
      Fase(id: "1", titulo: "Fase 1", desbloqueada: true, atual: true),
      Fase(id: "2", titulo: "Fase 2", desbloqueada: false, atual: false),
      Fase(id: "3", titulo: "Fase 3", desbloqueada: false, atual: false),
    ],
    "História": [
      Fase(id: "1", titulo: "Fase 1", desbloqueada: true, atual: true),
      Fase(id: "2", titulo: "Fase 2", desbloqueada: false, atual: false),
      Fase(id: "3", titulo: "Fase 3", desbloqueada: false, atual: false),
    ],
  };

  /// Marca fase como concluída e desbloqueia a próxima
  void concluirFase(String materia, String faseId) {
    final lista = fases[materia]!;
    final index = lista.indexWhere((f) => f.id == faseId);

    if (index != -1) {
      // remove o "atual" da fase concluída
      lista[index].atual = false;

      // desbloqueia próxima fase, se existir
      if (index + 1 < lista.length) {
        lista[index + 1].desbloqueada = true;
        lista[index + 1].atual = true;
      }
    }

    // força rebuild
    materiaSelecionada.notifyListeners();
  }
}
