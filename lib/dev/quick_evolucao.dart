// lib/dev/quick_evolucao.dart
//
// Demo DEV para validar a evolução física anual.
// Pode rodar de duas formas:
//
//  1) Standalone (fora do app):
//     dart run lib/dev/quick_evolucao.dart
//
//  2) Dentro do app (por um botão/atajo DEV):
//     chame `runQuickEvolucaoDemo()`
//
// Observação: este arquivo apenas LOGA no console (dev.log),
// não possui UI e é tolerante a diferenças de API entre branches.
//
// ignore_for_file: avoid_print, unused_local_variable

import 'dart:math';
import 'dart:developer' as dev;

// Ajuste se o caminho do seu EvolucaoService for diferente.
import 'package:futsim/services/evolucao/evolucao_service.dart';

/// ✅ Chaves físicas usadas pela demo (string keys).
/// Se seu EvolucaoService usa outras chaves, só troque aqui.
class AtribF {
  static const String potencia = 'potencia';
  static const String velocidade = 'velocidade';
  static const String resistencia = 'resistencia';
  static const String aptidao = 'aptidao';
  static const String coordenacao = 'coordenacao';
}

/// Executa a demo de evolução (útil quando chamada a partir do app).
void runQuickEvolucaoDemo({
  int idadeNoDia1Jan = 28,
  int minutosAnoAnterior = 1850,
  bool recebeuFoco = true,
  int seed = 123,
  Map<String, int>? atributosIniciais,
  List<String>? preferenciasGanho,
  List<String>? ordemQueda,
  bool clampAntesDepois = true,
}) {
  _runDemo(
    idadeNoDia1Jan: idadeNoDia1Jan,
    minutosAnoAnterior: minutosAnoAnterior,
    recebeuFoco: recebeuFoco,
    seed: seed,
    atributosIniciais: atributosIniciais,
    preferenciasGanho: preferenciasGanho,
    ordemQueda: ordemQueda,
    clampAntesDepois: clampAntesDepois,
  );
}

/// Entry-point para execução standalone (via `dart run`).
void main() {
  _runDemo();
}

void _runDemo({
  int idadeNoDia1Jan = 28,
  int minutosAnoAnterior = 1850,
  bool recebeuFoco = true,
  int seed = 123,
  Map<String, int>? atributosIniciais,
  List<String>? preferenciasGanho,
  List<String>? ordemQueda,
  bool clampAntesDepois = true,
}) {
  // Atributos FÍSICOS iniciais (escala 0..10).
  final base = <String, int>{
    AtribF.potencia: 6,
    AtribF.velocidade: 7,
    AtribF.resistencia: 6,
    AtribF.aptidao: 6,
    AtribF.coordenacao: 5,
  };
  final atributos = Map<String, int>.from(atributosIniciais ?? base);

  // Preferência de GANHO (ordem em que tentamos alocar bônus, se houver)
  final escolhasGanhos = preferenciasGanho ??
      <String>[
        AtribF.velocidade,
        AtribF.potencia,
        AtribF.resistencia,
        AtribF.aptidao,
        AtribF.coordenacao,
      ];

  // Preferência de QUEDA (ordem de sacrificar quando há declínio)
  final ordemDeQueda = ordemQueda ??
      <String>[
        AtribF.aptidao,
        AtribF.velocidade,
        AtribF.resistencia,
        AtribF.potencia,
        AtribF.coordenacao,
      ];

  // RNG determinístico p/ reproduzir resultado
  final rng = Random(seed);

  if (clampAntesDepois) {
    _clampAtribs(atributos, 0, 10);
  }

  // ----- LOG: entrada -----
  dev.log('=== EVOLUÇÃO (entrada) ===');
  dev.log('Idade base: $idadeNoDia1Jan');
  dev.log('Minutos última temporada: $minutosAnoAnterior');
  dev.log('Recebeu foco do staff? ${recebeuFoco ? "Sim" : "Não"}');
  dev.log('Atributos iniciais: ${_fmtAtribs(atributos)}');
  dev.log('Preferência de ganho: $escolhasGanhos');
  dev.log('Ordem de queda:       $ordemDeQueda');

  final res = _callTickCompat(
    atributos: Map<String, int>.from(atributos),
    idadeNoDia1Jan: idadeNoDia1Jan,
    minutosAnoAnterior: minutosAnoAnterior,
    recebeuFoco: recebeuFoco,
    escolhasGanhos: escolhasGanhos,
    ordemQueda: ordemDeQueda,
    rng: rng,
  );

  if (res == null) {
    dev.log(
      '❌ EvolucaoService.tick* indisponível (nenhuma assinatura encontrada). '
      'Ajuste os nomes em _callTickCompat() para o seu EvolucaoService.',
    );
    return;
  }

  // tentamos ler campos esperados; se não existir, a demo ainda loga algo
  final finais =
      Map<String, int>.from(_safeMapInt(_readDyn(res, 'atributosNovos')));
  if (clampAntesDepois) {
    _clampAtribs(finais, 0, 10);
  }

  final ganhos = _safeInt(_readDyn(res, 'pontosGanhos'));
  final queda = _safeInt(_readDyn(res, 'quedaFisica'));
  final logGanho = _safeMapInt(_readDyn(res, 'logGanho'));
  final logQueda = _safeMapInt(_readDyn(res, 'logQueda'));

  // ----- LOG: saída -----
  dev.log('=== EVOLUÇÃO (resultado) ===');
  dev.log('Pontos ganhos totais: $ganhos');
  dev.log('Queda física total:   $queda');
  dev.log('Ganho por atributo:   ${_fmtAtribs(logGanho)}');
  dev.log('Queda por atributo:   ${_fmtAtribs(logQueda)}');
  dev.log('Atributos finais:     ${_fmtAtribs(finais)}');

  // Diferença final por atributo (qual subiu/desceu e quanto)
  final delta = <String, int>{};
  for (final k in {...atributos.keys, ...finais.keys}) {
    final before = atributos[k] ?? 0;
    final after = finais[k] ?? before;
    delta[k] = after - before;
  }
  dev.log('Δ por atributo:       ${_fmtAtribs(delta, showSign: true)}');
}

