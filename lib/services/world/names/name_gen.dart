// lib/services/world/name_gen.dart
//
// Gerador de nomes com pesos por nacionalidade.
// - Compatível com uso estático: NameGen.fullName()
// - Também permite instanciar com seed personalizado para testes:
//     final ng = NameGen(seed: 42);
//     print(ng.gerarNomeCompleto());
//
// Pools esperados em: services/world/names/
//   pool_br.dart -> kBR_FIRST_NAMES / kBR_SURNAMES
//   pool_es.dart -> kES_FIRST_NAMES / kES_SURNAMES
//   pool_it.dart -> kIT_FIRST_NAMES / kIT_SURNAMES

import 'dart:math';
import '../names/pool_br.dart';
import '../names/pool_es.dart';
import '../names/pool_it.dart';

enum Nacionalidade { br, es, it }

extension NacionalidadeLabel on Nacionalidade {
  String get code {
    switch (this) {
      case Nacionalidade.br:
        return 'BRA';
      case Nacionalidade.es:
        return 'ESP';
      case Nacionalidade.it:
        return 'ITA';
    }
  }

  String get nome {
    switch (this) {
      case Nacionalidade.br:
        return 'Brasil';
      case Nacionalidade.es:
        return 'Espanha';
      case Nacionalidade.it:
        return 'Itália';
    }
  }
}

class NameRules {
  /// Pesos default (somam 1.0): BR 80%, ES 12%, IT 8%
  static const Map<Nacionalidade, double> distro = {
    Nacionalidade.br: 0.80,
    Nacionalidade.es: 0.12,
    Nacionalidade.it: 0.08,
  };
}

class NameGen {
  // ---------- interface estática de conveniência (compat) ----------
  static final NameGen _default = NameGen();
  static String fullName({
    Nacionalidade? nat,
    bool sobrenomeComposto = true,
  }) =>
      _default.gerarNomeCompleto(
        nat: nat,
        sobrenomeComposto: sobrenomeComposto,
      );

  static String firstName({Nacionalidade? nat}) =>
      _default.gerarPrimeiroNome(nat: nat);

  static String lastName({
    Nacionalidade? nat,
    bool composto = true,
  }) =>
      _default.gerarSobrenome(nat: nat, composto: composto);

  // ---------- instância ----------
  final Random _rng;
  final Map<Nacionalidade, double> _pesos; // normalizados e somente leitura

  NameGen({
    int? seed,
    Map<Nacionalidade, double>? pesos,
  })  : _rng = Random(seed),
        _pesos = _normalizar(pesos ?? NameRules.distro);

  // Normaliza pesos para somar 1.0 e garante entradas para todas as nats
  static Map<Nacionalidade, double> _normalizar(
      Map<Nacionalidade, double> inMap) {
    final out = <Nacionalidade, double>{
      for (final n in Nacionalidade.values) n: (inMap[n] ?? 0),
    };
    final soma = out.values.fold<double>(0, (a, b) => a + max(b, 0));
    if (soma <= 0) {
      // fallback defensivo: BR 100%
      return {
        Nacionalidade.br: 1.0,
        Nacionalidade.es: 0.0,
        Nacionalidade.it: 0.0,
      };
    }
    return {
      for (final e in out.entries) e.key: max(e.value, 0) / soma,
    };
  }

  // ---------- API de geração ----------
  String gerarNomeCompleto({
    Nacionalidade? nat,
    bool sobrenomeComposto = true,
  }) {
    final n = nat ?? _sorteiaNacionalidade();
    final first = gerarPrimeiroNome(nat: n);
    final last = gerarSobrenome(nat: n, composto: sobrenomeComposto);
    return '$first $last';
  }

  String gerarPrimeiroNome({Nacionalidade? nat}) {
    final n = nat ?? _sorteiaNacionalidade();
    final list = switch (n) {
      Nacionalidade.br => kBR_FIRST_NAMES,
      Nacionalidade.es => kES_FIRST_NAMES,
      Nacionalidade.it => kIT_FIRST_NAMES,
    };
    return _pick(list, fallback: 'Alex');
  }

  String gerarSobrenome({Nacionalidade? nat, bool composto = true}) {
    final n = nat ?? _sorteiaNacionalidade();
    final list = switch (n) {
      Nacionalidade.br => kBR_SURNAMES,
      Nacionalidade.es => kES_SURNAMES,
      Nacionalidade.it => kIT_SURNAMES,
    };
    final s1 = _pick(list, fallback: 'Silva');
    // Probabilidade pequena de sobrenome composto (ajustável por país)
    final prob = switch (n) {
      Nacionalidade.br => 0.28,
      Nacionalidade.es => 0.35,
      Nacionalidade.it => 0.22,
    };
    if (composto && _rng.nextDouble() < prob) {
      var s2 = _pick(list, fallback: 'Souza');
      // Evita duplicar o mesmo sobrenome
      if (s2 == s1 && list.length > 1) {
        do {
          s2 = _pick(list, fallback: 'Souza');
        } while (s2 == s1);
      }
      return '$s1 $s2';
    }
    return s1;
  }

  // ---------- internos ----------
  String _pick(List<String> list, {required String fallback}) {
    if (list.isEmpty) return fallback;
    return list[_rng.nextInt(list.length)];
  }

  Nacionalidade _sorteiaNacionalidade() {
    final p = _rng.nextDouble();
    double acc = 0;
    for (final e in _pesos.entries) {
      acc += e.value;
      if (p <= acc) return e.key;
    }
    // fallback impossível em teoria por conta da normalização
    return Nacionalidade.br;
  }
}
