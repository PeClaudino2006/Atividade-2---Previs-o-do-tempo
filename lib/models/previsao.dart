import 'cidade.dart';
import 'dia_previsao.dart';

class Previsao {
  const Previsao({required this.cidade, required this.atualizacao, required this.dias});
  final Cidade cidade;
  final DateTime? atualizacao;
  final List<DiaPrevisao> dias;
}
