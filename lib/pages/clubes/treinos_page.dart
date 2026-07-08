// lib/pages/clubes/treinos_page.dart
//
// Tela de Treinos — versão final robusta e independente de branch.
// - Não depende de tipos externos inexistentes (TreinoConfig/TreinoRegistry).
// - Persiste por clube via SharedPreferences (chave: treino:cfg:{slug}).
// - Sliders 0..100 para Volume, Foco Físico, Técnico e Tático.
// - Se um Registry futuro for adicionado, é fácil plugar (ver TODO no _salvar()).

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Mantemos o import para compat (pode existir num branch), mas não referenciamos símbolos dele.
import '../../models/time_sim_ext.dart'
    show TimeTaticoRegistry; // ignore: unused_import

class TreinosPage extends StatefulWidget {
  final String? slug;
  const TreinosPage({super.key, required this.slug});

  @override
  State<TreinosPage> createState() => _TreinosPageState();
}

class _TreinosPageState extends State<TreinosPage> {
  late _TreinoConfig _cfg;
  bool _busy = true;

  @override
  void initState() {
    super.initState();
    _cfg = const _TreinoConfig(); // defaults
    _carregar();
  }

  Future<void> _carregar() async {
    final slug = widget.slug;
    if (slug == null) {
      setState(() => _busy = false);
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey(slug));
      if (raw != null && raw.isNotEmpty) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        _cfg = _TreinoConfig.fromJson(map);
      }
    } catch (_) {
      // mantém defaults
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _salvar() async {
    final slug = widget.slug;
    if (slug == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey(slug), jsonEncode(_cfg.toJson()));

    // TODO (compat futura):
    // Se em algum branch existir um TreinoRegistry/TreinoConfig global,
    // poderemos tentar enviar os valores via chamadas dinâmicas aqui.
    // try {
    //   final reg = (TreinoRegistry as dynamic);
    //   reg.set(slug, {
    //     'volume': _cfg.volume,
    //     'focoFisico': _cfg.focoFisico,
    //     'focoTecnico': _cfg.focoTecnico,
    //     'focoTatico': _cfg.focoTatico,
    //   });
    // } catch (_) {}

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Treino salvo!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slug = widget.slug;
    if (slug == null) {
      return const Scaffold(
        body:
            Center(child: Text('Selecione um clube para configurar treinos.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Treinos')),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _slider(
                  label: 'Volume geral',
                  value: _cfg.volume.toDouble(),
                  onChanged: (v) =>
                      setState(() => _cfg = _cfg.copyWith(volume: v.round())),
                ),
                const SizedBox(height: 16),
                _slider(
                  label: 'Foco físico',
                  value: _cfg.focoFisico.toDouble(),
                  onChanged: (v) => setState(
                      () => _cfg = _cfg.copyWith(focoFisico: v.round())),
                ),
                _slider(
                  label: 'Foco técnico',
                  value: _cfg.focoTecnico.toDouble(),
                  onChanged: (v) => setState(
                      () => _cfg = _cfg.copyWith(focoTecnico: v.round())),
                ),
                _slider(
                  label: 'Foco tático',
                  value: _cfg.focoTatico.toDouble(),
                  onChanged: (v) => setState(
                      () => _cfg = _cfg.copyWith(focoTatico: v.round())),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _salvar,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar'),
                ),
              ],
            ),
    );
  }

  Widget _slider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.round()}'),
        Slider(
          value: value.clamp(0, 100),
          min: 0,
          max: 100,
          onChanged: onChanged,
        ),
      ],
    );
  }

  String _prefKey(String slug) => 'treino:cfg:$slug';
}

// ==============================
// Modelo local robusto (0..100)
// ==============================
class _TreinoConfig {
  final int volume; // carga total
  final int focoFisico;
  final int focoTecnico;
  final int focoTatico;

  const _TreinoConfig({
    this.volume = 60,
    this.focoFisico = 40,
    this.focoTecnico = 40,
    this.focoTatico = 20,
  });

  _TreinoConfig copyWith({
    int? volume,
    int? focoFisico,
    int? focoTecnico,
    int? focoTatico,
  }) {
    return _TreinoConfig(
      volume: _c(volume ?? this.volume),
      focoFisico: _c(focoFisico ?? this.focoFisico),
      focoTecnico: _c(focoTecnico ?? this.focoTecnico),
      focoTatico: _c(focoTatico ?? this.focoTatico),
    );
  }

  Map<String, dynamic> toJson() => {
        'volume': volume,
        'focoFisico': focoFisico,
        'focoTecnico': focoTecnico,
        'focoTatico': focoTatico,
      };

  factory _TreinoConfig.fromJson(Map<String, dynamic> j) => _TreinoConfig(
        volume: _c(_asInt(j['volume'], 60)),
        focoFisico: _c(_asInt(j['focoFisico'], 40)),
        focoTecnico: _c(_asInt(j['focoTecnico'], 40)),
        focoTatico: _c(_asInt(j['focoTatico'], 20)),
      );

  static int _c(num v) => v.clamp(0, 100).round();
  static int _asInt(Object? v, int def) {
    if (v == null) return def;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? def;
  }
}
