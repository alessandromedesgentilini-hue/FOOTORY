// lib/pages/boot/boot_menu_page.dart
//
// Tela de boot do FutSim:
// - "Novo jogo" → abre ChooseClubePage, o jogador escolhe o clube
// - Cria a temporada e salva automaticamente (Hive)
// - "Continuar carreira" → carrega o save (Hive) e abre HomePage
//
// MVP: Save em JSON (sem Adapter), 1 slot.

import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/clubes_data.dart';
import '../../services/storage/save_repository.dart';
import '../../services/world/game_state.dart';
import '../home/home_page.dart';
import 'choose_clube_page.dart';

class BootMenuPage extends StatefulWidget {
  const BootMenuPage({super.key});

  @override
  State<BootMenuPage> createState() => _BootMenuPageState();
}

class _BootMenuPageState extends State<BootMenuPage> {
  bool _loading = false;
  bool _hasSave = false;

  @override
  void initState() {
    super.initState();
    _refreshHasSave();
  }

  void _refreshHasSave() {
    final has = SaveRepository.hasCareer();
    setState(() => _hasSave = has);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FutSim'),
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sports_soccer,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'FutSim',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'MVP — carreira offline simples',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // NOVO JOGO
                  FilledButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Novo jogo'),
                    onPressed: _loading ? null : _onNovoJogo,
                  ),
                  const SizedBox(height: 12),

                  // CONTINUAR
                  OutlinedButton.icon(
                    icon: const Icon(Icons.save),
                    label: Text(
                      _hasSave ? 'Continuar carreira' : 'Continuar (sem save)',
                    ),
                    onPressed: (_loading || !_hasSave) ? null : _onContinuar,
                  ),

                  const SizedBox(height: 12),

                  // (Opcional) botão de reset/debug — útil no dev
                  if (_hasSave)
                    TextButton.icon(
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Apagar save (debug)'),
                      onPressed: _loading ? null : _onApagarSave,
                    ),

                  const SizedBox(height: 24),
                  Text(
                    'Escolha um clube, jogue a liga completa,\n'
                    'suba e desça divisões. Depois a gente pluga\n'
                    'finanças, mercado e base por cima.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _onNovoJogo() async {
    final picked = await Navigator.of(context).push<ClubeSeed>(
      MaterialPageRoute(builder: (_) => const ChooseClubePage()),
    );
    if (picked == null) return;

    setState(() => _loading = true);

    try {
      final gs = GameState.I;

      final divId = _divisionIdFromSeed(picked.divisao);
      gs.divisionId = divId;

      final forca = _forcaEstimativa(picked).toDouble();
      final estruturas = (forca * 0.92).clamp(30.0, 99.0);

      gs.registerUserClub(
        id: picked.slug,
        nome: picked.name,
        ovrMedia100: forca,
        idxEstruturas100: estruturas,
        taticaBonus: 5,
        artilheiros: [
          'Camisa 9',
          'Camisa 10',
          picked.shortName,
        ],
      );

      final seed = DateTime.now().microsecondsSinceEpoch & 0x7fffffff;
      await gs.iniciarTemporada(divisao: divId, seed: seed);

      // salva
      await SaveRepository.saveCareer();
      _refreshHasSave();

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao iniciar novo jogo: $e')),
      );
      setState(() => _loading = false);
    }
  }

  Future<void> _onContinuar() async {
    setState(() => _loading = true);

    try {
      final ok = await SaveRepository.loadCareer();
      if (!ok) {
        _refreshHasSave();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum save encontrado.')),
        );
        setState(() => _loading = false);
        return;
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      await SaveRepository.clearCareer();
      _refreshHasSave();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save inválido. Apagado. Erro: $e')),
      );
      setState(() => _loading = false);
    }
  }

  Future<void> _onApagarSave() async {
    setState(() => _loading = true);
    await SaveRepository.clearCareer();
    _refreshHasSave();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Save apagado.')),
    );
    setState(() => _loading = false);
  }

  String _divisionIdFromSeed(Divisao d) {
    switch (d) {
      case Divisao.a:
        return 'A';
      case Divisao.b:
        return 'B';
      case Divisao.c:
        return 'C';
      case Divisao.d:
        return 'D';
    }
  }

  int _forcaEstimativa(ClubeSeed s) {
    final h = s.slug.hashCode & 0x7fffffff;
    final rnd = Random(h);

    double base;
    switch (s.divisao) {
      case Divisao.a:
        base = 74;
        break;
      case Divisao.b:
        base = 68;
        break;
      case Divisao.c:
        base = 62;
        break;
      case Divisao.d:
        base = 56;
        break;
    }

    final jitter = rnd.nextInt(11) - 5; // -5..+5
    final v = (base + jitter).clamp(45, 85);
    return v.round();
  }
}
