import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/models/league_table.dart';
import 'package:footory26/pages/hub/widgets/hub_shared.dart';
import 'package:footory26/services/finance/finance_rules_service.dart';
import 'package:footory26/services/world/game_state.dart';

class HubExecutiveSummary extends StatelessWidget {
  final GameState gs;
  final List<TableEntry> table;

  const HubExecutiveSummary({
    super.key,
    required this.gs,
    required this.table,
  });

  @override
  Widget build(BuildContext context) {
    final userIndex = table.indexWhere(
      (entry) => entry.clubId == gs.userClubId,
    );

    final hasPlayedMatches = userIndex >= 0 && table[userIndex].played > 0;

    if (!hasPlayedMatches) {
      return _PreSeasonSummary(gs: gs);
    }

    final entry = table[userIndex];
    final position = userIndex + 1;
    final totalClubs = table.length;

    final power = snapFromPower10(
      gs.clubPower10(gs.userClubId),
    );

    final zone = _zoneInfo(
      position: position,
      total: totalClubs,
      divisionId: gs.divisionId,
    );

    final finance = _financeInfo(gs.userFinanceHealth);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SummaryHeader(
            title: 'Situação do clube',
            subtitle: 'Resumo atual da temporada',
            icon: Icons.assessment_rounded,
          ),
          const SizedBox(height: 11),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ExecutiveItem(
                  icon: Icons.leaderboard_rounded,
                  label: 'Posição',
                  value: '$positionº',
                  helper: '${entry.points} pontos',
                  color: _positionColor(
                    position,
                    totalClubs,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _ExecutiveItem(
                  icon: Icons.trending_up_rounded,
                  label: 'Momento',
                  value: zone.label,
                  helper: zone.helper,
                  color: zone.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ExecutiveItem(
                  icon: Icons.shield_rounded,
                  label: 'Força',
                  value: power.label10,
                  helper: '${power.stars5}/5 estrelas',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _ExecutiveItem(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Finanças',
                  value: finance.label,
                  helper: finance.helper,
                  color: finance.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static _ZoneInfo _zoneInfo({
    required int position,
    required int total,
    required String divisionId,
  }) {
    final division = divisionId.trim().toLowerCase();

    if (division == 'bra' || division == 'br-a') {
      if (position <= 4) {
        return const _ZoneInfo(
          label: 'Topo',
          helper: 'Briga pelo título',
          color: Colors.green,
        );
      }

      if (position <= 8) {
        return const _ZoneInfo(
          label: 'Continental',
          helper: 'Zona de classificação',
          color: Colors.teal,
        );
      }

      if (position > total - 4) {
        return const _ZoneInfo(
          label: 'Risco',
          helper: 'Luta contra a queda',
          color: Colors.red,
        );
      }

      return const _ZoneInfo(
        label: 'Estável',
        helper: 'Meio de tabela',
        color: AppColors.primary,
      );
    }

    if (division == 'brb' ||
        division == 'br-b' ||
        division == 'brc' ||
        division == 'br-c') {
      if (position <= 4) {
        return const _ZoneInfo(
          label: 'Acesso',
          helper: 'Zona de promoção',
          color: Colors.green,
        );
      }

      if (position > total - 4) {
        return const _ZoneInfo(
          label: 'Risco',
          helper: 'Zona de rebaixamento',
          color: Colors.red,
        );
      }

      return const _ZoneInfo(
        label: 'Estável',
        helper: 'Meio de tabela',
        color: AppColors.primary,
      );
    }

    if (division == 'brd' || division == 'br-d') {
      if (position <= 4) {
        return const _ZoneInfo(
          label: 'Classificação',
          helper: 'Zona de avanço',
          color: Colors.green,
        );
      }

      if (position > total - 4) {
        return const _ZoneInfo(
          label: 'Baixa',
          helper: 'Parte inferior',
          color: Colors.orange,
        );
      }

      return const _ZoneInfo(
        label: 'Disputa',
        helper: 'Em busca da vaga',
        color: AppColors.primary,
      );
    }

    if (position <= 4) {
      return const _ZoneInfo(
        label: 'Topo',
        helper: 'Entre os primeiros',
        color: Colors.green,
      );
    }

    if (position > total - 4) {
      return const _ZoneInfo(
        label: 'Risco',
        helper: 'Parte inferior',
        color: Colors.red,
      );
    }

    return const _ZoneInfo(
      label: 'Estável',
      helper: 'Meio de tabela',
      color: AppColors.primary,
    );
  }

  static Color _positionColor(int position, int total) {
    if (position <= 4) {
      return Colors.green;
    }

    if (position > total - 4) {
      return Colors.red;
    }

    return AppColors.primary;
  }

  static _FinanceInfo _financeInfo(FinanceHealth health) {
    switch (health) {
      case FinanceHealth.muitoSaudavel:
        return const _FinanceInfo(
          label: 'Excelente',
          helper: 'Caixa confortável',
          color: Colors.green,
        );

      case FinanceHealth.saudavel:
        return const _FinanceInfo(
          label: 'Saudável',
          helper: 'Situação positiva',
          color: Colors.green,
        );

      case FinanceHealth.estavel:
        return const _FinanceInfo(
          label: 'Estável',
          helper: 'Sem risco imediato',
          color: Colors.blue,
        );

      case FinanceHealth.pressionado:
        return const _FinanceInfo(
          label: 'Atenção',
          helper: 'Caixa pressionado',
          color: Colors.orange,
        );

      case FinanceHealth.critico:
        return const _FinanceInfo(
          label: 'Crítico',
          helper: 'Exige reação',
          color: Colors.red,
        );

      case FinanceHealth.colapsoFinanceiro:
        return const _FinanceInfo(
          label: 'Colapso',
          helper: 'Situação extrema',
          color: Colors.red,
        );
    }
  }
}

class _PreSeasonSummary extends StatelessWidget {
  final GameState gs;

  const _PreSeasonSummary({
    required this.gs,
  });

  @override
  Widget build(BuildContext context) {
    final power = snapFromPower10(
      gs.clubPower10(gs.userClubId),
    );

    final finance = _preSeasonFinanceInfo(
      gs.userFinanceHealth,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SummaryHeader(
            title: 'Situação do clube',
            subtitle: 'Preparação para a nova temporada',
            icon: Icons.flag_rounded,
          ),
          const SizedBox(height: 11),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ExecutiveItem(
                  icon: Icons.calendar_month_rounded,
                  label: 'Temporada',
                  value: '${gs.seasonYear}',
                  helper: 'Início da caminhada',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _ExecutiveItem(
                  icon: Icons.shield_rounded,
                  label: 'Força',
                  value: power.label10,
                  helper: '${power.stars5}/5 estrelas',
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          _ExecutiveItem(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Finanças',
            value: finance.label,
            helper: finance.helper,
            color: finance.color,
            horizontal: true,
          ),
        ],
      ),
    );
  }

  _FinanceInfo _preSeasonFinanceInfo(FinanceHealth health) {
    switch (health) {
      case FinanceHealth.muitoSaudavel:
        return const _FinanceInfo(
          label: 'Excelente',
          helper: 'Caixa confortável para iniciar o ano',
          color: Colors.green,
        );

      case FinanceHealth.saudavel:
        return const _FinanceInfo(
          label: 'Saudável',
          helper: 'Clube inicia o ano em boa situação',
          color: Colors.green,
        );

      case FinanceHealth.estavel:
        return const _FinanceInfo(
          label: 'Estável',
          helper: 'Orçamento sob controle',
          color: Colors.blue,
        );

      case FinanceHealth.pressionado:
        return const _FinanceInfo(
          label: 'Atenção',
          helper: 'Será necessário controlar os gastos',
          color: Colors.orange,
        );

      case FinanceHealth.critico:
        return const _FinanceInfo(
          label: 'Crítico',
          helper: 'A temporada começa sob pressão',
          color: Colors.red,
        );

      case FinanceHealth.colapsoFinanceiro:
        return const _FinanceInfo(
          label: 'Colapso',
          helper: 'Recuperação financeira é prioridade',
          color: Colors.red,
        );
    }
  }
}

class _SummaryHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SummaryHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExecutiveItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String helper;
  final Color color;
  final bool horizontal;

  const _ExecutiveItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.helper,
    required this.color,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (horizontal) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: color.withOpacity(0.18),
          ),
        ),
        child: Row(
          children: [
            _ItemIcon(
              icon: icon,
              color: color,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    helper,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(
        minHeight: 82,
      ),
      padding: const EdgeInsets.fromLTRB(9, 9, 9, 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withOpacity(0.18),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ItemIcon(
                icon: icon,
                color: color,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            helper,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _ItemIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 14,
        color: color,
      ),
    );
  }
}

class _ZoneInfo {
  final String label;
  final String helper;
  final Color color;

  const _ZoneInfo({
    required this.label,
    required this.helper,
    required this.color,
  });
}

class _FinanceInfo {
  final String label;
  final String helper;
  final Color color;

  const _FinanceInfo({
    required this.label,
    required this.helper,
    required this.color,
  });
}
