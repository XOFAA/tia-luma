import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class OnboardingViewModel {
  String nome = "";
  String anoEscolar = "";
  List<String> materiasFoco = [];

  final materiasDisponiveis = [
    "Matemática", "Português", "História", "Geografia",
    "Ciências", "Inglês", "Física", "Química", "Biologia"
  ];

  final FirebaseFirestore db = FirebaseFirestore.instance;
  final uuid = const Uuid();

  void toggleMateria(String materia) {
    if (materiasFoco.contains(materia)) {
      materiasFoco.remove(materia);
    } else {
      materiasFoco.add(materia);
    }
  }

  Future<void> salvarUsuario() async {
    final userId = uuid.v4();
    await db.collection("usuarios").doc(userId).set({
      "nome": nome,
      "anoEscolar": anoEscolar,
      "materiasFoco": materiasFoco,
      "nivel": "iniciante",
      "metaDiaria": 3,
      "estatisticas": {
        "licoesConcluidas": 0,
        "horasEstudadas": 0,
        "sequenciaDias": 0,
      }
    });
  }
}
