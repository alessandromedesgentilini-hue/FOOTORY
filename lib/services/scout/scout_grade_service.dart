// lib/services/scout/scout_grade_service.dart
//
// ScoutGradeService
// - Calcula os pilares (of/def/tec/men/fis) como média 1..10
// - Converte para A–E (9–10 / 7–8 / 5–6 / 3–4 / 1–2)
// - NÃO é core de atributo; é “camada de observação” para mercado/análises.
//
// ✅ FIXES:
// - Remove dependência externa: implementa GradeUtils aqui.
// - Corrige chaves inexistentes no seu catálogo:
//    • 'bola_parada' -> 'chute_longe'
//    • 'forca'       -> 'potencia'

import '../../models/jogador.dart';
import '../../models/scout/attribute_grade.dart';
import '../../models/scout/scout_filter.dart';

class ScoutGradeService {
  const ScoutGradeService();

  /// Retorna a nota 1..10 de um pilar.
  double pillarAvg10(Jogador j, ScoutPillar pillar) {
    final attrs = _getAttrs(j);

    // Observação:
    // - Aqui é “camada de scouting”, então a seleção de chaves é heurística.
    // - Usa apenas chaves existentes no core (29).
    final keys = switch (pillar) {
      ScoutPillar.ofensivo => const [
          'finalizacao',
          'presenca_ofensiva',
          'drible',
          'dominio_conducao',
          'passe_curto',
          'chute_longe',
        ],
      ScoutPillar.defensivo => const [
          'marcacao',
          'cobertura_defensiva',
          'jogo_aereo',
          'antecipacao',
          'desarme',
          'controle_area',
        ],
      ScoutPillar.tecnico => const [
          'passe_curto',
          'passe_longo',
          'dominio_conducao',
          'drible',
          'cruzamento',
          'coordenacao_motora',
        ],
      ScoutPillar.mental => const [
          'tomada_decisao',
          'capacidade_tatica',
          'frieza',
          'espirito_protagonista',
          'composicao_natural',
        ],
      ScoutPillar.fisico => const [
          'velocidade',
          'resistencia',
          'potencia',
          'coordenacao_motora',
          'composicao_natural',
          'reflexo_reacao',
        ],
    };

    if (keys.isEmpty) return 5.0;

    var sum = 0;
    for (final k in keys) {
      sum += (attrs[k] ?? 5).clamp(1, 10);
    }

    final avg = sum / keys.length;
    return avg.clamp(1.0, 10.0);
  }

  /// Converte pilar -> grade A–E.
  AttributeGrade pillarGrade(Jogador j, ScoutPillar pillar) {
    final avg = pillarAvg10(j, pillar);
    return GradeUtils.fromAvg10(avg);
  }

  /// Retorna os 5 pilares já em A–E.
  Map<ScoutPillar, AttributeGrade> allPillarsGrade(Jogador j) {
    return {
      ScoutPillar.ofensivo: pillarGrade(j, ScoutPillar.ofensivo),
      ScoutPillar.defensivo: pillarGrade(j, ScoutPillar.defensivo),
      ScoutPillar.tecnico: pillarGrade(j, ScoutPillar.tecnico),
      ScoutPillar.mental: pillarGrade(j, ScoutPillar.mental),
      ScoutPillar.fisico: pillarGrade(j, ScoutPillar.fisico),
    };
  }

  // -------------------------
  // Interno: pega atributos 1..10 do Jogador
  // -------------------------
  Map<String, int> _getAttrs(Jogador j) {
    // caminho B: Jogador.atributos
    try {
      final dyn = j as dynamic;
      final v = dyn.atributos;
      if (v is Map<String, int>) return v;
      if (v is Map) {
        return v.map((k, val) => MapEntry(k.toString(), (val as num).toInt()));
      }
    } catch (_) {}
    return const {};
  }
}

class GradeUtils {
  const GradeUtils._();

  /// 9–10 => A, 7–8 => B, 5–6 => C, 3–4 => D, 1–2 => E
  static AttributeGrade fromAvg10(double avg10) {
    final v = avg10.clamp(1.0, 10.0);

    if (v >= 9.0) return AttributeGrade.A;
    if (v >= 7.0) return AttributeGrade.B;
    if (v >= 5.0) return AttributeGrade.C;
    if (v >= 3.0) return AttributeGrade.D;
    return AttributeGrade.E;
  }
}
