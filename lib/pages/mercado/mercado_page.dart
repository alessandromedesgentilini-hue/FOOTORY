// lib/pages/mercado/mercado_page.dart
//
// Mercado MVP (UI) — PLUGADO no GameState atual.
// 4 abas: Comprar, Empréstimo, Livres, Venda/Lista.
//
// ✅ Recebe ClubeState (padrão do projeto):
// MercadoPage(clube: cs)
//
// ✅ COMPAT:
// Seu GameState pode estar em versão antiga.
// Então aqui a UI tenta chamar métodos novos (contratarTransferenciaDaLista / etc)
// e, se não existir, cai no contratarDoMercado.

import 'package:flutter/material.dart';

import '../../domain/models/clube_state.dart';
import '../../models/jogador.dart';
import '../../services/world/game_state.dart';

class MercadoPage extends StatefulWidget {
  final ClubeState clube;

  const MercadoPage({
    super.key,
    required this.clube,
  });

  @override
  State<MercadoPage> createState() => _MercadoPageState();
}

class _MercadoPageState extends State<MercadoPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nomeClube = widget.clube.nome;
    final gs = GameState.I;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mercado • $nomeClube'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Comprar'),
            Tab(text: 'Empréstimo'),
            Tab(text: 'Livres'),
            Tab(text: 'Venda/Lista'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _ComprarTab(
            clube: widget.clube,
            onChanged: () => setState(() {}),
          ),
          _EmprestimoTab(
            clube: widget.clube,
            onChanged: () => setState(() {}),
          ),
          _LivresTab(
            clube: widget.clube,
            onChanged: () => setState(() {}),
          ),
          _VendaListaTab(
            clube: widget.clube,
            onChanged: () => setState(() {}),
          ),
        ],
      ),
      bottomNavigationBar: _MercadoFooter(clube: widget.clube, gs: gs),
    );
  }
}

class _MercadoFooter extends StatelessWidget {
  final ClubeState clube;
  final GameState gs;

