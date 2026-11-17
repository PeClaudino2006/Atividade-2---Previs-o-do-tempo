class Cidade {
  const Cidade({required this.id, required this.nome, required this.uf});
  final String id;
  final String nome;
  final String uf;

  String get identificacao => '$nome - $uf';
}
