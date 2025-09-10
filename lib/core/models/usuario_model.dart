class Usuario {
  final String id;
  final String nome;
  final String anoEscolar;
  final List<String> materiasFoco;
  final String escola; // 👈 novo campo
  final String nivel;
  final int metaDiaria;
  final Map<String, int> estatisticas;

  Usuario({
    required this.id,
    required this.nome,
    required this.anoEscolar,
    required this.materiasFoco,
    required this.escola, // 👈 passa como required
    this.nivel = "iniciante",
    this.metaDiaria = 3,
    Map<String, int>? estatisticas,
  }) : estatisticas = estatisticas ??
            {
              "licoesConcluidas": 0,
              "horasEstudadas": 0,
              "sequenciaDias": 0,
            };

  /// Converte pra Map (salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "nome": nome,
      "anoEscolar": anoEscolar,
      "materiasFoco": materiasFoco,
      "escola": escola, // 👈 salva no Firestore
      "nivel": nivel,
      "metaDiaria": metaDiaria,
      "estatisticas": estatisticas,
    };
  }

  /// Cria a partir do Firestore
  factory Usuario.fromMap(String id, Map<String, dynamic> map) {
    return Usuario(
      id: id,
      nome: map["nome"] ?? "",
      anoEscolar: map["anoEscolar"] ?? "",
      materiasFoco: List<String>.from(map["materiasFoco"] ?? []),
      escola: map["escola"] ?? "", // 👈 carrega do Firestore
      nivel: map["nivel"] ?? "iniciante",
      metaDiaria: map["metaDiaria"] ?? 3,
      estatisticas: Map<String, int>.from(map["estatisticas"] ?? {}),
    );
  }
}
