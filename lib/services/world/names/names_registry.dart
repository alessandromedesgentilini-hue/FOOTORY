// lib/services/world/names/registry.dart
//
// FutSim — Names registry por país
// - Mapas imutáveis de primeiros nomes e sobrenomes por país (códigos ISO-like).
// - Helpers seguros para obter listas com fallback e sortear um nome/sobrenome.
// - Suporta: BR, ES, IT.
//
// Observação: mantém compat com o uso atual (acessando os mapas diretamente).

import 'dart:math';
import 'pool_br.dart';
import 'pool_it.dart';
import 'pool_es.dart';

class NamesRegistry {
  /// Países suportados (códigos em CAIXA ALTA).
  static const List<String> supported = ['BR', 'ES', 'IT'];

  static const Map<String, List<String>> firstNamesByCountry = {
    'BR': kBR_FIRST_NAMES,
    'IT': kIT_FIRST_NAMES,
    'ES': kES_FIRST_NAMES,
  };

  static const Map<String, List<String>> surnamesByCountry = {
    'BR': kBR_SURNAMES,
    'IT': kIT_SURNAMES,
    'ES': kES_SURNAMES,
  };

  /// Retorna `true` se o país é suportado.
  static bool hasCountry(String code) =>
      supported.contains(code.trim().toUpperCase());

  /// Lista de primeiros nomes pelo código do país (fallback: BR).
  static List<String> firstNames(String code) =>
      firstNamesByCountry[code.trim().toUpperCase()] ?? kBR_FIRST_NAMES;

  /// Lista de sobrenomes pelo código do país (fallback: BR).
  static List<String> surnames(String code) =>
      surnamesByCountry[code.trim().toUpperCase()] ?? kBR_SURNAMES;

  /// Sorteia um primeiro nome do país informado (fallback: BR).
  static String pickFirst(String code, {Random? rng}) {
    final list = firstNames(code);
    final r = rng ?? Random();
    return list.isEmpty ? 'Alex' : list[r.nextInt(list.length)];
  }

  /// Sorteia um sobrenome do país informado (fallback: BR).
  static String pickSurname(String code, {Random? rng}) {
    final list = surnames(code);
    final r = rng ?? Random();
    return list.isEmpty ? 'Silva' : list[r.nextInt(list.length)];
  }

  /// Sorteia nome completo (primeiro + sobrenome).
  /// Use [sobrenomeComposto] para permitir dois sobrenomes com baixa probabilidade.
  static String pickFullName(
    String code, {
    bool sobrenomeComposto = true,
    Random? rng,
  }) {
    final r = rng ?? Random();
    final first = pickFirst(code, rng: r);
    final last1 = pickSurname(code, rng: r);

    if (!sobrenomeComposto) return '$first $last1';

    // Probabilidade leve de segundo sobrenome, variando por país.
    final prob = switch (code.trim().toUpperCase()) {
      'BR' => 0.28,
      'ES' => 0.35,
      'IT' => 0.22,
      _ => 0.25,
    };

    if (r.nextDouble() < prob) {
      // Evita duplicado imediato.
      String last2;
      final list = surnames(code);
      if (list.length <= 1) {
        last2 = (last1 == 'Souza') ? 'Santos' : 'Souza';
      } else {
        do {
          last2 = list[r.nextInt(list.length)];
        } while (last2 == last1 && list.length > 1);
      }
      return '$first $last1 $last2';
    }

    return '$first $last1';
  }
}
