// lib/pages/dev/quick_temporada_page.dart
//
// Tela/dev helper para disparar a criação rápida de temporada.
// Versão compatível com o novo GameState:
// - NÃO usa mais seedSerieA() (que não existe nesse branch).
// - Apenas chama GameState.I.iniciarTemporada(...) com a divisão atual.
// - Exibe feedbacks claros na UI.
// - Usa logging seguro para debugging.

import 'package:flutter/material.dart';
import '../../services/world/game_state.dart';

class QuickTemporadaPage extends StatefulWidget {
  const QuickTemporadaPage({super.key});

  @override
  State<QuickTemporadaPage> createState() => _QuickTemporadaPageState();
}

class _QuickTemporadaPageState extends State<QuickTemporadaPage> {
  bool _loading = false;
  String? _erro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Temporada')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Criação rápida de temporada para dev/testes.\n'
                'Usa a divisão atual do GameState (A/B/C/D).',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sports_soccer),
                label: Text(_loading ? 'Gerando...' : 'Gerar temporada'),
                onPressed: _loading ? null : _onSeed,
              ),
              const SizedBox(height: 16),
              if (_erro != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SelectableText(
                          _erro!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSeed() async {
    setState(() {
      _loading = true;
      _erro = null;
    });

    try {
      final gs = GameState.I;
      // Usa a divisão atual do GameState (ex.: 'D' por padrão)
      await gs.iniciarTemporada(
        divisao: gs.divisionId,
        seed: DateTime.now().microsecondsSinceEpoch & 0x7fffffff,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Temporada criada com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = 'Falhou ao criar temporada: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falhou: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}
