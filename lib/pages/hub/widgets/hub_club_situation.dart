import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/core/money_formatter.dart';
import 'package:footory26/models/league_table.dart';
import 'package:footory26/pages/hub/widgets/hub_shared.dart';
import 'package:footory26/services/finance/finance_rules_service.dart';
import 'package:footory26/services/world/game_state.dart';

class HubClubSituation extends StatelessWidget {
  final GameState gs;
  final List<TableEntry> table;

  const HubClubSituation({
    super.key,
    required this.gs,
    required this.table,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final idx = table.indexWhere((e) => e.clubId == gs.userClubId);
    if (idx < 0) {
      return Text(
        'Situação indisponível.',
        style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
      );
    }

    final position = idx + 1;
    final points = table[idx].points;
    final played = table[idx].played;

    final snap = gs.expectations;
    final userSnap = snapFromPower10(gs.clubPower10(gs.userClubId));

    final isPreSeason = played == 0;

    final zoneLabel = _zoneLabel(
      position: position,
      total: table.length,
      divisionId: gs.divisionId,
    );

    final financeHealth = gs.userFinanceHealth;
    final operacional = gs.userOperationalCash;
    final fixedCost = gs.userTotalMonthlyFixedCost;
    final debt = gs.userDebt;
    final repassPct = (gs.userRepassPercentage * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isPreSeason) ...[
          _TopHighlightCard(
            icon: Icons.flag_outlined,
            title: 'Início de temporada',
            subtitle: 'A caminhada do clube está começando.',
          ),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.bolt_outlined,
            label: 'Força do Clube',
            value: userSnap.label10,
            tail: HubStars5(filled: userSnap.stars5, size: 18),
          ),
          if (snap != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _BadgeInfoBox(
                    title: 'Expectativa',
                    value: snap.expectedLabel,
                    icon: Icons.assignment_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _BadgeInfoBox(
                    title: 'Status',
                    value: snap.statusLabel,
                    icon: Icons.insights_outlined,
                  ),
                ),
              ],
            ),
          ],
        ] else ...[
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Posição',
                  value: '$positionº',
                  icon: Icons.leaderboard_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  title: 'Pontos',
                  value: '$points',
                  icon: Icons.confirmation_number_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  title: 'Zona',
                  value: _shortZone(zoneLabel),
                  icon: Icons.flag_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TopHighlightCard(
            icon: _zoneIcon(zoneLabel),
            title: zoneLabel,
            subtitle: _zoneDescription(zoneLabel),
          ),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.bolt_outlined,
            label: 'Força do Clube',
            value: userSnap.label10,
            tail: HubStars5(filled: userSnap.stars5, size: 18),
          ),
          if (snap != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _BadgeInfoBox(
                    title: 'Expectativa',
                    value: snap.expectedLabel,
                    icon: Icons.assignment_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _BadgeInfoBox(
                    title: 'Status',
                    value: snap.statusLabel,
                    icon: Icons.insights_outlined,
                  ),
                ),
              ],
            ),
          ],
        ],

        // =====================================================
        // FINANÇAS
        // =====================================================

        const SizedBox(height: 14),

        _FinanceSituationCard(
          health: financeHealth,
          operacional: operacional,
          fixedCost: fixedCost,
          debt: debt,
          repassPct: repassPct,
        ),
      ],
    );
  }

  String _zoneLabel({
    required int position,
    required int total,
    required String divisionId,
  }) {
    const topCount = 4;
    const relegateCount = 4;

    final div = divisionId.trim().toUpperCase();

    if (div == 'BR-A') {
      if (position <= 4) return 'Briga pelo título';
      if (position <= 8) return 'Vaga continental';
      if (position <= 16) return 'Meio de tabela';
      return 'Luta contra o rebaixamento';
    }

    if (div == 'BR-D') {
      if (position <= topCount) return 'Acesso';
      if (position > total - relegateCount) return 'Baixa tabela';
      return 'Meio de tabela';
    }

    if (position <= topCount) return 'Acesso';
    if (position > total - relegateCount) return 'Rebaixamento';
    return 'Meio de tabela';
  }

  String _shortZone(String zone) {
    switch (zone) {
      case 'Briga pelo título':
        return 'Título';
      case 'Vaga continental':
        return 'Continental';
      case 'Luta contra o rebaixamento':
        return 'Perigo';
      default:
        return zone;
    }
  }

  String _zoneDescription(String zone) {
    switch (zone) {
      case 'Briga pelo título':
        return 'O clube está competindo na parte mais alta da tabela.';
      case 'Vaga continental':
        return 'A equipe está forte e sonha com vaga internacional.';
      case 'Acesso':
        return 'O clube está lutando para subir de divisão.';
      case 'Rebaixamento':
        return 'A equipe precisa reagir para fugir da queda.';
      case 'Luta contra o rebaixamento':
        return 'Cada rodada pesa muito na permanência.';
      case 'Baixa tabela':
        return 'O clube precisa crescer para entrar na briga de cima.';
      default:
        return 'A temporada segue em aberto e cada rodada importa.';
    }
  }

  IconData _zoneIcon(String zone) {
    switch (zone) {
      case 'Briga pelo título':
        return Icons.emoji_events_outlined;
      case 'Vaga continental':
        return Icons.public_outlined;
      case 'Acesso':
        return Icons.trending_up_rounded;
      case 'Rebaixamento':
      case 'Luta contra o rebaixamento':
        return Icons.warning_amber_rounded;
      default:
        return Icons.insights_outlined;
    }
  }
}

