import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/dia_previsao.dart';

class GraficoTemperatura extends StatelessWidget {
  const GraficoTemperatura({super.key, required this.dias});
  final List<DiaPrevisao> dias;

  @override
  Widget build(BuildContext context) {
    final validos = dias.where((d) => d.minima != null && d.maxima != null).toList();
    if (validos.isEmpty) return const Text('Temperaturas indisponíveis para o gráfico.');
    final min = validos.map((d) => d.minima!).reduce((a, b) => a < b ? a : b).toDouble() - 3;
    final max = validos.map((d) => d.maxima!).reduce((a, b) => a > b ? a : b).toDouble() + 3;
    return SizedBox(
      height: 210,
      child: LineChart(LineChartData(
        minY: min, maxY: max, gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 34, getTitlesWidget: (v, _) => Text('${v.toInt()}°', style: const TextStyle(fontSize: 10)))),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1, getTitlesWidget: (v, _) {
            final i = v.toInt();
            if (i < 0 || i >= validos.length) return const SizedBox.shrink();
            return Padding(padding: const EdgeInsets.only(top: 8), child: Text('${validos[i].data.day}/${validos[i].data.month}', style: const TextStyle(fontSize: 10)));
          })),
        ),
        lineBarsData: [
          LineChartBarData(isCurved: true, color: const Color(0xFFFF9F43), barWidth: 3, dotData: const FlDotData(show: true), spots: [for (var i = 0; i < validos.length; i++) FlSpot(i.toDouble(), validos[i].maxima!.toDouble())]),
          LineChartBarData(isCurved: true, color: const Color(0xFF3998E8), barWidth: 3, dotData: const FlDotData(show: true), spots: [for (var i = 0; i < validos.length; i++) FlSpot(i.toDouble(), validos[i].minima!.toDouble())]),
        ],
      )),
    );
  }
}
