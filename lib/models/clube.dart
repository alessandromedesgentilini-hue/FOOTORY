// lib/models/clube.dart
//
// Clube = entidade institucional do jogo (divisão/finanças/reputação/metas).
// TimeModel = elenco + estilo + regras esportivas (já existe).
//
// Este model nasce a partir do seed oficial em lib/data/clubes_data.dart
// e está preparado para salvar/carregar (JSON) no MVP.

import '../data/clubes_data.dart';
import 'estilos.dart';
import 'time_model.dart';

class Clube {
  final int id; // 1..80 (estável)
  Divisao divisao; // pode mudar por acesso/rebaixamento

  final String name;
  final String shortName;
  final String slug;

  // Institucional (MVP)
  double reputacao; // 1..10
  double caixa; // dinheiro disponível
  double folhaMensal; // custo mensal estimado

  // Elenco + estilo
  TimeModel time;

  Clube({
    required this.id,
    required this.divisao,
    required this.name,
    required this.shortName,
    required this.slug,
    required this.reputacao,
    required this.caixa,
    required this.folhaMensal,
    required this.time,
  });

  /// Cria um Clube do universo a partir do seed oficial.
  /// Por padrão usa o primeiro estilo do enum (seguro).
  factory Clube.fromSeed(
    ClubeSeed seed, {
    Estilo? estiloInicial,
  }) {
    final rep = _reputacaoBase(seed.divisao);
    final cx = _caixaBase(seed.divisao);
    final folha = _folhaMensalBase(seed.divisao);

    final estilo = estiloInicial ?? Estilo.values.first;

    // ID do TimeModel (string), estável:
    final timeId = 'CLB-${seed.id.toString().padLeft(3, '0')}';

    return Clube(
      id: seed.id,
      divisao: seed.divisao,
      name: seed.name,
      shortName: seed.shortName,
      slug: seed.slug,
      reputacao: rep,
      caixa: cx,
      folhaMensal: folha,
      time: TimeModel(
        id: timeId,
        nome: seed.name,
        estilo: estilo,
        // elenco: não precisa passar -> o TimeModel já cria lista vazia
      ),
    );
  }

  /// Gera o universo completo (80 clubes) a partir dos seeds.
  static List<Clube> gerarUniverso({Estilo? estiloInicial}) {
    return clubesSeeds
        .map((s) => Clube.fromSeed(s, estiloInicial: estiloInicial))
        .toList(growable: false);
  }

  // ------------------------
  // JSON / Persistência
  // ------------------------

  Map<String, dynamic> toJson() => {
        'id': id,
        'divisao': divisao.name, // 'a'|'b'|'c'|'d'
        'name': name,
        'shortName': shortName,
        'slug': slug,
        'reputacao': reputacao,
        'caixa': caixa,
        'folhaMensal': folhaMensal,
        'time': time.toJson(),
      };

  factory Clube.fromJson(Map<String, dynamic> json) {
    final divStr = (json['divisao'] ?? 'd').toString();
    final div = Divisao.values.firstWhere(
      (e) => e.name == divStr,
      orElse: () => Divisao.d,
    );

    final id = (json['id'] as num).toInt();

    // reconstrói do seed (garante nomes oficiais sempre)
    final seed = clubesSeeds.firstWhere(
      (s) => s.id == id,
      orElse: () => ClubeSeed(
        id: id,
        divisao: div,
        name: (json['name'] ?? 'Clube $id').toString(),
        shortName: (json['shortName'] ?? 'Clube $id').toString(),
        slug: (json['slug'] ?? 'clube_$id').toString(),
      ),
    );

    final timeJson = json['time'] as Map<String, dynamic>?;

    return Clube(
      id: id,
      divisao: div,
      name: seed.name,
      shortName: seed.shortName,
      slug: seed.slug,
      reputacao: (json['reputacao'] as num?)?.toDouble() ?? _reputacaoBase(div),
      caixa: (json['caixa'] as num?)?.toDouble() ?? _caixaBase(div),
      folhaMensal:
          (json['folhaMensal'] as num?)?.toDouble() ?? _folhaMensalBase(div),
      time: timeJson != null
          ? TimeModel.fromJson(timeJson)
          : TimeModel(
              id: 'CLB-${id.toString().padLeft(3, '0')}',
              nome: seed.name,
              estilo: Estilo.values.first,
            ),
    );
  }

  @override
  String toString() => 'Clube($id, ${divisao.name.toUpperCase()}, $name)';
}

// ------------------------
// Defaults MVP (simples)
// ------------------------

double _reputacaoBase(Divisao d) {
  switch (d) {
    case Divisao.a:
      return 7.5;
    case Divisao.b:
      return 6.0;
    case Divisao.c:
      return 4.5;
    case Divisao.d:
      return 3.5;
  }
}

double _caixaBase(Divisao d) {
  switch (d) {
    case Divisao.a:
      return 12000000.0;
    case Divisao.b:
      return 5000000.0;
    case Divisao.c:
      return 2000000.0;
    case Divisao.d:
      return 800000.0;
  }
}

double _folhaMensalBase(Divisao d) {
  switch (d) {
    case Divisao.a:
      return 2000000.0;
    case Divisao.b:
      return 850000.0;
    case Divisao.c:
      return 350000.0;
    case Divisao.d:
      return 150000.0;
  }
}
