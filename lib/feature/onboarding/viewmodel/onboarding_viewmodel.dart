import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/usuario_model.dart'; // 👈 novo import

class OnboardingViewModel {
  String nome = "";
  String anoEscolar = "";
  List<String> materiasFoco = [];

  final FirebaseFirestore db = FirebaseFirestore.instance;
  final uuid = const Uuid();

  final materiasDisponiveis = [
    "Matemática",
    "Português",
    "História",
    "Geografia",
    "Ciências",
    "Inglês",
    "Física",
    "Química",
    "Biologia",
  ];

  void toggleMateria(String materia) {
    if (materiasFoco.contains(materia)) {
      materiasFoco.remove(materia);
    } else {
      materiasFoco.add(materia);
    }
  }

  Future<Usuario> salvarUsuario() async {
    final userId = uuid.v4();

    final usuario = Usuario(
      id: userId,
      nome: nome,
      anoEscolar: anoEscolar,
      materiasFoco: materiasFoco,
    );

    await db.collection("usuarios").doc(userId).set(usuario.toMap());

    return usuario; // 👈 retorna o objeto
  }
}