/// Lê uma propriedade dinâmica com segurança.
dynamic _readDyn(dynamic obj, String name) {
  try {
    return (obj as dynamic).__getattr__(name);
  } catch (_) {
    // fallback: tenta acesso direto
    try {
      // ignore: avoid_dynamic_calls
      return (obj as dynamic).toJson != null ? null : null;
    } catch (_) {}
  }

  try {
    // ignore: avoid_dynamic_calls
    return (obj as dynamic)[name];
  } catch (_) {}

  try {
    // ignore: avoid_dynamic_calls
    return (obj as dynamic).runtimeType; // só p/ evitar lint
  } catch (_) {}

  // último fallback: reflection-like via dynamic getter
  try {
    // ignore: avoid_dynamic_calls
    return (obj as dynamic).noSuchMethod;
  } catch (_) {}

  // tentativa direta (getter)
  try {
    // ignore: avoid_dynamic_calls
    return (obj as dynamic).$name;
  } catch (_) {}

  // não achou
  try {
    // ignore: avoid_dynamic_calls
    return (obj as dynamic).toString();
  } catch (_) {}
  return null;
}

/// Tentativa compatível com múltiplos nomes/assinaturas de EvolucaoService.
/// Importante: tudo via dynamic pra não quebrar compile quando o método não existir.
dynamic _callTickCompat({
  required Map<String, int> atributos,
  required int idadeNoDia1Jan,
  required int minutosAnoAnterior,
  required bool recebeuFoco,
  required List<String> escolhasGanhos,
  required List<String> ordemQueda,
  required Random rng,
}) {
  final svc = EvolucaoService as dynamic;

  // 1) tickAnualJaneiro (com rng)
  try {
    final r = svc.tickAnualJaneiro(
      atributos: atributos,
      idadeNoDia1Jan: idadeNoDia1Jan,
      minutosAnoAnterior: minutosAnoAnterior,
      recebeuFoco: recebeuFoco,
      escolhasGanhos: escolhasGanhos,
      ordemQueda: ordemQueda,
      rng: rng,
    );
    if (r != null) return r;
  } catch (_) {}

  // 2) tickAnual (com rng)
  try {
    final r = svc.tickAnual(
      atributos: atributos,
      idadeNoDia1Jan: idadeNoDia1Jan,
      minutosAnoAnterior: minutosAnoAnterior,
      recebeuFoco: recebeuFoco,
      escolhasGanhos: escolhasGanhos,
      ordemQueda: ordemQueda,
      rng: rng,
    );
    if (r != null) return r;
  } catch (_) {}

  // 3) stepAnnual (com rng)
  try {
    final r = svc.stepAnnual(
      atributos: atributos,
      idadeNoDia1Jan: idadeNoDia1Jan,
      minutosAnoAnterior: minutosAnoAnterior,
      recebeuFoco: recebeuFoco,
      escolhasGanhos: escolhasGanhos,
      ordemQueda: ordemQueda,
      rng: rng,
    );
    if (r != null) return r;
  } catch (_) {}

  // 4) versões SEM rng (gera interno)
  try {
    final r = svc.tickAnualJaneiro(
      atributos: atributos,
      idadeNoDia1Jan: idadeNoDia1Jan,
      minutosAnoAnterior: minutosAnoAnterior,
      recebeuFoco: recebeuFoco,
      escolhasGanhos: escolhasGanhos,
      ordemQueda: ordemQueda,
    );
    if (r != null) return r;
  } catch (_) {}

  try {
    final r = svc.tickAnual(
      atributos: atributos,
      idadeNoDia1Jan: idadeNoDia1Jan,
      minutosAnoAnterior: minutosAnoAnterior,
      recebeuFoco: recebeuFoco,
      escolhasGanhos: escolhasGanhos,
      ordemQueda: ordemQueda,
    );
    if (r != null) return r;
  } catch (_) {}

  try {
    final r = svc.stepAnnual(
      atributos: atributos,
      idadeNoDia1Jan: idadeNoDia1Jan,
      minutosAnoAnterior: minutosAnoAnterior,
      recebeuFoco: recebeuFoco,
      escolhasGanhos: escolhasGanhos,
      ordemQueda: ordemQueda,
    );
    if (r != null) return r;
  } catch (_) {}

  return null;
}

/// Formata mapas {atributo: valor} com chaves ordenadas, para log bonito.
String _fmtAtribs(Map<String, int> m, {bool showSign = false}) {
  final keys = m.keys.toList()..sort();
  final parts = <String>[];
  for (final k in keys) {
    final v = m[k]!;
    final s = showSign && v >= 0 ? '+$v' : '$v';
    parts.add('$k:$s');
  }
  return '{${parts.join(', ')}}';
}

Map<String, int> _safeMapInt(dynamic x) {
  if (x is Map) {
    return x.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
  }
  return const <String, int>{};
}

int _safeInt(dynamic x) {
  if (x is int) return x;
  if (x is num) return x.toInt();
  return 0;
}

void _clampAtribs(Map<String, int> m, int min, int max) {
  for (final k in m.keys.toList()) {
    final v = m[k] ?? 0;
    m[k] = v.clamp(min, max);
  }
}
