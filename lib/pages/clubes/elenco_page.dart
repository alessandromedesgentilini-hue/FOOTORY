// lib/pages/clubes/elenco_page.dart
//
// Tela FINAL de Elenco / Base
// - Seleciona clube (persistido em SharedPreferences)
// - Busca por nome
// - Filtro por posição (GOL/DEF/MEI/ATA)
// - Ordenação (OVR, Valor, Idade, Nome - asc/desc)
// - Geração PRO e Base com escolha de tamanho (12/18/23 ou 10/12/15 U18)
// - Limpar Elenco / Limpar Base / Limpar Tudo
// - Exibe OVR por função (sum v2) mapeado 10..100 -> 40..95
// - Avatar com fallback (iniciais) se o asset falhar
//
// Dependências:
//  - shared_preferences
//  - intl (no modelo Jogador)
//  - services/ratings/service_rating_overall_sum_v2.dart
//
// Observações de robustez:
//  • Não depende de tipos específicos do GameState (usa dynamic seguro).
//  • Lê clubes via GameState.I.clubesPublicos() (espera {id, nome}).
//  • Tolera ausência de elencos/baseElencos e nivelDoClube().

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/jogador.dart';
import '../../models/pe_preferencial.dart'; // <- necessário para p.pe.label (extensão)
import '../../services/world/game_state.dart';
import '../../services/generator/player_gen.dart';
import '../../services/ratings/service_rating_overall_sum_v2.dart';
import 'jogador_detalhe_page.dart';

/// Chaves de persistência local
const _kPrefClubSlug = 'elenco:selected_slug';
const _kPrefSortKey = 'elenco:sort_key';
const _kPrefSortDesc = 'elenco:sort_desc';
const _kPrefFilterPos = 'elenco:filter_pos'; // '', GOL, DEF, MEI, ATA

enum _SortKey { ovr, valor, idade, nome }

/// Extensão nomeada (apenas membros de instância)
extension SortKeyX on _SortKey {
  String get label {
    switch (this) {
      case _SortKey.ovr:
        return 'OVR';
      case _SortKey.valor:
        return 'Valor';
      case _SortKey.idade:
        return 'Idade';
      case _SortKey.nome:
        return 'Nome';
    }
  }

  String get pref => toString().split('.').last;
}

/// Conversor a partir do valor salvo nas prefs
_SortKey _sortKeyFromPref(String? s) {
  switch (s) {
    case 'valor':
      return _SortKey.valor;
    case 'idade':
      return _SortKey.idade;
    case 'nome':
      return _SortKey.nome;
    case 'ovr':
    default:
      return _SortKey.ovr;
  }
}

class ElencoPage extends StatefulWidget {
  final String? titulo;
  const ElencoPage({super.key, this.titulo});

  @override
  State<ElencoPage> createState() => _ElencoPageState();
}

class _ElencoPageState extends State<ElencoPage> {
  // estado base
  String? _slug; // clube selecionado
  bool _busy = false;

  // lista de clubes carregada do GameState
  List<(String slug, String nome)> _clubes = const [];

  // geração/serviços
  late final PlayerGen _gen;

  // busca e filtros
  final TextEditingController _searchC = TextEditingController();
  String _filterPos = ''; // '', GOL, DEF, MEI, ATA
  _SortKey _sortKey = _SortKey.ovr;
  bool _sortDesc = true;

  // cache de listas exibidas
  List<Jogador> _viewPro = const [];
  List<Jogador> _viewBase = const [];

  // debounce para busca
  Timer? _deb;

  @override
  void initState() {
    super.initState();
    _gen = PlayerGen();
    _init();
    _searchC.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchC.removeListener(_onSearchChanged);
    _searchC.dispose();
    _deb?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() => _busy = true);

    // carrega prefs
    final prefs = await SharedPreferences.getInstance();

    // carrega clubes do GameState (Future) e converte para (slug, nome)
    try {
      final raw = await GameState.I.clubesPublicos();
      final clubes = <(String, String)>[];
      for (final c in raw) {
        try {
          final id = (c as dynamic).id as String?;
          final nome = (c as dynamic).nome as String?;
          if (id != null && nome != null) clubes.add((id, nome));
        } catch (_) {}
      }
      clubes.sort((a, b) => a.$2.compareTo(b.$2));
      _clubes = clubes;
    } catch (_) {
      _clubes = const [];
    }

    final clubes = _clubes;

