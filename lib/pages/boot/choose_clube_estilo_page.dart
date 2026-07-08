// lib/pages/boot/choose_clube_estilo_page.dart
//
// Tela para escolher o clube e o estilo de jogo ao iniciar a carreira.
// Versão com carregamento assíncrono dos clubes (GameState.I.clubesPublicos()):
// • Usa FutureBuilder para esperar a Future<List<AdversaryClub>>.
// • Ordena clubes por nome e lida com lista vazia/erro.
// • Botão Confirmar só habilita quando há seleção válida.
// • Try/catch no startNew com snackbar de erro.

import 'package:flutter/material.dart';
import '../../services/world/game_state.dart';
import '../../services/career/career_state.dart';
import '../../models/estilos.dart';

class ChooseClubeEstiloPage extends StatefulWidget {
  const ChooseClubeEstiloPage({super.key});

  @override
  State<ChooseClubeEstiloPage> createState() => _ChooseClubeEstiloPageState();
}

class _ChooseClubeEstiloPageState extends State<ChooseClubeEstiloPage> {
  String? _slug;
  Estilo _estilo = Estilo.transicao;

  late Future<List<AdversaryClub>> _futureClubes;

  @override
  void initState() {
    super.initState();
    // Carrega a lista de clubes públicos de forma assíncrona
    _futureClubes = GameState.I.clubesPublicos();
  }

  Future<void> _confirmar() async {
    if (_slug == null) return;
    try {
      await CareerState.I.startNew(_slug!, _estilo);
      if (!mounted) return;
      Navigator.of(context).pop(true); // retorna OK para o MenuPage
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao iniciar carreira: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escolha clube e estilo')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<List<AdversaryClub>>(
            future: _futureClubes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _ErrorCard(error: snapshot.error.toString());
              }

              final data = snapshot.data ?? const <AdversaryClub>[];

              if (data.isEmpty) {
                return const _NoClubesCard();
              }

              // Cópia ordenada por nome
              final clubes = List<AdversaryClub>.from(data)
                ..sort((a, b) => a.nome.compareTo(b.nome));

              // Garante slug inicial válido
              if (_slug == null || !clubes.any((c) => c.id == _slug)) {
                _slug = clubes.first.id;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Clube',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _slug,
                    items: clubes
                        .map<DropdownMenuItem<String>>(
                          (c) => DropdownMenuItem(
                            value: c.id, // usamos id como slug
                            child: Text(
                              c.nome,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _slug = v),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Estilo de jogo',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: Estilo.values.map((e) {
                      final sel = _estilo == e;
                      return ChoiceChip(
                        selected: sel,
                        showCheckmark: false,
                        label: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 180,
                            maxWidth: 240,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                e.descCurta,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onSelected: (_) => setState(() => _estilo = e),
                      );
                    }).toList(),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Confirmar'),
                      onPressed: (_slug != null) ? _confirmar : null,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NoClubesCard extends StatelessWidget {
  const _NoClubesCard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Nenhum clube disponível.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              const Text(
                'Verifique o seed de dados no GameState.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close),
                label: const Text('Fechar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String error;
  const _ErrorCard({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Erro ao carregar clubes.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                error,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close),
                label: const Text('Fechar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
