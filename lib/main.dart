import 'package:flutter/material.dart';
import 'models/cidade.dart';
import 'screens/busca_screen.dart';
import 'screens/previsao_screen.dart';
import 'services/cptec_service.dart';
import 'services/preferencias_service.dart';

void main() => runApp(const TempoClaroApp());

class TempoClaroApp extends StatefulWidget {
  const TempoClaroApp({super.key});
  @override
  State<TempoClaroApp> createState() => _TempoClaroAppState();
}

class _TempoClaroAppState extends State<TempoClaroApp> {
  final _service = CptecService();
  final _preferencias = PreferenciasService();
  Cidade? _cidadeSelecionada;
  bool _iniciando = true;

  @override
  void initState() { super.initState(); _recuperarUltimaCidade(); }
  Future<void> _recuperarUltimaCidade() async {
    final cidade = await _preferencias.recuperarCidade();
    if (mounted) setState(() { _cidadeSelecionada = cidade; _iniciando = false; });
  }
  Future<void> _selecionar(Cidade cidade) async {
    await _preferencias.salvarCidade(cidade);
    if (mounted) setState(() => _cidadeSelecionada = cidade);
  }
  @override
  void dispose() { _service.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Tempo Claro', debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2), brightness: Brightness.light), useMaterial3: true, scaffoldBackgroundColor: const Color(0xFFF4F7FB), appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF4F7FB), foregroundColor: Color(0xFF17324D)), cardTheme: CardThemeData(color: Colors.white, elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)))),
    home: _iniciando ? const Scaffold(body: Center(child: CircularProgressIndicator())) : _cidadeSelecionada == null
      ? BuscaScreen(service: _service, onSelecionar: _selecionar)
      : PrevisaoScreen(key: ValueKey(_cidadeSelecionada!.id), cidade: _cidadeSelecionada!, service: _service, onVoltar: () => setState(() => _cidadeSelecionada = null)),
  );
}
