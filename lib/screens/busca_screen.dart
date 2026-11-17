import 'package:flutter/material.dart';
import '../models/cidade.dart';
import '../services/cptec_service.dart';

class BuscaScreen extends StatefulWidget {
  const BuscaScreen({super.key, required this.service, required this.onSelecionar});
  final CptecService service;
  final ValueChanged<Cidade> onSelecionar;
  @override
  State<BuscaScreen> createState() => _BuscaScreenState();
}

class _BuscaScreenState extends State<BuscaScreen> {
  final _controller = TextEditingController();
  List<Cidade> _cidades = [];
  bool _carregando = false;
  String? _erro;

  Future<void> _buscar() async {
    if (_controller.text.trim().isEmpty) {
      setState(() { _erro = 'Digite o nome de uma cidade.'; _cidades = []; });
      return;
    }
    setState(() { _carregando = true; _erro = null; _cidades = []; });
    try {
      final resultado = await widget.service.buscarCidades(_controller.text);
      if (!mounted) return;
      setState(() { _cidades = resultado; if (resultado.isEmpty) _erro = 'Nenhuma cidade encontrada. Confira o nome e tente novamente.'; });
    } on CptecException catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } finally { if (mounted) setState(() => _carregando = false); }
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tempo Claro'), centerTitle: false),
      body: SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [
        Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1769AA), Color(0xFF42A5F5)]), borderRadius: BorderRadius.circular(24)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('PREVISÃO DO TEMPO', style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)), SizedBox(height: 10), Text('Como está o tempo\nna sua cidade?', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)), SizedBox(height: 8), Text('Consulte a previsão dos próximos quatro dias.', style: TextStyle(color: Colors.white70))])),
        const SizedBox(height: 24), const Text('Buscar localidade', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
        TextField(controller: _controller, textInputAction: TextInputAction.search, onSubmitted: (_) => _buscar(), decoration: InputDecoration(hintText: 'Ex.: Jacareí, São Paulo...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), suffixIcon: IconButton(onPressed: _carregando ? null : _buscar, icon: const Icon(Icons.arrow_forward))),),
        const SizedBox(height: 18),
        if (_carregando) const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
        if (_erro != null) Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Theme.of(context).colorScheme.errorContainer, borderRadius: BorderRadius.circular(14)), child: Text(_erro!)),
        if (_cidades.isNotEmpty) ...[
          Text('Resultados encontrados (${_cidades.length})', style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 8),
          ..._cidades.map((cidade) => Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.location_city)), title: Text(cidade.nome), subtitle: Text('Estado: ${cidade.uf}  •  Código: ${cidade.id}'), trailing: const Icon(Icons.chevron_right), onTap: () => widget.onSelecionar(cidade)))),
        ],
        const SizedBox(height: 26), const Text('Fonte dos dados: CPTEC/INPE', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
      ])),
    );
  }
}
