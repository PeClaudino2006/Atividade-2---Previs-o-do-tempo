
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../models/cidade.dart';
import '../models/dia_previsao.dart';
import '../models/previsao.dart';

class CptecException implements Exception {
  CptecException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CptecService {
  CptecService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  // Na Web, utiliza o intermediário Node.js.
  // Nas outras plataformas, consulta diretamente o CPTEC.
  static String get _base => kIsWeb
      ? 'http://127.0.0.1:3001/cptec'
      : 'http://servicos.cptec.inpe.br/XML';

  Future<List<Cidade>> buscarCidades(String nome) async {
    final termo = nome.trim();

    if (termo.isEmpty) return [];

    final uri = Uri.parse('$_base/listaCidades').replace(
      queryParameters: {'city': _semAcentos(termo)},
    );

    final response = await _get(uri);

    try {
      final document = XmlDocument.parse(
        latin1.decode(response.bodyBytes),
      );

      return document.findAllElements('cidade').map((node) {
        String value(String tag) =>
            node.getElement(tag)?.innerText.trim() ?? '';

        return Cidade(
          id: value('id'),
          nome: value('nome'),
          uf: value('uf'),
        );
      }).where((cidade) {
        return cidade.id.isNotEmpty &&
            cidade.nome.isNotEmpty &&
            cidade.uf.isNotEmpty;
      }).toList();
    } on XmlException {
      throw CptecException(
        'O serviço retornou uma resposta de cidades inválida.',
      );
    }
  }

  Future<Previsao> buscarPrevisao(Cidade cidade) async {
    final uri = Uri.parse(
      '$_base/cidade/${cidade.id}/previsao.xml',
    );

    final response = await _get(uri);

    try {
      final document = XmlDocument.parse(
        latin1.decode(response.bodyBytes),
      );

      final root = document.rootElement;

      String value(String tag) =>
          root.getElement(tag)?.innerText.trim() ?? '';

      final nome = value('nome').isEmpty
          ? cidade.nome
          : value('nome');

      final uf = value('uf').isEmpty
          ? cidade.uf
          : value('uf');

      final atualizacaoTexto = value('atualizacao');
      final atualizacao = DateTime.tryParse(atualizacaoTexto);

      final dias = root.findElements('previsao').map((node) {
        String field(String tag) =>
            node.getElement(tag)?.innerText.trim() ?? '';

        final data = DateTime.tryParse(field('dia'));

        if (data == null) return null;

        return DiaPrevisao(
          data: data,
          codigoTempo: field('tempo'),
          maxima: int.tryParse(field('maxima')),
          minima: int.tryParse(field('minima')),
          iuv: double.tryParse(
            field('iuv').replaceAll(',', '.'),
          ),
        );
      }).whereType<DiaPrevisao>().toList();

      if (dias.isEmpty) {
        throw CptecException(
          'Não há previsão disponível para esta cidade no momento.',
        );
      }

      return Previsao(
        cidade: Cidade(
          id: cidade.id,
          nome: nome,
          uf: uf,
        ),
        atualizacao: atualizacao,
        dias: dias,
      );
    } on XmlException {
      throw CptecException(
        'O serviço retornou uma previsão inválida. Tente novamente.',
      );
    }
  }

  String _semAcentos(String texto) {
    var resultado = texto.toLowerCase();

    const substituicoes = {
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
    };

    substituicoes.forEach((acentuado, simples) {
      resultado = resultado.replaceAll(acentuado, simples);
    });

    return resultado;
  }

  Future<http.Response> _get(Uri uri) async {
    try {
      final response = await _client
          .get(
            uri,
            headers: {'Accept': 'application/xml'},
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw CptecException(
          'O serviço CPTEC/INPE está indisponível '
          '(HTTP ${response.statusCode}).',
        );
      }

      if (response.bodyBytes.isEmpty) {
        throw CptecException(
          'O serviço retornou uma resposta vazia.',
        );
      }

      return response;
    } on CptecException {
      rethrow;
    } catch (_) {
      throw CptecException(
        'Não foi possível conectar ao CPTEC/INPE. '
        'Verifique sua internet e tente novamente.',
      );
    }
  }

  void dispose() => _client.close();
}