class _FinanceSituationCard extends StatelessWidget {
  final FinanceHealth health;
  final int operacional;
  final int fixedCost;
  final int debt;
  final int repassPct;

  const _FinanceSituationCard({
    required this.health,
    required this.operacional,
    required this.fixedCost,
    required this.debt,
    required this.repassPct,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final isDanger = operacional < fixedCost;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDanger
            ? AppColors.danger.withOpacity(0.08)
            : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color:
              isDanger ? AppColors.danger.withOpacity(0.35) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDanger ? AppColors.danger : AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDanger
                      ? Icons.warning_amber_rounded
                      : Icons.account_balance_wallet_outlined,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Situação Financeira',
                      style: t.titleSmall?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _healthLabel(health),
                      style: t.bodyMedium?.copyWith(
                        color: isDanger ? AppColors.danger : AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _FinanceLine(
            label: 'Fluxo operacional',
            value: MoneyFormatter.formatCurrency(operacional),
          ),
          _FinanceLine(
            label: 'Custo fixo mensal',
            value: MoneyFormatter.formatCurrency(fixedCost),
          ),
          _FinanceLine(
            label: 'Dívida',
            value: MoneyFormatter.formatCurrency(debt),
          ),
          _FinanceLine(
            label: 'Repasse',
            value: '$repassPct%',
            highlighted: true,
          ),
          const SizedBox(height: 12),
          Text(
            _summary(),
            style: t.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  String _summary() {
    if (operacional < 0) {
      return 'O fluxo operacional está negativo. O clube já não consegue cobrir salários e manutenção com estabilidade.';
    }

    if (operacional < fixedCost) {
      return 'O fluxo operacional está apertado. O clube precisa controlar gastos ou aumentar receitas rapidamente.';
    }

    switch (health) {
      case FinanceHealth.muitoSaudavel:
        return 'O clube vive um momento financeiro muito confortável.';
      case FinanceHealth.saudavel:
        return 'A situação financeira é positiva e estável.';
      case FinanceHealth.estavel:
        return 'O clube está equilibrado, mas ainda sem grande margem.';
      case FinanceHealth.pressionado:
        return 'A dívida começa a limitar o crescimento do clube.';
      case FinanceHealth.critico:
        return 'O ambiente financeiro já preocupa bastante.';
      case FinanceHealth.colapsoFinanceiro:
        return 'O clube atravessa um cenário extremo de pressão financeira.';
    }
  }

  String _healthLabel(FinanceHealth health) {
    switch (health) {
      case FinanceHealth.muitoSaudavel:
        return 'Muito saudável';
      case FinanceHealth.saudavel:
        return 'Saudável';
      case FinanceHealth.estavel:
        return 'Estável';
      case FinanceHealth.pressionado:
        return 'Pressionado';
      case FinanceHealth.critico:
        return 'Crítico';
      case FinanceHealth.colapsoFinanceiro:
        return 'Colapso financeiro';
    }
  }
}

class _FinanceLine extends StatelessWidget {
  final String label;
  final String value;
  final bool highlighted;

  const _FinanceLine({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: t.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: t.bodySmall?.copyWith(
              color: highlighted ? AppColors.primary : AppColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: t.titleSmall?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            style: t.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopHighlightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TopHighlightCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: t.titleSmall?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: t.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? tail;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.tail,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: t.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: t.titleSmall?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          if (tail != null) ...[
            const SizedBox(width: 12),
            tail!,
          ],
        ],
      ),
    );
  }
}

class _BadgeInfoBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _BadgeInfoBox({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              icon,
              size: 19,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: t.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: t.bodyMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
