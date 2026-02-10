// lib/core/game_state.dart
//
// GameState = estado global do MVP.
// - Gera o universo de clubes (80) a partir dos seeds.
// - Mantém o treinador (save central) e o clube atual.
// - Helpers para UI (por divisão, buscar por id/slug).
//
// ✅ Agora: ponte oficial para calendário real via SeasonClock EXISTENTE
//   (lib/services/world/season_clock.dart)
// - Deriva mês atual / janela Jan-Jul a partir de (ano + rodadaAtual).
// - Sem mover arquivos. Sem duplicar SeasonClock.
// - Pluga a competição atual (CompetitionModel) como "driver" do calendário.
//
// Importante:
// - Se você ainda não setou a competição no GameState, ele faz fallback seguro.

import '../data/clubes_data.dart';
import '../models/clube.dart';
import '../models/treinador.dart';
import '../models/competition_model.dart';
import '../services/world/season_clock.dart';

class GameState {
  GameState._();
  static final GameState I = GameState._();

  bool _inited = false;

  late final List<Clube> clubes;
  late Treinador treinador;

  /// ✅ Competição/Liga atual que dirige o calendário (rodadaAtual -> data/mês).
  /// Você deve setar isso quando criar/carregar a liga.
  CompetitionModel? _competicaoAtual;

  bool get isReady => _inited;

  /// Inicializa estado base do MVP.
  /// Depois a gente troca pra carregar do storage (Hive/Sqflite).
  Future<void> init() async {
    if (_inited) return;

    clubes = Clube.gerarUniverso();

    // Default: começa na Série D (id 61) até existir tela de escolha.
    treinador = Treinador(
      id: 'coach-001',
      nome: 'Treinador',
      clubeAtualId: 61,
      temporada: 2026,
    );

    _inited = true;

    // Debug útil: confirma que tá tudo certo
    // ignore: avoid_print
    print(
        'GameState.init OK | clubes=${clubes.length} | A=${clubesDaDivisao(Divisao.a).length} B=${clubesDaDivisao(Divisao.b).length} C=${clubesDaDivisao(Divisao.c).length} D=${clubesDaDivisao(Divisao.d).length}');
  }

  // ---------------------------------------------------------
  // Clube atual
  // ---------------------------------------------------------

  Clube get clubeAtual => clubeById(treinador.clubeAtualId);

  Clube clubeById(int id) => clubes.firstWhere((c) => c.id == id);

  Clube? clubeBySlug(String slug) {
    for (final c in clubes) {
      if (c.slug == slug) return c;
    }
    return null;
  }

  List<Clube> clubesDaDivisao(Divisao d) =>
      clubes.where((c) => c.divisao == d).toList(growable: false);

  /// Troca o "emprego" do treinador (quando escolher clube ou receber proposta).
  void setClubeAtual(int clubeId) {
    treinador.clubeAtualId = clubeId;
  }

  // ---------------------------------------------------------
  // ✅ Competição atual (driver do calendário)
  // ---------------------------------------------------------

  CompetitionModel? get competicaoAtual => _competicaoAtual;

  /// Chame isso assim que você criar/carregar a liga do ano.
  /// Ex: GameState.I.setCompeticaoAtual(ligaModel);
  void setCompeticaoAtual(CompetitionModel c) {
    _competicaoAtual = c;
  }

  /// Ano do calendário: usa ano da competição se existir; senão usa treinador.temporada.
  int get anoCalendario => _competicaoAtual?.ano ?? treinador.temporada;

  /// Rodada atual: usa rodadaAtual da competição se existir; senão fallback 1.
  int get rodadaAtual => _competicaoAtual?.rodadaAtual ?? 1;

  /// Total de rodadas: tenta inferir do CompetitionModel; se não, 1.
  int get totalRodadas {
    final c = _competicaoAtual;
    if (c == null) return 1;

    // CompetitionModel tem método interno, mas não expõe. Então inferimos pelo public API:
    // se tiver partidas, pega max(rodada) delas; senão usa rodadaAtual.
    if (c.partidas.isEmpty) return c.rodadaAtual;

    int maxRod = 1;
    for (final p in c.partidas) {
      try {
        final r = (p as dynamic).rodada;
        if (r is int && r > maxRod) maxRod = r;
        if (r is num && r.toInt() > maxRod) maxRod = r.toInt();
      } catch (_) {}
    }
    return maxRod;
  }

  // ---------------------------------------------------------
  // ✅ SeasonClock oficial (já existe no projeto)
  // ---------------------------------------------------------

  final SeasonClock _clock = const SeasonClock();

  /// Data real aproximada da rodada atual (padrão Dom/Qua).
  DateTime get dataRodadaAtual => _clock.dateForRound(
        ano: anoCalendario,
        rodada: rodadaAtual,
      );

  /// Mês real (1..12) baseado na rodada atual.
  int get mesAtual => _clock.monthForRound(
        ano: anoCalendario,
        rodada: rodadaAtual,
      );

  /// Janela de transferências aberta? (Jan/Jul)
  bool get janelaTransferenciaAberta => _clock.isTransferWindowOpen(
        ano: anoCalendario,
        rodada: rodadaAtual,
      );

  /// Label útil pra UI: "Rodada 7 • Março"
  String get labelCalendario {
    final m = mesAtual;
    final nomeMes = _mesNomePt(m);
    return 'Rodada $rodadaAtual • $nomeMes';
  }

  /// Avança a rodada via CompetitionModel (se existir).
  /// Retorna true se avançou.
  bool avancarRodada() {
    final c = _competicaoAtual;
    if (c == null) return false;
    return c.avancarRodada();
  }

  // ---------------------------------------------------------
  // helpers
  // ---------------------------------------------------------

  String _mesNomePt(int m) {
    switch (m) {
      case 1:
        return 'Janeiro';
      case 2:
        return 'Fevereiro';
      case 3:
        return 'Março';
      case 4:
        return 'Abril';
      case 5:
        return 'Maio';
      case 6:
        return 'Junho';
      case 7:
        return 'Julho';
      case 8:
        return 'Agosto';
      case 9:
        return 'Setembro';
      case 10:
        return 'Outubro';
      case 11:
        return 'Novembro';
      case 12:
        return 'Dezembro';
      default:
        return '—';
    }
  }
}
