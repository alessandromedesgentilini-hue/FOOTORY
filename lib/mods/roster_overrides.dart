// lib/mods/roster_overrides.dart
//
// Sistema de overrides de elenco — versão robusta e segura.
// Permite aplicar ajustes manuais em atributos, posições e dados do jogador
// por save, facilitando atualizações rápidas e patches de comunidade.
//
// Está **desativado por padrão** até finalizarmos a padronização de Jogador/Posição,
// mas já deixamos a API final pronta para reativar no futuro.

import '../models/jogador.dart';
import '../models/posicao.dart';

/// Override de atributos individuais de um jogador.
///
/// • id → ID único do jogador.
/// • posicao → nova posição principal, se fornecida.
/// • atributos → mapa parcial de atributos ajustados (0..10 ou 40..95, aceita ambos).
class RosterOverride {
  final String jogadorId;
  final Posicao? posicao;
  final Map<String, int>? atributos;

  const RosterOverride({
    required this.jogadorId,
    this.posicao,
    this.atributos,
  });

  RosterOverride copyWith({
    String? jogadorId,
    Posicao? posicao,
    Map<String, int>? atributos,
  }) {
    return RosterOverride(
      jogadorId: jogadorId ?? this.jogadorId,
      posicao: posicao ?? this.posicao,
      atributos: atributos ?? this.atributos,
    );
  }

  Map<String, dynamic> toJson() => {
        'jogadorId': jogadorId,
        'posicao': posicao?.name,
        'atributos': atributos,
      };

  factory RosterOverride.fromJson(Map<String, dynamic> j) {
    final posStr = (j['posicao'] ?? '').toString();
    final pos = PosicaoX.parse(posStr);
    final attrs = j['atributos'] is Map<String, dynamic>
        ? (j['atributos'] as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, int.tryParse('$v') ?? 0),
          )
        : null;

    return RosterOverride(
      jogadorId: j['jogadorId'] ?? '',
      posicao: pos,
      atributos: attrs,
    );
  }

  @override
  String toString() =>
      'RosterOverride($jogadorId, pos:${posicao?.label}, attrs:${atributos?.keys.length ?? 0})';
}

/// Registry global para overrides de jogadores.
/// Suporta carga dinâmica, merge incremental e clear/reset.
class RosterOverridesRegistry {
  RosterOverridesRegistry._();

  static final Map<String, RosterOverride> _overrides =
      <String, RosterOverride>{};

  /// Retorna override para jogador específico, se existir.
  static RosterOverride? de(String jogadorId) => _overrides[jogadorId];

  /// Define ou substitui override.
  static void set(RosterOverride override) {
    _overrides[override.jogadorId] = override;
  }

  /// Remove override por jogador.
  static bool remove(String jogadorId) => _overrides.remove(jogadorId) != null;

  /// Limpa todos os overrides carregados.
  static void clear() => _overrides.clear();

  /// Snapshot imutável do estado atual.
  static Map<String, RosterOverride> snapshot() => Map.unmodifiable(_overrides);

  /// Merge incremental a partir de uma lista JSON.
  static void importJson(List<dynamic> data, {bool merge = true}) {
    if (!merge) clear();
    for (final e in data) {
      if (e is Map<String, dynamic>) {
        final ovr = RosterOverride.fromJson(e);
        if (ovr.jogadorId.isNotEmpty) {
          _overrides[ovr.jogadorId] = ovr;
        }
      }
    }
  }

  /// Exporta todos os overrides atuais.
  static List<Map<String, dynamic>> exportJson() =>
      _overrides.values.map((o) => o.toJson()).toList(growable: false);

  /// Quantos overrides estão ativos no momento.
  static int get count => _overrides.length;
}
