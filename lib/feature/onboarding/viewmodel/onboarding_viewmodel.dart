import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/usuario_model.dart';

class OnboardingViewModel {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final uuid = const Uuid();

  // 👉 Controlados por ValueNotifier
  final nome = ValueNotifier<String>("");
  final escola = ValueNotifier<String>("");
  final anoEscolar = ValueNotifier<String>("");
  final materiasFoco = ValueNotifier<List<String>>([]); // ✅ agora é ValueNotifier

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

  final escolasDisponiveis = [
    "E.E. Antônio Telles",
    "E.E. Carvalho Leal",
    "E.E. Getúlio Vargas",
    "E.E. Farias Brito",
    "E.E. Adalberto Valle",
    "E.E. Bom Pastor",
  ];

  final anosDisponiveis = [
    "5ª Série",
    "6ª Série",
    "7ª Série",
    "8ª Série",
    "9ª Série",
    "1º Ano",
    "2º Ano",
    "3º Ano",
  ];

  void toggleMateria(String materia) {
    final list = List<String>.from(materiasFoco.value);
    if (list.contains(materia)) {
      list.remove(materia);
    } else {
      list.add(materia);
    }
    materiasFoco.value = list; // ✅ notifica os listeners
  }

  Future<Usuario> salvarUsuario() async {
    final userId = uuid.v4();

    final usuario = Usuario(
      id: userId,
      nome: nome.value,
      anoEscolar: anoEscolar.value,
      materiasFoco: materiasFoco.value, // ✅ pega lista atual
      escola: escola.value,
    );

    await db.collection("usuarios").doc(userId).set(usuario.toMap());
    return usuario;
  }
}