  const _MercadoFooter({
    required this.clube,
    required this.gs,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final janelaStr = switch (gs.janelaAtual) {
      MarketWindow.jan => 'JAN (aberta)',
      MarketWindow.jul => 'JUL (aberta)',
      MarketWindow.fora => 'Fora da janela',
    };

    final caixa = clube.financeiro.caixa;
    final divida = clube.financeiro.divida;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withOpacity(0.35)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Janela: $janelaStr • Scout N${gs.scoutNivel} • Fin N${gs.nivelFinanceiro}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Caixa: ${_money(caixa)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: (caixa <= 0) ? cs.error : null,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Dívida: ${_money(divida)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: (divida > 0) ? cs.error : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComprarTab extends StatelessWidget {
  final ClubeState clube;
  final VoidCallback onChanged;

  const _ComprarTab({
    required this.clube,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final gs = GameState.I;
    final cs = Theme.of(context).colorScheme;

    final lista = gs.alvosTransferencia;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _HeaderCard(
          title: 'Comprar (Transferência)',
          subtitle: gs.podeNegociarTransferenciasAgora
              ? 'Lista curada desta janela (fixa até a próxima janela).'
              : 'Fora da janela: você pode ver a lista, mas não fecha transferência agora.',
        ),
        const SizedBox(height: 10),
        if (lista.isEmpty)
          const _EmptyCard(
            text: 'Sem alvos de transferência no momento.\n'
                'Quando abrir JAN/JUL, a lista é gerada automaticamente.',
          )
        else
          ...lista.map((j) {
            final motivo = gs.scoutMotivoPorJogadorId[j.id] ?? 'Sem relatório.';
            final resumo = gs.scoutResumoPorJogadorId[j.id];

            return _PlayerCard(
              jogador: j,
              motivo: motivo,
              resumo: resumo,
              trailing: _ActionButton(
                label: 'Negociar',
                enabled: gs.podeNegociarTransferenciasAgora,
                onPressed: () async {
                  final ok = await _confirmarContrato(
                    context,
                    j,
                    tipo: 'Transferência',
                    anosDefault: j.anosContrato,
                  );
                  if (!ok) return;

                  final anos = await _pickAnosContrato(
                    context,
                    initial: j.anosContrato,
                  );
                  if (anos == null) return;

                  final fechado = _tryContratarTransferencia(gs, j, anos);

                  if (!context.mounted) return;

                  if (!fechado) {
                    _snack(
                      context,
                      'Não foi possível fechar agora (janela fechada ou jogador indisponível).',
                      error: true,
                    );
                    return;
                  }

                  _purgeMarketLists(gs, j.id);

                  _snack(context,
                      'Transferência fechada: ${j.nome} ($anos ano(s)).');
                  onChanged();
                },
                disabledHint: 'Janela fechada',
              ),
              footer: Container(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Valor (base): ${_money(j.valorMercado.toDouble())} • Contrato sugerido: ${j.anosContrato} ano(s)',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
            );
          }),
        const SizedBox(height: 12),
        const _NoteCard(
          text:
              'Nota: o valor final aplica desconto do Dept. Futebol e pode virar dívida se faltar caixa.\n'
              'Essa tela está pronta pra receber “proposta/contra-proposta” depois.',
        ),
      ],
    );
  }
}

class _EmprestimoTab extends StatelessWidget {
  final ClubeState clube;
  final VoidCallback onChanged;

  const _EmprestimoTab({
    required this.clube,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final gs = GameState.I;
    final cs = Theme.of(context).colorScheme;

    final lista = gs.alvosEmprestimo;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _HeaderCard(
          title: 'Empréstimo',
          subtitle: gs.podeNegociarTransferenciasAgora
              ? 'Lista curada desta janela (fixa até a próxima janela).'
              : 'Fora da janela: você pode ver a lista, mas não fecha empréstimo agora.',
        ),
        const SizedBox(height: 10),
        if (lista.isEmpty)
          const _EmptyCard(
            text: 'Sem alvos de empréstimo no momento.\n'
                'Quando abrir JAN/JUL, a lista é gerada automaticamente.',
          )
        else
          ...lista.map((j) {
            final motivo = gs.scoutMotivoPorJogadorId[j.id] ?? 'Sem relatório.';
            final resumo = gs.scoutResumoPorJogadorId[j.id];

            return _PlayerCard(
              jogador: j,
              motivo: motivo,
              resumo: resumo,
              trailing: _ActionButton(
                label: 'Pegar emprestado',
                enabled: gs.podeNegociarTransferenciasAgora,
                onPressed: () async {
                  final ok = await _confirmarContrato(
                    context,
                    j,
                    tipo: 'Empréstimo',
                    anosDefault: 1,
                  );
                  if (!ok) return;

                  final fechado = _tryContratarEmprestimo(gs, j);

                  if (!context.mounted) return;

                  if (!fechado) {
                    _snack(
                      context,
                      'Não foi possível fechar agora (janela fechada ou jogador indisponível).',
                      error: true,
                    );
                    return;
                  }

                  _purgeMarketLists(gs, j.id);

                  _snack(context, 'Empréstimo fechado: ${j.nome} (1 ano).');
                  onChanged();
                },
                disabledHint: 'Janela fechada',
              ),
              footer: Container(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Custo (MVP): usa a mesma regra de “comprar” por enquanto • Contrato: 1 ano',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
            );
          }),
        const SizedBox(height: 12),
        const _NoteCard(
          text:
              'Nota: no MVP o empréstimo ainda usa a mesma regra de “comprar”.\n'
              'Depois a gente coloca taxa (10%), divisão de salário e opção de compra.',
        ),
      ],
    );
  }
}

class _LivresTab extends StatelessWidget {
  final ClubeState clube;
  final VoidCallback onChanged;

  const _LivresTab({
    required this.clube,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final gs = GameState.I;
    final cs = Theme.of(context).colorScheme;

    final lista = gs.alvosFreeAgent;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const _HeaderCard(
          title: 'Jogadores Livres',
          subtitle:
              'Free Agents ficam disponíveis o ano todo (a lista pode ser regenerada mensalmente).',
        ),
        const SizedBox(height: 10),
        if (lista.isEmpty)
          const _EmptyCard(
            text: 'Sem free agents visíveis.\n'
                'O GameState gera a lista automaticamente conforme o mês.',
          )
        else
          ...lista.map((j) {
            final motivo = gs.scoutMotivoPorJogadorId[j.id] ?? 'Sem relatório.';
            final resumo = gs.scoutResumoPorJogadorId[j.id];

            return _PlayerCard(
              jogador: j,
              motivo: motivo,
              resumo: resumo,
              trailing: _ActionButton(
                label: 'Contratar',
                enabled: true,
                onPressed: () async {
                  final ok = await _confirmarContrato(
                    context,
                    j,
                    tipo: 'Free Agent',
                    anosDefault: j.anosContrato,
                  );
                  if (!ok) return;

                  final anos = await _pickAnosContrato(
                    context,
                    initial: j.anosContrato,
                  );
                  if (anos == null) return;

                  final fechado = _tryContratarFreeAgent(gs, j, anos);

                  if (!context.mounted) return;

                  if (!fechado) {
                    _snack(
                      context,
                      'Não foi possível contratar (indisponível).',
                      error: true,
                    );
                    return;
                  }

                  _purgeMarketLists(gs, j.id);

                  _snack(context,
                      'Free Agent contratado: ${j.nome} ($anos ano(s)).');
                  onChanged();
                },
              ),
              footer: Container(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Valor (base): ${_money(j.valorMercado.toDouble())}',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
            );
          }),
        const SizedBox(height: 12),
        const _NoteCard(
          text:
              'Se o seu GameState tiver regra especial de Free Agent (luvas/nível financeiro), ela vai rodar automaticamente.\n'
              'Se não tiver, cai no contratarDoMercado (compat).',
        ),
      ],
    );
  }
}

class _VendaListaTab extends StatelessWidget {
  final ClubeState clube;
  final VoidCallback onChanged;

  const _VendaListaTab({
    required this.clube,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final gs = GameState.I;
    final cs = Theme.of(context).colorScheme;

    final elenco = gs.elencos;
    final base = gs.baseElencos;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const _HeaderCard(
          title: 'Venda / Lista',
          subtitle:
              'MVP: aqui a gente só lista o elenco/base. Próximo passo: botões “Listar à venda” / “Listar p/ empréstimo”.',
        ),
        const SizedBox(height: 10),
        if (elenco.isEmpty && base.isEmpty)
          const _EmptyCard(
            text:
                'Sem jogadores carregados agora. (Se o ClubSquadService estiver ok, isso não deveria acontecer.)',
          )
        else ...[
          _SectionTitle('Elenco profissional (${elenco.length})'),
          const SizedBox(height: 6),
          ...elenco.map((j) => _SquadRow(jogador: j)),
          const SizedBox(height: 12),
          _SectionTitle('Base (${base.length})'),
          const SizedBox(height: 6),
          ...base.map((j) => _SquadRow(jogador: j)),
        ],
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
          ),
          child: const Text(
            'Ideias MVP pra essa aba:\n'
            '• Botão “Listar à venda” (-30%)\n'
            '• Botão “Listar para empréstimo”\n'
            '• “Propostas” entram na Caixa de Entrada\n'
            '• Em crise, diretoria pode forçar venda\n',
            style: TextStyle(height: 1.25),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
    );
  }
}

class _SquadRow extends StatelessWidget {
  final Jogador jogador;
  const _SquadRow({required this.jogador});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pos = jogador.posDet.isNotEmpty ? jogador.posDet : jogador.pos;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                jogador.nome,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              '$pos • ${jogador.idade}a',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// Widgets / helpers
// =======================================================

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeaderCard({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(height: 1.25, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;

  const _EmptyCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(height: 1.25, color: cs.onSurfaceVariant),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String text;
  const _NoteCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(height: 1.25, color: cs.onSurfaceVariant),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final Jogador jogador;
  final String motivo;
  final ScoutResumo? resumo;
  final Widget trailing;
  final Widget? footer;

  const _PlayerCard({
    required this.jogador,
    required this.motivo,
    required this.resumo,
    required this.trailing,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final pos = jogador.posDet.isNotEmpty ? jogador.posDet : jogador.pos;
    final idade = jogador.idade;

    final scoutLine = (resumo == null)
        ? 'Scout: —'
        : 'Scout • OFE ${resumo!.ofe}  DEF ${resumo!.def}  TEC ${resumo!.tec}  FIS ${resumo!.fis}  MEN ${resumo!.men}';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    jogador.nome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                trailing,
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '$pos • $idade anos',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              scoutLine,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              motivo,
              style: const TextStyle(height: 1.25),
            ),
            if (footer != null) footer!,
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onPressed;
  final String? disabledHint;

  const _ActionButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
    this.disabledHint,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return Tooltip(
        message: disabledHint ?? 'Indisponível',
        child: FilledButton(
          onPressed: null,
          child: Text(label),
        ),
      );
    }

    return FilledButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

// =======================================================
// COMPAT: chamadas seguras pro GameState (evita erro de compile)
// =======================================================

bool _tryContratarTransferencia(GameState gs, Jogador j, int anos) {
  final dyn = gs as dynamic;
  try {
    final r = dyn.contratarTransferenciaDaLista(j, anosContrato: anos);
    if (r is bool) return r;
  } catch (_) {}

  try {
    final r = dyn.contratarDoMercado(j, anosContrato: anos);
    if (r is bool) return r;
  } catch (_) {}

  return false;
}

bool _tryContratarEmprestimo(GameState gs, Jogador j) {
  final dyn = gs as dynamic;
  try {
    final r = dyn.contratarEmprestimoDaLista(j);
    if (r is bool) return r;
  } catch (_) {}

  try {
    final r = dyn.contratarDoMercado(j, anosContrato: 1);
    if (r is bool) return r;
  } catch (_) {}

  return false;
}

bool _tryContratarFreeAgent(GameState gs, Jogador j, int anos) {
  final dyn = gs as dynamic;
  try {
    final r = dyn.contratarFreeAgent(j, anosContrato: anos);
    if (r is bool) return r;
  } catch (_) {}

  try {
    final r = dyn.contratarDoMercado(j, anosContrato: anos);
    if (r is bool) return r;
  } catch (_) {}

  return false;
}

// =======================================================
// Mercado: purge helpers
// =======================================================

void _purgeScout(GameState gs, String jogadorId) {
  gs.scoutMotivoPorJogadorId.remove(jogadorId);
  gs.scoutResumoPorJogadorId.remove(jogadorId);
}

void _purgeMarketLists(GameState gs, String jogadorId) {
  gs.alvosTransferencia.removeWhere((j) => j.id == jogadorId);
  gs.alvosEmprestimo.removeWhere((j) => j.id == jogadorId);
  gs.alvosFreeAgent.removeWhere((j) => j.id == jogadorId);
  _purgeScout(gs, jogadorId);
}

// =======================================================
// UI helpers
// =======================================================

void _snack(BuildContext context, String msg, {bool error = false}) {
  final cs = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: error ? cs.error : null,
    ),
  );
}

String _money(double v) {
  // formatação simples: R$ 1.234.567
  final n = v.isNaN ? 0 : v;
  final i = n.round();
  final s = i.abs().toString();
  final buf = StringBuffer();
  for (var k = 0; k < s.length; k++) {
    final idx = s.length - 1 - k;
    buf.write(s[idx]);
    if ((k + 1) % 3 == 0 && (k + 1) != s.length) {
      buf.write('.');
    }
  }
  final rev = buf.toString().split('').reversed.join();
  final sign = i < 0 ? '-' : '';
  return '${sign}R\$ $rev';
}

Future<bool> _confirmarContrato(
  BuildContext context,
  Jogador j, {
  required String tipo,
  required int anosDefault,
}) async {
  final pos = j.posDet.isNotEmpty ? j.posDet : j.pos;
  final val = _money(j.valorMercado.toDouble());

  final res = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Confirmar: $tipo'),
      content: Text(
        '${j.nome} • $pos\n'
        'Valor base: $val\n'
        'Contrato sugerido: $anosDefault ano(s)\n\n'
        'Deseja continuar?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Continuar'),
        ),
      ],
    ),
  );

  return res ?? false;
}

Future<int?> _pickAnosContrato(BuildContext context,
    {required int initial}) async {
  int value = initial.clamp(1, 5);

  final res = await showDialog<int>(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Escolher contrato'),
        content: Row(
          children: [
            const Text('Anos: '),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: value,
              items: const [
                DropdownMenuItem(value: 1, child: Text('1')),
                DropdownMenuItem(value: 2, child: Text('2')),
                DropdownMenuItem(value: 3, child: Text('3')),
                DropdownMenuItem(value: 4, child: Text('4')),
                DropdownMenuItem(value: 5, child: Text('5')),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => value = v);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, value),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    ),
  );

  return res;
}
