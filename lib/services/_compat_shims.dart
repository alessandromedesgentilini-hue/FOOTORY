// lib/services/_compat_shims.dart
//
// Shims temporários para manter código legado compilando durante a migração.
// Pode morar aqui em `services/` ou ser movido para `services/world/` depois,
// sem impacto — nada depende de caminho absoluto.

// --------- Enum legado de variação tática ---------
enum VariacaoTatica { padrao, ofensiva, defensiva, equilibrada }

extension VariacaoTaticaX on VariacaoTatica {
  /// Rótulo amigável (UI).
  String get label {
    switch (this) {
      case VariacaoTatica.padrao:
        return 'Padrão';
      case VariacaoTatica.ofensiva:
        return 'Ofensiva';
      case VariacaoTatica.defensiva:
        return 'Defensiva';
      case VariacaoTatica.equilibrada:
        return 'Equilibrada';
    }
  }

  /// Código curto (útil pra persistência/telemetria).
  String get code {
    switch (this) {
      case VariacaoTatica.padrao:
        return 'std';
      case VariacaoTatica.ofensiva:
        return 'off';
      case VariacaoTatica.defensiva:
        return 'def';
      case VariacaoTatica.equilibrada:
        return 'bal';
    }
  }
}

/// Parse tolerante a strings; retorna null se desconhecido.
VariacaoTatica? variacaoFromString(String? s) {
  if (s == null) return null;
  final k = s.trim().toLowerCase();
  switch (k) {
    case 'padrao':
    case 'padrão':
    case 'std':
      return VariacaoTatica.padrao;
    case 'ofensiva':
    case 'off':
      return VariacaoTatica.ofensiva;
    case 'defensiva':
    case 'def':
      return VariacaoTatica.defensiva;
    case 'equilibrada':
    case 'bal':
      return VariacaoTatica.equilibrada;
    default:
      return null;
  }
}

/// Parse por código curto (std/off/def/bal); retorna null se desconhecido.
VariacaoTatica? variacaoFromCode(String? code) {
  if (code == null) return null;
  switch (code) {
    case 'std':
      return VariacaoTatica.padrao;
    case 'off':
      return VariacaoTatica.ofensiva;
    case 'def':
      return VariacaoTatica.defensiva;
    case 'bal':
      return VariacaoTatica.equilibrada;
    default:
      return null;
  }
}

/// Lista [(enum,label)] — útil para Dropdowns.
List<(VariacaoTatica, String)> get variacoesComLabel =>
    VariacaoTatica.values.map((v) => (v, v.label)).toList(growable: false);

// --------- Limites padrão de “nível de execução” / porcentagem ---------
/// Nível “genérico” (0..100).
const int kNivelMin = 0;
const int kNivelMax = 100;

/// Porcentagem (0..100).
const int kPctMin = 0;
const int kPctMax = 100;

/// Clamp explícito pra evitar `num` vindo de `int.clamp`.
int clampNivel(int v) {
  if (v < kNivelMin) return kNivelMin;
  if (v > kNivelMax) return kNivelMax;
  return v;
}

/// Clamp de porcentagem 0..100.
int clampPct(int v) {
  if (v < kPctMin) return kPctMin;
  if (v > kPctMax) return kPctMax;
  return v;
}
