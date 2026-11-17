import 'package:flutter_test/flutter_test.dart';
import 'package:tempo_claro/models/dia_previsao.dart';

void main() {
  group('DiaPrevisao', () {
    test('converte a sigla cl para Céu claro', () {
      final dia = DiaPrevisao(data: DateTime(2026, 11, 17), codigoTempo: 'cl', maxima: 28, minima: 17);
      expect(dia.descricao, 'Céu claro');
      expect(dia.emoji, '☀️');
    });

    test('usa descrição genérica para sigla desconhecida', () {
      final dia = DiaPrevisao(data: DateTime(2026, 11, 17), codigoTempo: 'xx', maxima: null, minima: null);
      expect(dia.descricao, 'Condição não informada');
      expect(dia.maxima, isNull);
      expect(dia.minima, isNull);
    });

    test('mantém o índice UV opcional', () {
      final dia = DiaPrevisao(data: DateTime(2026, 11, 17), codigoTempo: 'ps', maxima: 30, minima: 19, iuv: 8.5);
      expect(dia.iuv, 8.5);
    });
  });
}