    _slug = prefs.getString(_kPrefClubSlug);
    if (_slug == null && clubes.isNotEmpty) {
      _slug = clubes.first.$1;
    }
    _filterPos = prefs.getString(_kPrefFilterPos) ?? '';
    _sortKey = _sortKeyFromPref(prefs.getString(_kPrefSortKey));
    _sortDesc = prefs.getBool(_kPrefSortDesc) ?? true;

    _rebuildViews();

    setState(() => _busy = false);
  }

  void _onSearchChanged() {
    _deb?.cancel();
    _deb = Timer(const Duration(milliseconds: 200), () => _rebuildViews());
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    if (_slug != null) await prefs.setString(_kPrefClubSlug, _slug!);
    await prefs.setString(_kPrefFilterPos, _filterPos);
    await prefs.setString(_kPrefSortKey, _sortKey.pref);
    await prefs.setBool(_kPrefSortDesc, _sortDesc);
  }

  // ===== construção das listas exibidas =====

  void _rebuildViews() {
    final gs = GameState.I;
    final slug = _slug;

    List<Jogador> pro = const [];
    List<Jogador> base = const [];

    if (slug != null) {
      // tenta mapas diretos
      try {
        final elencos = (gs as dynamic).elencos;
        if (elencos is Map<String, List<Jogador>>) {
          pro = elencos[slug] ?? const <Jogador>[];
        }
      } catch (_) {}
      try {
        final baseElencos = (gs as dynamic).baseElencos;
        if (baseElencos is Map<String, List<Jogador>>) {
          base = baseElencos[slug] ?? const <Jogador>[];
        }
      } catch (_) {}

      // tenta métodos elencoDo/baseDo
      if (pro.isEmpty) {
        try {
          final res = (gs as dynamic).elencoDo(slug);
          if (res is List<Jogador>) pro = res;
        } catch (_) {}
      }
      if (base.isEmpty) {
        try {
          final res = (gs as dynamic).baseDo(slug);
          if (res is List<Jogador>) base = res;
        } catch (_) {}
      }
    }

    final q = _searchC.text.trim().toLowerCase();

    bool pass(Jogador j) {
      final hitsName = q.isEmpty || j.nome.toLowerCase().contains(q);
      final hitsPos = _filterPos.isEmpty || j.pos == _filterPos;
      return hitsName && hitsPos;
    }

    // aplica filtro
    pro = pro.where(pass).toList(growable: false);
    base = base.where(pass).toList(growable: false);

    // ordena
    int ovr(Jogador j) => _ovrFuncFromJogador(j);
    int cmp(Jogador a, Jogador b) {
      int c;
      switch (_sortKey) {
        case _SortKey.ovr:
          c = ovr(a).compareTo(ovr(b));
          break;
        case _SortKey.valor:
          c = a.valorMercado.compareTo(b.valorMercado);
          break;
        case _SortKey.idade:
          c = a.idade.compareTo(b.idade);
          break;
        case _SortKey.nome:
          c = a.nome
              .trim()
              .toLowerCase()
              .compareTo(b.nome.trim().toLowerCase());
          break;
      }
      return _sortDesc ? -c : c;
    }

    pro = [...pro]..sort(cmp);
    base = [...base]..sort(cmp);

    setState(() {
      _viewPro = pro;
      _viewBase = base;
    });
  }

  // ===== UI =====

  @override
  Widget build(BuildContext context) {
    final clubes = _clubes;
    final selecionado = _slug;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo ?? 'Elenco / Base'),
        actions: [
          // menu ações
          PopupMenuButton<String>(
            tooltip: 'Ações',
            onSelected: (value) {
              switch (value) {
                case 'limpar_pro':
                  _limpar(pro: true, base: false);
                  break;
                case 'limpar_base':
                  _limpar(pro: false, base: true);
                  break;
                case 'limpar_tudo':
                  _limpar(pro: true, base: true);
                  break;
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'limpar_pro',
                child: Text('Limpar Elenco (PRO)'),
              ),
              PopupMenuItem(
                value: 'limpar_base',
                child: Text('Limpar Base (U18)'),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'limpar_tudo',
                child: Text('Limpar Tudo'),
              ),
            ],
          ),
        ],
      ),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _toolbar(clubes, selecionado),
                  const SizedBox(height: 12),
                  _filters(),
                  const SizedBox(height: 12),
                  Expanded(child: _bodyList()),
                ],
              ),
            ),
      floatingActionButton: (_slug != null)
          ? _FabGroup(
              onGerarPro: _gerarPro,
              onGerarBase: _gerarBase,
            )
          : null,
    );
  }

  Widget _toolbar(
      List<(String slug, String nome)> clubes, String? selecionado) {
    return Column(
      children: [
        Row(
          children: [
            const Text('Clube:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButton<String>(
                isExpanded: true,
                value:
                    clubes.any((c) => c.$1 == selecionado) ? selecionado : null,
                items: clubes
                    .map((c) => DropdownMenuItem<String>(
                          value: c.$1,
                          child: Text(c.$2, overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (v) async {
                  setState(() => _slug = v);
                  await _persist();
                  _rebuildViews();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchC,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Buscar por nome…',
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: (_searchC.text.isEmpty)
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _searchC.clear(),
                    tooltip: 'Limpar busca',
                  ),
          ),
        ),
      ],
    );
  }

  Widget _filters() {
    return Row(
      children: [
        // filtro de posição
        Wrap(
          spacing: 6,
          children: [
            _choice('TODOS', '', isFirst: true),
            _choice('GOL', 'GOL'),
            _choice('DEF', 'DEF'),
            _choice('MEI', 'MEI'),
            _choice('ATA', 'ATA'),
          ],
        ),
        const Spacer(),
        // ordenação
        PopupMenuButton<_SortKey>(
          tooltip: 'Ordenar por…',
          initialValue: _sortKey,
          onSelected: (k) async {
            setState(() => _sortKey = k);
            await _persist();
            _rebuildViews();
          },
          itemBuilder: (_) => _SortKey.values
              .map((k) => PopupMenuItem(value: k, child: Text(k.label)))
              .toList(),
          child: const Row(
            children: [
              Icon(Icons.sort),
              SizedBox(width: 6),
              Text('Ordenar'),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          tooltip: _sortDesc ? 'Descendente' : 'Ascendente',
          onPressed: () async {
            setState(() => _sortDesc = !_sortDesc);
            await _persist();
            _rebuildViews();
          },
          icon: Icon(_sortDesc ? Icons.south : Icons.north),
        ),
      ],
    );
  }

  Widget _choice(String label, String value, {bool isFirst = false}) {
    final selected = _filterPos == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) async {
        setState(() => _filterPos = value);
        await _persist();
        _rebuildViews();
      },
      side: isFirst ? const BorderSide() : null,
    );
  }

  Widget _bodyList() {
    if (_viewPro.isEmpty && _viewBase.isEmpty) {
      return Center(
        child: Text(
          'Nenhum jogador.\nUse o botão flutuante para gerar PRO/Base.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    final children = <Widget>[];
    if (_viewPro.isNotEmpty) {
      children.add(const _SectionHeader('Elenco'));
      children
          .addAll(_viewPro.map((p) => _cardPlayer(context, p, isBase: false)));
      children.add(const SizedBox(height: 12));
    }
    if (_viewBase.isNotEmpty) {
      children.add(const _SectionHeader('Base (U18)'));
      children
          .addAll(_viewBase.map((p) => _cardPlayer(context, p, isBase: true)));
    }
    return ListView(children: children);
  }

  // ===== ações =====

  Future<void> _limpar({required bool pro, required bool base}) async {
    if (_slug == null) return;
    final slug = _slug!;
    final gs = GameState.I;

    setState(() => _busy = true);

    try {
      if (pro) {
        final el = (gs as dynamic).elencos;
        if (el is Map<String, List<Jogador>>) el.remove(slug);
      }
      if (base) {
        final be = (gs as dynamic).baseElencos;
        if (be is Map<String, List<Jogador>>) be.remove(slug);
      }
    } catch (_) {}

    setState(() => _busy = false);
    _rebuildViews();
  }

  Future<void> _gerarPro() async {
    if (_slug == null) return;
    final tamanho = await _pickTamanho('Gerar PRO');
    if (tamanho == null) return;

    setState(() => _busy = true);

    final slug = _slug!;
    double nivel = 3.0;
    try {
      final v = (GameState.I as dynamic).nivelDoClube(slug);
      if (v is num) nivel = v.toDouble();
    } catch (_) {}

    final views = _gen.gerarProf(tamanho, nivel: nivel, clubeId: slug);
    final listPro = views.map(_gen.toJogadorFromView).toList(growable: false)
      ..sort(
          (a, b) => _ovrFuncFromJogador(b).compareTo(_ovrFuncFromJogador(a)));

    try {
      final el = (GameState.I as dynamic).elencos;
      if (el is Map<String, List<Jogador>>) {
        el[slug] = listPro;
      }
    } catch (_) {}

    setState(() => _busy = false);
    _rebuildViews();
  }

  Future<void> _gerarBase() async {
    if (_slug == null) return;
    final tamanho = await _pickTamanho('Gerar Base', base: true);
    if (tamanho == null) return;

    setState(() => _busy = true);

    final slug = _slug!;
    double nivel = 3.0;
    try {
      final v = (GameState.I as dynamic).nivelDoClube(slug);
      if (v is num) nivel = v.toDouble();
    } catch (_) {}

    final views = _gen.gerarBase(clubeId: slug, nivel: nivel, n: tamanho);
    final listBase = views.map(_gen.toJogadorFromView).toList(growable: false)
      ..sort(
          (a, b) => _ovrFuncFromJogador(b).compareTo(_ovrFuncFromJogador(a)));

    try {
      final be = (GameState.I as dynamic).baseElencos;
      if (be is Map<String, List<Jogador>>) {
        be[slug] = listBase;
      }
    } catch (_) {}

    setState(() => _busy = false);
    _rebuildViews();
  }

  Future<int?> _pickTamanho(String title, {bool base = false}) async {
    final options = base ? const [10, 12, 15] : const [12, 18, 23];
    return showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Text(title, style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final n in options)
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(n),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Text('$n jogadores'),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ===== OVR helpers =====

  // mapeia linearmente 10..100 -> 40..95 (para casar com precificação/salário)
  int _mapRange(int v,
      {int inMin = 10, int inMax = 100, int outMin = 40, int outMax = 95}) {
    final cl = v.clamp(inMin, inMax);
    final n = (cl - inMin) / (inMax - inMin);
    return (outMin + n * (outMax - outMin)).round();
  }

  // calcula o OVR por função a partir do Jogador salvo (pilares → micros → soma 10)
  int _ovrFuncFromJogador(Jogador p) {
    final micros = microsFromPillars(
        p.ofensivo, p.defensivo, p.tecnico, p.mental, p.fisico);
    final func = funcaoFromPos(p.pos); // GOL/DEF/MEI/ATA
    final raw = sumForRole(func, micros); // 10..100
    return _mapRange(raw); // 40..95
  }

  // ===== UI cards =====

  Widget _cardPlayer(BuildContext context, Jogador p, {required bool isBase}) {
    final ovrDisplay = _ovrFuncFromJogador(p);

    return Card(
      color: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => JogadorDetalhePage(jogador: p)),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: _Ui.avatar(p),
        title: Row(
          children: [
            Expanded(
              child: Text(
                p.nome,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            if (isBase) _Ui.tag('U18', color: Colors.teal),
          ],
        ),
        subtitle: Text(
          '${p.pos} • ${p.pe.label} • ${p.idade} anos',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(p.valorFormatado,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            _Ui.ovrPill(ovrDisplay),
          ],
        ),
      ),
    );
  }
}

// ===== widgets utilitários =====

class _SectionHeader extends StatelessWidget {
  final String t;
  const _SectionHeader(this.t);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
      child: Text(t,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
    );
  }
}

class _FabGroup extends StatelessWidget {
  final VoidCallback onGerarPro;
  final VoidCallback onGerarBase;
  const _FabGroup({required this.onGerarPro, required this.onGerarBase});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.extended(
          heroTag: 'fab_pro',
          onPressed: onGerarPro,
          icon: const Icon(Icons.groups_2),
          label: const Text('Gerar PRO'),
        ),
        const SizedBox(height: 10),
        FloatingActionButton.extended(
          heroTag: 'fab_base',
          onPressed: onGerarBase,
          icon: const Icon(Icons.school),
          label: const Text('Gerar Base'),
        ),
      ],
    );
  }
}

class _Ui {
  static Widget avatar(Jogador p) {
    // se houver asset, tenta usar; se falhar, cai no círculo com iniciais
    if (p.facePath.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          p.facePath,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => CircleAvatar(
            radius: 28,
            child: Text(p.iniciais),
          ),
        ),
      );
    }
    return CircleAvatar(radius: 28, child: Text(p.iniciais));
  }

  static Widget tag(String text, {required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 10)),
    );
  }

  static Widget ovrPill(int ovr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.blueGrey.withOpacity(0.35)),
      ),
      child: Text('OVR $ovr', style: const TextStyle(fontSize: 11)),
    );
  }
}
