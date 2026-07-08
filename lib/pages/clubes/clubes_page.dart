// lib/pages/clubes/clubes_page.dart
//
// Lista de clubes disponíveis (dados vêm do GameState).
// Compatível com GameState.I.clubesPublicos() — agora assíncrono.
// Mostra nome, divisão e força aproximada.
// Busca por nome.
// Ao tocar, abre MeuClubePage.
//
// Dependências:
//   services/world/game_state.dart
//   pages/clubes/meu_clube_page.dart

import 'package:flutter/material.dart';
import '../../services/world/game_state.dart';
import 'meu_clube_page.dart';

class ClubesPage extends StatefulWidget {
  const ClubesPage({super.key});

  @override
  State<ClubesPage> createState() => _ClubesPageState();
}

class _ClubesPageState extends State<ClubesPage> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Clubes')),
      body: Column(
        children: [
          // ===== Campo de busca =====
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar por nome...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                        },
                      ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ===== Lista de clubes (assíncrona) =====
          Expanded(
            child: FutureBuilder<List<AdversaryClub>>(
              future: GameState.I.clubesPublicos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro ao carregar clubes:\n${snapshot.error}'),
                  );
                }

                final clubes = snapshot.data ?? const [];

                // Filtro da busca
                final filtrados = clubes.where((c) {
                  final nome = c.nome.toLowerCase();
                  return query.isEmpty || nome.contains(query);
                }).toList();

                // Ordenar por nome
                filtrados.sort((a, b) => a.nome.compareTo(b.nome));

                if (filtrados.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum clube encontrado.',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: filtrados.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final c = filtrados[i];

                    return ListTile(
                      title: Text(c.nome),
                      subtitle: Text(
                        'Divisão: ${c.divisao} • Força: ${c.idxEstruturas100.toStringAsFixed(1)}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MeuClubePage(slug: c.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
