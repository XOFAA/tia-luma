class Fase {
  final String id;
  final String titulo;
  bool desbloqueada;
  bool atual;

  Fase({
    required this.id,
    required this.titulo,
    this.desbloqueada = false,
    this.atual = false,
  });
}
