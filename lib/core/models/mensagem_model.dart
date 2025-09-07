import 'package:cloud_firestore/cloud_firestore.dart';

class Mensagem {
  final String id;
  final String remetente;
  final String texto;
  final DateTime enviadaEm;

  // 🔹 novos campos opcionais
  final String? tipo; // "texto" ou "audio"
  final String? audioBase64; // só quando for áudio

  Mensagem({
    required this.id,
    required this.remetente,
    required this.texto,
    required this.enviadaEm,
    this.tipo = "texto",
    this.audioBase64,
  });

  Map<String, dynamic> toMap() {
    return {
      'remetente': remetente,
      'texto': texto,
      'enviadaEm': Timestamp.fromDate(enviadaEm),
      'tipo': tipo,
      'audioBase64': audioBase64,
    };
  }

  factory Mensagem.fromMap(String id, Map<String, dynamic> map) {
    return Mensagem(
      id: id,
      remetente: map['remetente'],
      texto: map['texto'] ?? "",
      enviadaEm: (map['enviadaEm'] as Timestamp).toDate(),
      tipo: map['tipo'] ?? "texto",
      audioBase64: map['audioBase64'],
    );
  }
}
