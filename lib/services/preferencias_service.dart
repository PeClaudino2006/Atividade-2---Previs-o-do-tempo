import 'package:shared_preferences/shared_preferences.dart';
import '../models/cidade.dart';

class PreferenciasService {
  static const _id = 'ultima_cidade_id';
  static const _nome = 'ultima_cidade_nome';
  static const _uf = 'ultima_cidade_uf';

  Future<void> salvarCidade(Cidade cidade) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_id, cidade.id);
    await prefs.setString(_nome, cidade.nome);
    await prefs.setString(_uf, cidade.uf);
  }

  Future<Cidade?> recuperarCidade() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_id);
    final nome = prefs.getString(_nome);
    final uf = prefs.getString(_uf);
    if (id == null || nome == null || uf == null) return null;
    return Cidade(id: id, nome: nome, uf: uf);
  }
}
