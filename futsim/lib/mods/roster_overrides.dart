import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/jogador.dart';

class PlayerOverride {
  final String id;
  final String? nome, nacionalidade;
  final int? idade;
  final String? posicao;
  final List<String>? secundarias;

  PlayerOverride({
    required this.id,
    this.nome,
    this.nacionalidade,
    this.idade,
    this.posicao,
    this.secundarias,
  });

  factory PlayerOverride.fromJson(Map<String, dynamic> j) => PlayerOverride(
        id: j['id'] as String,
        nome: j['nome'] as String?,
        nacionalidade: j['nacionalidade'] as String?,
        idade: j['idade'] as int?,
        posicao: j['posicao'] as String?,
        secundarias:
            (j['secundarias'] as List?)?.map((e) => e.toString()).toList(),
      );
}

class RosterOverrides {
  final String packName, author;
  final List<PlayerOverride> overrides;
  RosterOverrides(
      {required this.packName, required this.author, required this.overrides});

  factory RosterOverrides.fromJson(Map<String, dynamic> j) => RosterOverrides(
        packName: j['packName'] as String? ?? 'Unnamed Pack',
        author: j['author'] as String? ?? 'Unknown',
        overrides: (j['overrides'] as List<dynamic>?)
                ?.map((e) => PlayerOverride.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const <PlayerOverride>[],
      );
}

Map<String, Jogador> applyRosterOverrides(
    Map<String, Jogador> base, RosterOverrides? pack) {
  if (pack == null || pack.overrides.isEmpty) return base;
  final out = Map<String, Jogador>.from(base);
  for (final ov in pack.overrides) {
    final j = out[ov.id];
    if (j == null) continue;

    List<Posicao>? secundarias;
    if (ov.secundarias != null) {
      secundarias = <Posicao>[];
      for (final s in ov.secundarias!) {
        try {
          secundarias.add(Posicao.values.firstWhere((e) => e.name == s));
        } catch (_) {}
      }
    }

    out[ov.id] = j.copyWith(
      nome: ov.nome ?? j.nome,
      nacionalidade: ov.nacionalidade ?? j.nacionalidade,
      idade: ov.idade ?? j.idade,
      posicaoPrincipal: ov.posicao != null
          ? Posicao.values.firstWhere((e) => e.name == ov.posicao)
          : j.posicaoPrincipal,
      funcoesSecundarias: secundarias ?? j.funcoesSecundarias,
    );
  }
  return out;
}

Future<RosterOverrides> loadOverridesFromAssets(String assetPath) async {
  final txt = await rootBundle.loadString(assetPath);
  final j = jsonDecode(txt) as Map<String, dynamic>;
  return RosterOverrides.fromJson(j);
}
