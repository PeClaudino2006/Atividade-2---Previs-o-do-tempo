import 'package:flutter/material.dart';
import '../models/cidade.dart';
import '../models/dia_previsao.dart';
import '../models/previsao.dart';
import '../services/cptec_service.dart';
import '../widgets/grafico_temperatura.dart';

class PrevisaoScreen extends StatefulWidget {
  const PrevisaoScreen({super.key, required this.cidade, required this.service, required this.onVoltar});
  final Cidade cidade;
  final CptecService service;
  final VoidCallback onVoltar;
  @override
  State<PrevisaoScreen> createState() => _PrevisaoScreenState();
}

class _PrevisaoScreenState extends State<PrevisaoScreen> {
  Previsao? _previsao;
  bool _carregando = true;
  String? _erro;

  @override
  void initState() { super.initState(); _carregar(); }

  Future<void> _carregar() async {
    setState(() { _carregando = true; _erro = null; });
    try { final p = await widget.service.buscarPrevisao(widget.cidade); if (mounted) setState(() => _previsao = p); }
    on CptecException catch (e) { if (mounted) setState(() => _erro = e.message); }
    finally { if (mounted) setState(() => _carregando = false); }
  }

  String _data(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  String _diaSemana(DateTime d) { const nomes = ['segunda-feira','terça-feira','quarta-feira','quinta-feira','sexta-feira','sábado','domingo']; return nomes[d.weekday - 1]; }

  @override
  Widget build(BuildContext context) {
    final p = _previsao;
    return Scaffold(appBar: AppBar(title: Text(widget.cidade.identificacao, style: const TextStyle(fontSize: 17)), leading: IconButton(onPressed: widget.onVoltar, icon: const Icon(Icons.arrow_back)), actions: [IconButton(onPressed: _carregando ? null : _carregar, tooltip: 'Atualizar previsão', icon: const Icon(Icons.refresh))]),
      body: _carregando ? const Center(child: CircularProgressIndicator()) : _erro != null ? _estadoErro() : p == null ? _estadoErro() : RefreshIndicator(onRefresh: _carregar, child: ListView(padding: const EdgeInsets.all(18), children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1769AA), Color(0xFF42A5F5)]), borderRadius: BorderRadius.circular(22)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('PREVISÃO PARA', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.3)), const SizedBox(height: 5), Text(p.cidade.nome, style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)), Text(p.cidade.uf, style: const TextStyle(color: Colors.white70)), const SizedBox(height: 12), Text('Atualização informada pelo CPTEC: ${p.atualizacao == null ? 'não informada' : _data(p.atualizacao!)}', style: const TextStyle(color: Colors.white70, fontSize: 12))])),
        const SizedBox(height: 22), const Text('Próximos dias', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
        ...p.dias.map(_cartaoDia),
        const SizedBox(height: 18), const Text('Variação de temperatura', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)), const SizedBox(height: 5), const Text('Máxima e mínima previstas em °C', style: TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 14),
        Card(child: Padding(padding: const EdgeInsets.fromLTRB(8, 18, 18, 12), child: Column(children: [const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.circle, color: Color(0xFFFF9F43), size: 9), SizedBox(width: 5), Text('Máxima', style: TextStyle(fontSize: 12)), SizedBox(width: 18), Icon(Icons.circle, color: Color(0xFF3998E8), size: 9), SizedBox(width: 5), Text('Mínima', style: TextStyle(fontSize: 12))]), const SizedBox(height: 14), GraficoTemperatura(dias: p.dias)]))),
        const SizedBox(height: 16), const Text('Dados meteorológicos fornecidos pelo CPTEC/INPE.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
      ])));
  }

  Widget _cartaoDia(DiaPrevisao dia) => Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(15), child: Row(children: [Text(dia.emoji, style: const TextStyle(fontSize: 34)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_diaSemana(dia.data), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), Text(_data(dia.data), style: const TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 4), Text(dia.descricao)])), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(dia.maxima == null ? '--°' : '${dia.maxima}°', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFFF9F43))), Text(dia.minima == null ? '--°' : '${dia.minima}°', style: const TextStyle(fontSize: 16, color: Color(0xFF3998E8))), if (dia.iuv != null) Text('IUV ${dia.iuv!.toStringAsFixed(1)}', style: const TextStyle(fontSize: 11, color: Colors.grey))])])));

  Widget _estadoErro() => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.cloud_off, size: 54, color: Colors.grey), const SizedBox(height: 14), Text(_erro ?? 'Não foi possível carregar a previsão.', textAlign: TextAlign.center), const SizedBox(height: 16), FilledButton.icon(onPressed: _carregar, icon: const Icon(Icons.refresh), label: const Text('Tentar novamente'))])));
}
