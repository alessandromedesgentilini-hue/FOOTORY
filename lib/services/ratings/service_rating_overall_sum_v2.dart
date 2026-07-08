// lib/services/ratings/service_rating_overall_sum_v2.dart
//
// Serviço de OVR baseado em “soma/ média ponderada de 10 micros” por função.
// API usada nas telas:
//   - microsFromPillars(of, def, tec, men, fis) -> Map<String,int> (10..100)
//   - funcaoFromPos(pos) -> Funcao (GOL/DEF/MEI/ATA)
//   - sumForRole(funcao, micros) -> int (10..100)
//
// Observação: este arquivo substitui o reexport sugerido antes.
// Se você tiver criado `ovr_sum_v2.dart` + um reexport com este nome,
// pode manter só este arquivo e remover o reexport para evitar duplicidade.

enum Funcao { GOL, DEF, MEI, ATA }

// Aceita "GOL/DEF/MEI/ATA" e também "GK/DF/MF/FW" (compat).
Funcao funcaoFromPos(String pos) {
  final p = pos.toUpperCase().trim();
  switch (p) {
    case 'GOL':
    case 'GK':
      return Funcao.GOL;
    case 'DEF':
    case 'DF':
      return Funcao.DEF;
    case 'MEI':
    case 'MF':
      return Funcao.MEI;
    case 'ATA':
    case 'FW':
    default:
      return Funcao.ATA;
  }
}

// Converte pilares (40..95) em 10 micros (10..100) – simples e determinístico.
// Se algum pilar faltar, usa 60 como default.
Map<String, int> microsFromPillars(
  Map<String, int> of,
  Map<String, int> de,
  Map<String, int> tec,
  Map<String, int> men,
  Map<String, int> fis,
) {
  int _get(Map<String, int> m, String k1, String k2, int d) {
    if (m.containsKey(k1)) return m[k1]!;
    if (m.containsKey(k2)) return m[k2]!;
    return d;
    // k1/k2: ex.: ('fin','finalizacao'), ('marc','marcacao'), ('tec','tecnica') etc.
  }

  final fin = _get(of, 'fin', 'finalizacao', 60);
  final marc = _get(de, 'marc', 'marcacao', 60);
  final tecB = _get(tec, 'tec', 'tecnica', 60);
  final mnt = _get(men, 'mnt', 'mental', 60);
  final fisB = _get(fis, 'fis', 'fisico', 60);

  // Mapeia linearmente 40..95 -> 10..100
  int map40to95_to10to100(int v) {
    final cl = v.clamp(40, 95);
    final n = (cl - 40) / (95 - 40);
    return (10 + n * 90).round().clamp(10, 100);
  }

  int a(int v) => map40to95_to10to100(v);

  // 10 micros (nomes curtos, compat com UI legada que por vezes exibe keys)
  return <String, int>{
    // Ofensivos/técnicos
    'fin': a(fin), // finalização
    'pas': a(tecB), // passe (derivado de técnica)
    'tec': a(tecB), // técnica
    'cri': a(mnt), // criatividade/visão (mental)
    // Físicos
    'vel': a(fisB), // velocidade
    'for': a(fisB), // força
    'res': a(fisB), // resistência
    // Defensivos
    'mar': a(marc), // marcação
    'des': a(marc), // desarme
    'pos': a(mnt), // posicionamento/concentração (mental)
  };
}

// Pesos por função somando ~10 para facilitar leitura.
// A nota final é média ponderada (∑w*x / ∑w), clamp 10..100.
int sumForRole(Funcao f, Map<String, int> m) {
  double g(String k) => (m[k] ?? 10).toDouble();

  late final List<MapEntry<String, double>> pesos;
  switch (f) {
    case Funcao.GOL:
      pesos = const [
        MapEntry('pos', 2.0),
        MapEntry('des', 1.6),
        MapEntry('mar', 1.6),
        MapEntry('res', 1.2),
        MapEntry('for', 1.0),
        MapEntry('vel', 0.8),
        MapEntry('cri', 0.6),
        MapEntry('tec', 0.6),
        MapEntry('pas', 0.4),
        MapEntry('fin', 0.2),
      ];
      break;
    case Funcao.DEF:
      pesos = const [
        MapEntry('mar', 2.0),
        MapEntry('des', 1.8),
        MapEntry('pos', 1.6),
        MapEntry('for', 1.2),
        MapEntry('res', 1.2),
        MapEntry('pas', 0.8),
        MapEntry('tec', 0.6),
        MapEntry('vel', 0.6),
        MapEntry('cri', 0.4),
        MapEntry('fin', 0.2),
      ];
      break;
    case Funcao.MEI:
      pesos = const [
        MapEntry('pas', 1.8),
        MapEntry('tec', 1.6),
        MapEntry('cri', 1.6),
        MapEntry('pos', 1.2),
        MapEntry('res', 1.0),
        MapEntry('vel', 1.0),
        MapEntry('mar', 0.8),
        MapEntry('des', 0.8),
        MapEntry('fin', 0.7),
        MapEntry('for', 0.5),
      ];
      break;
    case Funcao.ATA:
      pesos = const [
        MapEntry('fin', 2.2),
        MapEntry('tec', 1.6),
        MapEntry('vel', 1.4),
        MapEntry('cri', 1.2),
        MapEntry('pas', 1.0),
        MapEntry('pos', 0.9),
        MapEntry('for', 0.7),
        MapEntry('res', 0.6),
        MapEntry('mar', 0.2),
        MapEntry('des', 0.2),
      ];
      break;
  }

  final wsum = pesos.fold<double>(0, (s, e) => s + e.value);
  final vsum = pesos.fold<double>(0, (s, e) => s + e.value * g(e.key));
  final out = (vsum / (wsum == 0 ? 1 : wsum)).round();
  return out.clamp(10, 100);
}
