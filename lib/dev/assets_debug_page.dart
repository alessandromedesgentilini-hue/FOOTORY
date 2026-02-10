// lib/pages/dev/assets_debug_page.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show rootBundle, Clipboard, ClipboardData;

/// Página dev para inspecionar rapidamente os retratos locais (rostos)
/// - Lê o AssetManifest.json e filtra apenas assets/rostos/ e assets/rostos_base/
/// - Busca com debounce, cópia de caminhos, zoom/preview e grid ajustável
/// - Mantém estado ao trocar de abas (AutomaticKeepAliveClientMixin)
class AssetsDebugPage extends StatefulWidget {
  const AssetsDebugPage({super.key});

  @override
  State<AssetsDebugPage> createState() => _AssetsDebugPageState();
}

class _AssetsDebugPageState extends State<AssetsDebugPage>
    with AutomaticKeepAliveClientMixin<AssetsDebugPage> {
  // Dados
  List<String> _all = <String>[];
  bool _loading = true;
  String? _erro;

  // Filtros
  bool _showRostos = true;
  bool _showRostosBase = true;
  String _query = '';
  final TextEditingController _queryController = TextEditingController();
  Timer? _qDebounce;

  // UI
  int _cols = 4; // grade padrão
  bool _showNames = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _qDebounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _erro = null;
    });

    try {
      // Lê o manifesto (gera a lista final de assets após o pubspec)
      // Estrutura esperada: Map<String, dynamic> { "caminho/asset": [variantes...] }
      final raw = await rootBundle.loadString('AssetManifest.json');
      final decoded = json.decode(raw);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('AssetManifest.json não é um mapa válido.');
      }

      // Coleta apenas os caminhos principais (chaves do manifest)
      final keys = decoded.keys
          .where((k) =>
              k is String &&
              (k.startsWith('assets/rostos/') ||
                  k.startsWith('assets/rostos_base/')))
          .cast<String>()
          .toList()
        ..sort();

      if (!mounted) return;
      setState(() {
        _all = keys;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _all = const <String>[];
        _loading = false;
        _erro = 'Manifesto de assets não encontrado ou inválido.\n'
            '• Confirme o pubspec.yaml (assets: - assets/rostos/, - assets/rostos_base/)\n'
            '• Rode: flutter clean && flutter pub get\n'
            '• Garanta que os arquivos realmente existem na pasta\n\n'
            'Detalhes: $e';
      });
    }
  }

  List<String> get _filtered {
    Iterable<String> x = _all;

    if (!_showRostos) {
      x = x.where((p) => !p.startsWith('assets/rostos/'));
    }
    if (!_showRostosBase) {
      x = x.where((p) => !p.startsWith('assets/rostos_base/'));
    }

    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      x = x.where((p) => p.toLowerCase().contains(q));
    }

    return x.toList();
  }

  bool get _hasDefault => _all.contains('assets/rostos/_default.png');

  void _onQueryChanged(String v) {
    // Debounce leve para evitar rebuilds a cada tecla em listas grandes
    _qDebounce?.cancel();
    _qDebounce = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      setState(() {
        _query = v;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final imgs = _filtered;

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
            : Column(
                children: [
                  if (!_hasDefault)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: const Text(
                        'Atenção: não encontrei assets/rostos/_default.png\n'
                        'Sem esse placeholder, a UI cai no avatar com iniciais.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _queryController,
                            decoration: const InputDecoration(
                              isDense: true,
                              prefixIcon: Icon(Icons.search),
                              hintText: 'Buscar por nome/arquivo…',
                            ),
                            onChanged: _onQueryChanged,
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilterChip(
                          label: const Text('rostos/'),
                          selected: _showRostos,
                          onSelected: (v) => setState(() => _showRostos = v),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('rostos_base/'),
                          selected: _showRostosBase,
                          onSelected: (v) =>
                              setState(() => _showRostosBase = v),
                        ),
                        const SizedBox(width: 12),
                        Tooltip(
                          message: 'Mostrar/ocultar nomes dos arquivos',
                          child: IconButton(
                            onPressed: () =>
                                setState(() => _showNames = !_showNames),
                            icon: Icon(
                              _showNames
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        Tooltip(
                          message: 'Menor grade',
                          child: IconButton(
                            onPressed: _cols > 2
                                ? () => setState(() => _cols--)
                                : null,
                            icon: const Icon(Icons.zoom_out_map),
                          ),
                        ),
                        Tooltip(
                          message: 'Maior grade',
                          child: IconButton(
                            onPressed: _cols < 10
                                ? () => setState(() => _cols++)
                                : null,
                            icon: const Icon(Icons.zoom_in_map),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Encontradas: ${imgs.length} (total: ${_all.length})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: imgs.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhuma imagem encontrada com os filtros atuais.',
                              textAlign: TextAlign.center,
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: _cols,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: imgs.length,
                            itemBuilder: (_, i) {
                              final path = imgs[i];
                              final name = path.split('/').last;
                              return InkWell(
                                onTap: () => _preview(context, path),
                                onLongPress: () {
                                  Clipboard.setData(ClipboardData(text: path));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Copiado: $path'),
                                      duration:
                                          const Duration(milliseconds: 1500),
                                    ),
                                  );
                                },
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Semantics(
                                          label: 'Retrato $name',
                                          child: Image.asset(
                                            path,
                                            fit: BoxFit.cover,
                                            // thumb leve (evita estourar memória)
                                            cacheWidth: 256,
                                            gaplessPlayback: true,
                                            errorBuilder: (_, __, ___) =>
                                                Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'ERRO\n$path',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.redAccent,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (_showNames)
                                      Positioned(
                                        left: 6,
                                        right: 6,
                                        bottom: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.55),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                const TextStyle(fontSize: 11),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assets Debug (rostos)'),
        actions: [
          IconButton(
            onPressed: _load,
            tooltip: 'Recarregar manifest',
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _copyAllToClipboard,
            tooltip: 'Copiar lista filtrada',
            icon: const Icon(Icons.copy_all),
          ),
        ],
      ),
      body: SafeArea(child: body),
    );
  }

  void _copyAllToClipboard() {
    final list = _filtered.join('\n');
    Clipboard.setData(ClipboardData(text: list));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copiado ${_filtered.length} caminho(s)'),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _preview(BuildContext context, String path) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.asset(
                path,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => SizedBox(
                  width: 320,
                  height: 320,
                  child: Center(
                    child: Text(
                      'Falha ao abrir\n$path',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red.shade300),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: IconButton.filledTonal(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              right: 48,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    path,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: IconButton(
                tooltip: 'Copiar caminho',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: path));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Caminho copiado!'),
                      duration: Duration(milliseconds: 1200),
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
