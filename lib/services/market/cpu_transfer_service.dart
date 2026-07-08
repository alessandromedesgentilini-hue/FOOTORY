import 'package:footory26/models/player.dart';
import 'package:footory26/services/market/market_service.dart';

class CpuTransferResult {
  final String clubId;
  final String divisionId;
  final Player? signedPlayer;
  final bool success;

  const CpuTransferResult({
    required this.clubId,
    required this.divisionId,
    required this.signedPlayer,
    required this.success,
  });
}

class CpuTransferService {
  const CpuTransferService();

  /// ============================================================
  /// EXECUTA UMA JANELA SIMPLES DE TRANSFERÊNCIAS CPU
  /// ============================================================
  ///
  /// Filosofia:
  /// - CPU não pensa em posição
  /// - CPU não monta elenco por função
  /// - CPU só compra por nível/divisão/força do clube
  ///
  /// REGRA CRÍTICA:
  /// - CPU NUNCA pode agir sobre clube excluído (ex: clube do usuário)
  ///
  List<CpuTransferResult> runWindow({
    required MarketService market,
    required Map<String, List<String>> clubIdsByDivision,
    required Map<String, double> clubPower10ById,
    required int maxSigningsPerClub,
    required bool allowMultiplePasses,
    Set<String> excludedClubIds = const <String>{},
  }) {
    final results = <CpuTransferResult>[];
    final safeMaxSignings = maxSigningsPerClub < 1 ? 1 : maxSigningsPerClub;

    const divisions = <String>['BR-A', 'BR-B', 'BR-C', 'BR-D'];

    for (final divisionId in divisions) {
      final clubIds = clubIdsByDivision[divisionId] ?? const <String>[];
      if (clubIds.isEmpty) continue;

      for (final clubId in clubIds) {
        if (excludedClubIds.contains(clubId)) {
          continue;
        }

        final clubPower10 = clubPower10ById[clubId] ?? 5.0;
        final attempts = allowMultiplePasses ? safeMaxSignings : 1;

        var signedCount = 0;

        for (var i = 0; i < attempts; i++) {
          final player = market.tryCpuSignFreeAgent(
            divisionId: divisionId,
            clubPower10: clubPower10,
            financeLevel: _financeLevelFromPower(clubPower10),
          );

          if (player == null) {
            results.add(
              CpuTransferResult(
                clubId: clubId,
                divisionId: divisionId,
                signedPlayer: null,
                success: false,
              ),
            );
            continue;
          }

          signedCount++;

          results.add(
            CpuTransferResult(
              clubId: clubId,
              divisionId: divisionId,
              signedPlayer: player,
              success: true,
            ),
          );

          if (!allowMultiplePasses) {
            break;
          }

          if (signedCount >= safeMaxSignings) {
            break;
          }
        }
      }
    }

    return results;
  }

  /// ============================================================
  /// EXECUTA SOMENTE PARA UMA DIVISÃO
  /// ============================================================
  List<CpuTransferResult> runDivisionWindow({
    required String divisionId,
    required List<String> clubIds,
    required MarketService market,
    required Map<String, double> clubPower10ById,
    int maxSigningsPerClub = 1,
    bool allowMultiplePasses = false,
    Set<String> excludedClubIds = const <String>{},
  }) {
    final results = <CpuTransferResult>[];
    final safeMaxSignings = maxSigningsPerClub < 1 ? 1 : maxSigningsPerClub;

    for (final clubId in clubIds) {
      if (excludedClubIds.contains(clubId)) {
        continue;
      }

      final clubPower10 = clubPower10ById[clubId] ?? 5.0;
      final attempts = allowMultiplePasses ? safeMaxSignings : 1;

      var signedCount = 0;

      for (var i = 0; i < attempts; i++) {
        final player = market.tryCpuSignFreeAgent(
          divisionId: divisionId,
          clubPower10: clubPower10,
          financeLevel: _financeLevelFromPower(clubPower10),
        );

        if (player == null) {
          results.add(
            CpuTransferResult(
              clubId: clubId,
              divisionId: divisionId,
              signedPlayer: null,
              success: false,
            ),
          );
          continue;
        }

        signedCount++;

        results.add(
          CpuTransferResult(
            clubId: clubId,
            divisionId: divisionId,
            signedPlayer: player,
            success: true,
          ),
        );

        if (!allowMultiplePasses) {
          break;
        }

        if (signedCount >= safeMaxSignings) {
          break;
        }
      }
    }

    return results;
  }

  /// ============================================================
  /// APLICA CONTRATAÇÕES NO MAPA DE ELENCOS
  /// ============================================================
  ///
  /// REGRA CRÍTICA:
  /// - nunca aplicar em clube excluído
  ///
  void applyResultsToSquads({
    required List<CpuTransferResult> results,
    required Map<String, List<Player>> proSquads,
    Set<String> excludedClubIds = const <String>{},
  }) {
    for (final result in results) {
      if (excludedClubIds.contains(result.clubId)) continue;
      if (!result.success) continue;

      final player = result.signedPlayer;
      if (player == null) continue;

      final squad = proSquads.putIfAbsent(result.clubId, () => <Player>[]);
      final alreadyExists = squad.any((p) => p.id == player.id);
      if (alreadyExists) continue;

      squad.add(player);
    }
  }

  /// ============================================================
  /// GERA LINHAS DE NOTÍCIA SIMPLES
  /// ============================================================
  ///
  /// REGRA CRÍTICA:
  /// - não gerar notícia para clube excluído
  ///
  List<String> buildNewsLines({
    required List<CpuTransferResult> results,
    required String Function(String clubId) clubNameResolver,
    Set<String> excludedClubIds = const <String>{},
  }) {
    final lines = <String>[];

    for (final result in results) {
      if (excludedClubIds.contains(result.clubId)) continue;
      if (!result.success) continue;

      final player = result.signedPlayer;
      if (player == null) continue;

      lines.add(
        '${clubNameResolver(result.clubId)} acertou a chegada de ${player.nome} (${player.ovrCheio}).',
      );
    }

    return lines;
  }

  /// ============================================================
  /// HELPER
  /// ============================================================
  int _financeLevelFromPower(double clubPower10) {
    if (clubPower10 >= 8.0) return 9;
    if (clubPower10 >= 7.0) return 8;
    if (clubPower10 >= 6.0) return 7;
    if (clubPower10 >= 5.0) return 6;
    if (clubPower10 >= 4.0) return 5;
    return 4;
  }
}
