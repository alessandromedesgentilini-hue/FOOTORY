// lib/dev/quick_base_demo.dart
import 'dart:async';
import 'package:flutter/material.dart';

import '../services/generator/jogador_generator.dart';
import '../models/jogador.dart';

/// Demo rápida para gerar e listar jogadores de base (Caminho B).
/// - Ordena por OVR cheio (10..100): soma dos 10 atributos da função
/// - Mostra estrelas (1..10 em .5) + OVR cheio
/// - Tolera diferenças de API do JogadorGenerator (assinaturas distintas)
class QuickBaseDemo extends StatefulWidget {
  /// Mantido por compatibilidade com versões antigas (1..5).
  final double mediaClube;

  const QuickBaseDemo({super.key, required this.mediaClube});

  @override
  State<QuickBaseDemo> createState() => _QuickBaseDemoState();
}

class _QuickBaseDemoState extends State<QuickBaseDemo>
    with AutomaticKeepAliveClientMixin<QuickBaseDemo> {
  @override
  bool get wantKeepAlive => true;

  int _qtde = 10;
  int _seed = 123;
  String _nac = 'BRA';
  bool _ordemPorOvr = true;

  List<Jogador> _base = const [];
  bool _loading = true;
  String? _erro;

  JogadorGenerator? _gen;

  final TextEditingController _q = TextEditingController();
  Timer? _deb;

  @override
  void initState() {
    super.initState();
    _recreateGen();
    _run();
  }

  @override
  void dispose() {
    _deb?.cancel();
    _q.dispose();
    super.dispose();
  }

  void _recreateGen() {
    try {
      _gen = JogadorGenerator(seed: _seed);
    } catch (_) {
      // ignore: avoid_print
      print(
          '[quick_base_demo][WARN] JogadorGenerator(seed) indisponível; tentando construtor vazio.');
      try {
        // ignore: avoid_dynamic_calls
        _gen = (JogadorGenerator as dynamic).call();
      } catch (e) {
        _erro = 'Não foi possível instanciar JogadorGenerator.\nDetalhes: $e';
      }
    }
  }

  Future<void> _run() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _erro = null;
    });

    try {
      final lot = _gerarLoteCompat(
        gen: _gen,
        qtde: _qtde,
        nacionalidade: _nac,
        mediaClube: widget.mediaClube,
      );

      List<Jogador> out = List.of(lot);
      out.sort((a, b) => _ordemPorOvr
          ? b.ovrCheio.compareTo(a.ovrCheio)
          : a.nome.compareTo(b.nome));

      if (!mounted) return;
      setState(() {
        _base = out;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _base = const [];
        _loading = false;
        _erro = 'Falha ao gerar jogadores de base.\nDetalhes: $e';
      });
    }
  }

  /// Compatibilidade entre branches.
  ///
  /// Preferência (Caminho B):
  /// 1) gerarLote(qtde, nacionalidade: 'BRA', isBase: true)
  /// 2) gerarLote(qtde, nacionalidade: 'BRA')
  /// 3) gerarLote(qtde)
  /// 4) gerar(qtde, ...) (fallback)
  List<Jogador> _gerarLoteCompat({
    required JogadorGenerator? gen,
    required int qtde,
    required String nacionalidade,
    required double mediaClube,
  }) {
    if (gen == null) throw StateError('Generator não inicializado.');

    // 1) Caminho B: gerarLote com isBase
    try {
      // ignore: avoid_dynamic_calls
      final res = (gen as dynamic).gerarLote(
        qtde,
        nacionalidade: nacionalidade,
        isBase: true,
      );
      if (res is List<Jogador>) return res;
      if (res is List) return res.cast<Jogador>();
    } catch (_) {}

    // 2) gerarLote com nacionalidade
    try {
      // ignore: avoid_dynamic_calls
      final res = (gen as dynamic).gerarLote(
        qtde,
        nacionalidade: nacionalidade,
      );
      if (res is List<Jogador>) return res;
      if (res is List) return res.cast<Jogador>();
    } catch (_) {}

    // 3) gerarLote só qtde
    try {
      // ignore: avoid_dynamic_calls
      final res = (gen as dynamic).gerarLote(qtde);
      if (res is List<Jogador>) return res;
      if (res is List) return res.cast<Jogador>();
    } catch (_) {}

    // 4) fallback antigo "mediaClube"
    try {
      // ignore: avoid_dynamic_calls
      final res = (gen as dynamic).gerarLote(
        qtde,
        nacionalidade: nacionalidade,
        mediaClube: mediaClube,
      );
      if (res is List) return res.cast<Jogador>();
    } catch (_) {}

    // 5) método alternativo "gerar"
    try {
      // ignore: avoid_dynamic_calls
      final res = (gen as dynamic).gerar(
        qtde,
        nacionalidade: nacionalidade,
        mediaClube: mediaClube,
      );
      if (res is List) return res.cast<Jogador>();
    } catch (e) {
      throw StateError('APIs gerar/gerarLote indisponíveis.\n$e');
    }

    throw StateError('Gerador não retornou lista válida.');
  }

  List<Jogador> get _filtered {
    final q = _q.text.trim().toLowerCase();
    if (q.isEmpty) return _base;
    return _base.where((p) {
      final nome = p.nome.toLowerCase();
      final pos = p.pos.toLowerCase();
      final pe = _peLabelSafe(p).toLowerCase();
      return nome.contains(q) || pos.contains(q) || pe.contains(q);
    }).toList();
  }

  String _peLabelSafe(Jogador p) {
    // não depende de extensão label (evita quebra entre branches)
    try {
      final v = (p as dynamic).peLabel;
      if (v is String && v.isNotEmpty) return v;
    } catch (_) {}
    try {
      final pe = (p as dynamic).pe;
      final s = pe.toString();
      if (s.contains('.')) return s.split('.').last.toUpperCase();
      return s.toUpperCase();
    } catch (_) {}
    return '-';
  }

  Future<void> _onRefresh() async {
    await _run();
  }

  void _onQueryChanged(String v) {
    _deb?.cancel();
    _deb = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : _erro != null
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  _erro!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              )
            : _list();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Base — Demo'),
        actions: [
          IconButton(
            tooltip: 'Gerar novamente',
            onPressed: () {
              setState(() => _loading = true);
              _run();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _toolbar(context),
            const Divider(height: 1),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          SizedBox(
            width: 260,
            child: TextField(
              controller: _q,
              onChanged: _onQueryChanged,
              decoration: const InputDecoration(
                isDense: true,
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar por nome/posição/pé…',
              ),
            ),
          ),
          DropdownButton<String>(
            value: _nac,
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                _nac = v;
                _loading = true;
              });
              _run();
            },
            items: const [
              DropdownMenuItem(value: 'BRA', child: Text('BRA')),
              DropdownMenuItem(value: 'ARG', child: Text('ARG')),
              DropdownMenuItem(value: 'ITA', child: Text('ITA')),
              DropdownMenuItem(value: 'URU', child: Text('URU')),
              DropdownMenuItem(value: 'ESP', child: Text('ESP')),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Qtd'),
              const SizedBox(width: 6),
              SizedBox(
                width: 72,
                child: TextFormField(
                  initialValue: _qtde.toString(),
                  decoration: const InputDecoration(isDense: true),
                  keyboardType: TextInputType.number,
                  onFieldSubmitted: (v) {
                    final n = int.tryParse(v);
                    if (n == null || n < 1) return;
                    setState(() {
                      _qtde = n.clamp(1, 50);
                      _loading = true;
                    });
                    _run();
                  },
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Seed'),
              const SizedBox(width: 6),
              SizedBox(
                width: 96,
                child: TextFormField(
                  initialValue: _seed.toString(),
                  decoration: const InputDecoration(isDense: true),
                  keyboardType: TextInputType.number,
                  onFieldSubmitted: (v) {
                    final n = int.tryParse(v);
                    if (n == null) return;
                    setState(() {
                      _seed = n;
                      _recreateGen();
                      _loading = true;
                    });
                    _run();
                  },
                ),
              ),
            ],
          ),
          FilterChip(
            label: Text(_ordemPorOvr ? 'Ordenar por OVR' : 'Ordenar por Nome'),
            selected: _ordemPorOvr,
            onSelected: (v) {
              setState(() {
                _ordemPorOvr = v;
                _base = List.of(_base)
                  ..sort((a, b) => _ordemPorOvr
                      ? b.ovrCheio.compareTo(a.ovrCheio)
                      : a.nome.compareTo(b.nome));
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _list() {
    final data = _filtered;
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum jogador encontrado com os filtros atuais.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: data.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (c, i) {
        final p = data[i];

        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              p.facePath,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              cacheWidth: 128,
              errorBuilder: (_, __, ___) => CircleAvatar(
                radius: 26,
                backgroundColor: Colors.blueGrey.shade700,
                child: Text(p.iniciais),
              ),
            ),
          ),
          title: Text(p.nome, overflow: TextOverflow.ellipsis),
          subtitle: Text('${p.pos} • ${_peLabelSafe(p)} • ${p.idade} anos'),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('OVR ${p.ovrCheio}',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              Text('${p.estrelas.toStringAsFixed(1)} ★',
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
          onTap: () => _showDetails(context, p),
        );
      },
    );
  }

  void _showDetails(BuildContext context, Jogador p) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  p.facePath,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  cacheWidth: 160,
                  errorBuilder: (_, __, ___) => CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.blueGrey.shade700,
                    child: Text(p.iniciais),
                  ),
                ),
              ),
              title: Text(p.nome, overflow: TextOverflow.ellipsis),
              subtitle: Text('${p.pos} • ${_peLabelSafe(p)} • ${p.idade} anos'),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('OVR ${p.ovrCheio}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text('${p.estrelas.toStringAsFixed(1)} ★',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() => _loading = true);
                      _run();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Gerar novamente'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
