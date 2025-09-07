class Pergunta {
  final String id;
  final String texto;
  final DateTime criadaEm;

  Pergunta({required this.id, required this.texto, required this.criadaEm});

  Map<String, dynamic> toMap() {
    return {'id': id, 'texto': texto, 'criadaEm': criadaEm.toIso8601String()};
  }

  factory Pergunta.fromMap(Map<String, dynamic> map) {
    return Pergunta(
      id: map['id'] ?? '',
      texto: map['texto'] ?? '',
      criadaEm: DateTime.parse(map['criadaEm']),
    );
  }
}
