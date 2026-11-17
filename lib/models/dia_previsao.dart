class DiaPrevisao {
  const DiaPrevisao({required this.data, required this.codigoTempo, required this.maxima, required this.minima, this.iuv});
  final DateTime data;
  final String codigoTempo;
  final int? maxima;
  final int? minima;
  final double? iuv;

  String get descricao => descricoes[codigoTempo.toLowerCase()] ?? 'Condição não informada';
  String get emoji => icones[codigoTempo.toLowerCase()] ?? '🌡️';

  static const Map<String, String> descricoes = {
    'ec': 'Encoberto com chuvas isoladas', 'ci': 'Chuvas isoladas', 'c': 'Chuva',
    'in': 'Instável', 'pp': 'Possibilidade de pancadas de chuva', 'cm': 'Chuva pela manhã',
    'cn': 'Chuva à noite', 'pt': 'Pancadas de chuva à tarde', 'pm': 'Pancadas de chuva pela manhã',
    'np': 'Nublado e pancadas de chuva', 'pc': 'Pancadas de chuva', 'pn': 'Parcialmente nublado',
    'cv': 'Chuvisco', 'ch': 'Chuvoso', 't': 'Tempestade', 'ps': 'Predomínio de sol',
    'e': 'Encoberto', 'n': 'Nublado', 'cl': 'Céu claro', 'nv': 'Nevoeiro', 'g': 'Geada',
    'ne': 'Neve', 'nd': 'Não definido', 'pnt': 'Pancadas de chuva à noite',
    'psc': 'Possibilidade de chuva', 'pcm': 'Possibilidade de chuva pela manhã',
    'pct': 'Possibilidade de chuva à tarde', 'pcn': 'Possibilidade de chuva à noite',
    'npt': 'Nublado com pancadas à tarde', 'npn': 'Nublado com pancadas à noite',
    'ncn': 'Nublado com possibilidade de chuva à noite', 'nct': 'Nublado com possibilidade de chuva à tarde',
    'ncm': 'Nublado com possibilidade de chuva pela manhã', 'npm': 'Nublado com pancadas pela manhã',
    'npp': 'Nublado com possibilidade de chuva', 'vn': 'Variação de nebulosidade',
    'ct': 'Chuva à tarde', 'ppn': 'Possibilidade de pancadas de chuva à noite',
    'ppt': 'Possibilidade de pancadas de chuva à tarde', 'ppm': 'Possibilidade de pancadas de chuva pela manhã',
  };

  static const Map<String, String> icones = {
    'ec': '🌧️', 'ci': '🌤️', 'c': '🌧️', 'in': '⛈️', 'pp': '🌦️', 'cm': '🌧️', 'cn': '🌧️',
    'pt': '🌦️', 'pm': '🌦️', 'np': '🌧️', 'pc': '🌦️', 'pn': '⛅', 'cl': '☀️', 'nv': '🌫️',
    'g': '❄️', 'ne': '❄️', 'nd': '🌡️', 'pnt': '🌧️', 'psc': '🌦️', 'n': '☁️', 'vn': '⛅',
    'ct': '🌦️', 'ch': '🌧️', 't': '⛈️', 'ps': '☀️', 'e': '☁️', 'cv': '🌦️', 'npt': '🌧️', 'npn': '🌧️', 'ncn': '🌦️', 'nct': '🌦️', 'ncm': '🌦️', 'npm': '🌧️', 'npp': '🌦️', 'ppn': '🌦️', 'ppt': '🌦️', 'ppm': '🌦️', 'pct': '🌦️', 'pcn': '🌦️', 'pcm': '🌦️',
  };
}
