// lib/services/_compat_shims.dart
// Shims temporários para manter código legado compilando durante a migração.

/// Variação tática usada por telas e seeds antigos
enum VariacaoTatica { padrao, ofensiva, defensiva, equilibrada }

/// Limites padrão para nível de execução
const int kNivelMin = 0;
const int kNivelMax = 100;
