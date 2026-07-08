import 'package:footory26/services/finance/finance_snapshot.dart';

class SeasonFinancialReport {
  final List<String> lines;

  const SeasonFinancialReport({
    required this.lines,
  });
}

class SeasonFinancialReportService {
  const SeasonFinancialReportService();

  SeasonFinancialReport build({
    required FinanceSnapshot? start,
    required FinanceSnapshot end,
  }) {
    final lines = <String>[];

    if (start == null) {
      lines.add(
        'Relatório financeiro — Dados insuficientes para comparação da temporada.',
      );
      return SeasonFinancialReport(lines: lines);
    }

    final debtDiff = end.debt - start.debt;
    final caixaDiff = end.caixa - start.caixa;
    final operacionalDiff = end.operacional - start.operacional;
    final totalCashDiff = end.totalCash - start.totalCash;

    if (debtDiff < 0) {
      final reductionRatio = _safeRatio(debtDiff.abs(), start.debt);
      lines.add(
        reductionRatio >= 0.25
            ? 'Relatório financeiro — O clube conseguiu uma redução significativa da dívida ao longo da temporada.'
            : 'Relatório financeiro — A dívida do clube foi reduzida, ainda que de forma moderada.',
      );
    } else if (debtDiff > 0) {
      final increaseRatio = _safeRatio(debtDiff, start.debt);
      lines.add(
        increaseRatio >= 0.25
            ? 'Relatório financeiro — A dívida do clube cresceu de forma preocupante durante a temporada.'
            : 'Relatório financeiro — A dívida do clube aumentou ao longo da temporada.',
      );
    } else {
      lines.add(
        'Relatório financeiro — A dívida do clube se manteve estável ao longo da temporada.',
      );
    }

    if (start.health != end.health) {
      lines.add(
        'Saúde financeira — O clube saiu de ${_label(start.health)} para ${_label(end.health)}.',
      );
    } else {
      lines.add(
        'Saúde financeira — O clube manteve o status ${_label(end.health)}.',
      );
    }

    if (operacionalDiff > 0) {
      lines.add(
        'Fluxo operacional — O clube terminou o ano com mais fôlego para cobrir salários, manutenção e custos mensais.',
      );
    } else if (operacionalDiff < 0) {
      lines.add(
        'Fluxo operacional — O clube consumiu parte da reserva operacional durante a temporada, reduzindo a margem para custos fixos.',
      );
    } else {
      lines.add(
        'Fluxo operacional — A reserva para salários e manutenção se manteve estável.',
      );
    }

    if (caixaDiff > 0) {
      lines.add(
        'Caixa livre — O clube aumentou o dinheiro disponível para investimentos, contratações e melhorias estruturais.',
      );
    } else if (caixaDiff < 0) {
      lines.add(
        'Caixa livre — O clube reduziu sua margem de investimento ao longo da temporada.',
      );
    } else {
      lines.add(
        'Caixa livre — O dinheiro disponível para investimentos se manteve estável.',
      );
    }

    if (totalCashDiff > 0) {
      lines.add(
        'Resumo financeiro — Somando caixa livre e fluxo operacional, o clube fechou a temporada com mais dinheiro disponível.',
      );
    } else if (totalCashDiff < 0) {
      lines.add(
        'Resumo financeiro — Somando caixa livre e fluxo operacional, o clube encerrou a temporada com menos margem financeira.',
      );
    } else {
      lines.add(
        'Resumo financeiro — O volume total de caixa do clube ficou praticamente estável.',
      );
    }

    return SeasonFinancialReport(lines: lines);
  }

  double _safeRatio(int value, int base) {
    if (base <= 0) return value > 0 ? 1.0 : 0.0;
    return value / base;
  }

  String _label(Object health) {
    final raw = health.toString();

    if (raw.contains('muitoSaudavel')) return 'Muito saudável';
    if (raw.contains('saudavel')) return 'Saudável';
    if (raw.contains('estavel')) return 'Estável';
    if (raw.contains('pressionado')) return 'Pressionado';
    if (raw.contains('critico')) return 'Crítico';
    if (raw.contains('colapsoFinanceiro')) return 'Colapso financeiro';

    return 'Desconhecido';
  }
}
