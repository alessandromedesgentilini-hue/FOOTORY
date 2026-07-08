import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/core/money_formatter.dart';
import 'package:footory26/core/providers.dart';
import 'package:footory26/services/finance/finance_rules_service.dart';
import 'package:footory26/services/world/game_state.dart';

enum _FinanceTab {
  summary,
  costs,
  debt,
  structures,
  explanation,
}

class FinancePage extends ConsumerStatefulWidget {
  const FinancePage({super.key});

  @override
  ConsumerState<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends ConsumerState<FinancePage> {
  _FinanceTab _selectedTab = _FinanceTab.summary;

  @override
  Widget build(BuildContext context) {
    final GameState gs = ref.watch(gameStateProvider);

    if (!gs.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final caixa = gs.userFinance.caixa;
    final operacional = gs.userFinance.operacional;
    final debt = gs.userDebt;

    final monthlyWage = gs.userMonthlyWage;
    final structureMaintenance = gs.userStructureMaintenance;
    final totalFixedCost = gs.userTotalMonthlyFixedCost;
    final repassPct = (gs.userRepassPercentage * 100).round();
    final health = gs.userFinanceHealth;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Finanças'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
          child: Column(
            children: [
              _FinanceHeroCard(
                health: health,
                caixa: caixa,
                operacional: operacional,
              ),
              const SizedBox(height: 8),
              _FinanceQuickGrid(
                caixa: caixa,
                operacional: operacional,
                debt: debt,
                monthlyWage: monthlyWage,
                structureMaintenance: structureMaintenance,
                repassPct: repassPct,
              ),
              const SizedBox(height: 8),
              _FinanceMiniTabs(
                selected: _selectedTab,
                onChanged: (tab) {
                  setState(() {
                    _selectedTab = tab;
                  });
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _FinanceContentPanel(
                  selectedTab: _selectedTab,
                  health: health,
                  caixa: caixa,
                  operacional: operacional,
                  debt: debt,
                  monthlyWage: monthlyWage,
                  structureMaintenance: structureMaintenance,
                  totalFixedCost: totalFixedCost,
                  repassPct: repassPct,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinanceHeroCard extends StatelessWidget {
  final FinanceHealth health;
  final int caixa;
  final int operacional;

  const _FinanceHeroCard({
    required this.health,
    required this.caixa,
    required this.operacional,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      height: 118,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppColors.actionGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.white.withOpacity(0.18),
              ),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: AppColors.white,
              size: 42,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _healthLabel(health),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _healthDescription(health),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelMedium?.copyWith(
                    color: AppColors.white.withOpacity(0.94),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _HeroPill(label: 'Caixa ${_money(caixa)}'),
                    const SizedBox(width: 6),
                    _HeroPill(label: 'Oper. ${_money(operacional)}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final String label;

  const _HeroPill({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: AppColors.white.withOpacity(0.14),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
    );
  }
}

class _FinanceQuickGrid extends StatelessWidget {
  final int caixa;
  final int operacional;
  final int debt;
  final int monthlyWage;
  final int structureMaintenance;
  final int repassPct;

  const _FinanceQuickGrid({
    required this.caixa,
    required this.operacional,
    required this.debt,
    required this.monthlyWage,
    required this.structureMaintenance,
    required this.repassPct,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _QuickTile(
              icon: Icons.savings_rounded,
              label: 'Caixa',
              value: _money(caixa),
            ),
            const SizedBox(width: 7),
            _QuickTile(
              icon: Icons.sync_alt_rounded,
              label: 'Operacional',
              value: _money(operacional),
            ),
            const SizedBox(width: 7),
            _QuickTile(
              icon: Icons.warning_amber_rounded,
              label: 'Dívida',
              value: _money(debt),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            _QuickTile(
              icon: Icons.payments_rounded,
              label: 'Folha',
              value: _money(monthlyWage),
            ),
            const SizedBox(width: 7),
            _QuickTile(
              icon: Icons.apartment_rounded,
              label: 'Estruturas',
              value: _money(structureMaintenance),
            ),
            const SizedBox(width: 7),
            _QuickTile(
              icon: Icons.percent_rounded,
              label: 'Repasse',
              value: '$repassPct%',
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _QuickTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.94),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.13),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.045),
              blurRadius: 9,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 19,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 10.2,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinanceMiniTabs extends StatelessWidget {
  final _FinanceTab selected;
  final ValueChanged<_FinanceTab> onChanged;

  const _FinanceMiniTabs({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _TabChip(
            label: 'Resumo',
            selected: selected == _FinanceTab.summary,
            onTap: () => onChanged(_FinanceTab.summary),
          ),
          const SizedBox(width: 6),
          _TabChip(
            label: 'Custos',
            selected: selected == _FinanceTab.costs,
            onTap: () => onChanged(_FinanceTab.costs),
          ),
          const SizedBox(width: 6),
          _TabChip(
            label: 'Dívidas',
            selected: selected == _FinanceTab.debt,
            onTap: () => onChanged(_FinanceTab.debt),
          ),
          const SizedBox(width: 6),
          _TabChip(
            label: 'Estruturas',
            selected: selected == _FinanceTab.structures,
            onTap: () => onChanged(_FinanceTab.structures),
          ),
          const SizedBox(width: 6),
          _TabChip(
            label: 'Explicação',
            selected: selected == _FinanceTab.explanation,
            onTap: () => onChanged(_FinanceTab.explanation),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.13),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: selected ? AppColors.white : AppColors.primaryDark,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
      ),
    );
  }
}

class _FinanceContentPanel extends StatelessWidget {
  final _FinanceTab selectedTab;
  final FinanceHealth health;
  final int caixa;
  final int operacional;
  final int debt;
  final int monthlyWage;
  final int structureMaintenance;
  final int totalFixedCost;
  final int repassPct;

  const _FinanceContentPanel({
    required this.selectedTab,
    required this.health,
    required this.caixa,
    required this.operacional,
    required this.debt,
    required this.monthlyWage,
    required this.structureMaintenance,
    required this.totalFixedCost,
    required this.repassPct,
  });

  @override
  Widget build(BuildContext context) {
    return _PremiumSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            title: _title,
            subtitle: _subtitle,
            icon: _icon,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }

  String get _title {
    switch (selectedTab) {
      case _FinanceTab.summary:
        return 'Resumo Financeiro';
      case _FinanceTab.costs:
        return 'Custos Fixos';
      case _FinanceTab.debt:
        return 'Dívidas e Repasse';
      case _FinanceTab.structures:
        return 'Impacto das Estruturas';
      case _FinanceTab.explanation:
        return 'Como Funciona';
    }
  }

  String get _subtitle {
    switch (selectedTab) {
      case _FinanceTab.summary:
        return 'Leitura rápida do momento do clube.';
      case _FinanceTab.costs:
        return 'Folha, manutenção e operação mensal.';
      case _FinanceTab.debt:
        return 'Peso da dívida no crescimento do clube.';
      case _FinanceTab.structures:
        return 'Quanto a estrutura pesa no mês.';
      case _FinanceTab.explanation:
        return 'Regras básicas do sistema financeiro.';
    }
  }

  IconData get _icon {
    switch (selectedTab) {
      case _FinanceTab.summary:
        return Icons.insights_rounded;
      case _FinanceTab.costs:
        return Icons.payments_outlined;
      case _FinanceTab.debt:
        return Icons.warning_amber_rounded;
      case _FinanceTab.structures:
        return Icons.apartment_rounded;
      case _FinanceTab.explanation:
        return Icons.tips_and_updates_outlined;
    }
  }

  Widget _buildContent(BuildContext context) {
    switch (selectedTab) {
      case _FinanceTab.summary:
        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            _TextBlock(
              icon: Icons.insights_rounded,
              title: 'Leitura do momento',
              text: _momentSummary(
                health: health,
                caixa: caixa,
                operacional: operacional,
                debt: debt,
                totalFixedCost: totalFixedCost,
              ),
            ),
            const SizedBox(height: 8),
            _FinanceLineCard(
              rows: [
                _FinanceRowData('Saúde financeira', _healthLabel(health)),
                _FinanceRowData('Caixa livre', _money(caixa)),
                _FinanceRowData('Fluxo operacional', _money(operacional)),
                _FinanceRowData('Dívida total', _money(debt),
                    highlighted: true),
                _FinanceRowData('Repasse atual', '$repassPct%'),
              ],
            ),
          ],
        );

      case _FinanceTab.costs:
        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            _FinanceLineCard(
              rows: [
                _FinanceRowData('Folha salarial mensal', _money(monthlyWage)),
                _FinanceRowData(
                  'Manutenção estrutural',
                  _money(structureMaintenance),
                ),
                _FinanceRowData(
                  'Custo fixo mensal total',
                  _money(totalFixedCost),
                  highlighted: true,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _TextBlock(
              icon: Icons.payments_rounded,
              title: 'Pressão mensal',
              text:
                  'Esse é o peso fixo que o clube precisa suportar para manter elenco e estrutura funcionando.',
            ),
          ],
        );

      case _FinanceTab.debt:
        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            _FinanceLineCard(
              rows: [
                _FinanceRowData('Dívida total', _money(debt),
                    highlighted: true),
                _FinanceRowData('Repasse atual', '$repassPct%'),
                _FinanceRowData('Caixa livre', _money(caixa)),
                _FinanceRowData('Fluxo operacional', _money(operacional)),
              ],
            ),
            const SizedBox(height: 8),
            _TextBlock(
              icon: Icons.warning_amber_rounded,
              title: 'Impacto da dívida',
              text:
                  'Dívida alta reduz o repasse das grandes receitas e limita o crescimento. Mesmo com caixa, o clube pode ficar travado se a dívida dominar a estrutura financeira.',
            ),
          ],
        );

      case _FinanceTab.structures:
        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            _FinanceLineCard(
              rows: [
                _FinanceRowData(
                  'Manutenção estrutural',
                  _money(structureMaintenance),
                  highlighted: true,
                ),
                _FinanceRowData(
                  'Custo fixo mensal total',
                  _money(totalFixedCost),
                ),
                _FinanceRowData('Fluxo operacional', _money(operacional)),
              ],
            ),
            const SizedBox(height: 8),
            _TextBlock(
              icon: Icons.apartment_rounded,
              title: 'Estruturas do clube',
              text:
                  'Estruturas melhores aumentam o potencial do clube, mas também pesam na manutenção mensal. Evoluir sem proteger o fluxo operacional pode apertar a temporada.',
            ),
          ],
        );

      case _FinanceTab.explanation:
        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: const [
            _BulletLine(
              text:
                  'Caixa livre é o dinheiro disponível para contratações, estruturas e investimentos.',
            ),
            SizedBox(height: 8),
            _BulletLine(
              text:
                  'Fluxo operacional é a reserva usada para pagar salários e manutenção mensal.',
            ),
            SizedBox(height: 8),
            _BulletLine(
              text:
                  'Dívida alta reduz o repasse das grandes receitas e limita o crescimento do clube.',
            ),
            SizedBox(height: 8),
            _BulletLine(
              text:
                  'Bilheteria entra como receita cheia, mas vendas e premiações sofrem impacto da saúde financeira.',
            ),
            SizedBox(height: 8),
            _BulletLine(
              text:
                  'Se o fluxo operacional ficar negativo, o clube começa a operar sob pressão.',
            ),
          ],
        );
    }
  }
}

class _PanelHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _PanelHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.primaryDark,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FinanceLineCard extends StatelessWidget {
  final List<_FinanceRowData> rows;

  const _FinanceLineCard({
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.12),
        ),
      ),
      child: Column(
        children: rows.map((row) {
          return _FinanceLine(
            label: row.label,
            value: row.value,
            isHighlighted: row.highlighted,
          );
        }).toList(),
      ),
    );
  }
}

class _FinanceRowData {
  final String label;
  final String value;
  final bool highlighted;

  const _FinanceRowData(
    this.label,
    this.value, {
    this.highlighted = false,
  });
}

class _FinanceLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;

  const _FinanceLine({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            textAlign: TextAlign.right,
            style: t.bodySmall?.copyWith(
              color: isHighlighted ? AppColors.primaryDark : AppColors.text,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _TextBlock({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.primaryDark,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: t.labelMedium?.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: t.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
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

class _BulletLine extends StatelessWidget {
  final String text;

  const _BulletLine({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: t.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumSurface extends StatelessWidget {
  final Widget child;

  const _PremiumSurface({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.13),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.065),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
}

String _money(int value) {
  return MoneyFormatter.formatCurrency(value);
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

String _healthDescription(FinanceHealth health) {
  switch (health) {
    case FinanceHealth.muitoSaudavel:
      return 'O clube trabalha com folga.';
    case FinanceHealth.saudavel:
      return 'A situação é boa.';
    case FinanceHealth.estavel:
      return 'O clube está funcional.';
    case FinanceHealth.pressionado:
      return 'A dívida começa a apertar.';
    case FinanceHealth.critico:
      return 'Vendas ganham relevância.';
    case FinanceHealth.colapsoFinanceiro:
      return 'Pouca margem para investir.';
  }
}

String _momentSummary({
  required FinanceHealth health,
  required int caixa,
  required int operacional,
  required int debt,
  required int totalFixedCost,
}) {
  final fixedCostText = _money(totalFixedCost);

  if (operacional < 0) {
    return 'O fluxo operacional está negativo. A reserva para salários e manutenção já não cobre as obrigações do clube. O custo fixo mensal é de $fixedCostText, então será necessário vender jogadores, reduzir gastos ou melhorar receitas.';
  }

  if (operacional < totalFixedCost) {
    return 'O fluxo operacional está curto. O clube ainda tem caixa livre de ${_money(caixa)}, mas a reserva destinada a salários e manutenção não cobre um mês completo de custos fixos ($fixedCostText).';
  }

  if (debt > (caixa + operacional) * 5) {
    return 'A dívida ainda domina a estrutura financeira. O clube tem ${_money(caixa)} em caixa livre e ${_money(operacional)} no fluxo operacional, mas a dívida de ${_money(debt)} reduz o repasse das grandes receitas.';
  }

  switch (health) {
    case FinanceHealth.muitoSaudavel:
    case FinanceHealth.saudavel:
      return 'O clube está bem organizado. Há ${_money(caixa)} em caixa livre para investimentos e ${_money(operacional)} reservados para operação. Com custo fixo mensal de $fixedCostText, existe margem para crescer.';
    case FinanceHealth.estavel:
      return 'O clube está funcional, mas precisa de disciplina. O caixa livre é de ${_money(caixa)}, o fluxo operacional é de ${_money(operacional)} e o custo fixo mensal é de $fixedCostText.';
    case FinanceHealth.pressionado:
      return 'A situação já pede controle. O clube tem ${_money(caixa)} para investir, mas precisa preservar o fluxo operacional de ${_money(operacional)}. A dívida de ${_money(debt)} pesa no repasse.';
    case FinanceHealth.critico:
      return 'A pressão financeira é forte. Mesmo com ${_money(caixa)} em caixa livre, o clube precisa proteger o fluxo operacional de ${_money(operacional)}.';
    case FinanceHealth.colapsoFinanceiro:
      return 'O clube está em colapso financeiro. A dívida de ${_money(debt)} trava o crescimento, reduz o repasse e limita decisões de mercado.';
  }
}
