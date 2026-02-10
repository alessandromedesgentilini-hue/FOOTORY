// lib/pages/boot/choose_clube_page.dart
//
// Escolha de clube (MVP):
// - Mostra APENAS clubes da Série D (Divisao.d)
// - Retorna o ClubeSeed escolhido via Navigator.pop(context, seed)
// - UI simples, leve, tema claro

import 'package:flutter/material.dart';

import '../../data/clubes_data.dart';

class ChooseClubePage extends StatefulWidget {
  const ChooseClubePage({super.key});

  @override
  State<ChooseClubePage> createState() => _ChooseClubePageState();
}

class _ChooseClubePageState extends State<ChooseClubePage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ✅ MVP: trava a escolha na Série D
    final all = clubesSeeds.where((c) => c.divisao == Divisao.d).toList();

    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? all
        : all.where((c) {
            final name = c.name.toLowerCase();
            final shortName = c.shortName.toLowerCase();
            final slug = c.slug.toLowerCase();
            return name.contains(q) ||
                shortName.contains(q) ||
                slug.contains(q);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha seu clube'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Série D (MVP)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Você começa na 4ª divisão. Na versão Premium (futuro), poderá escolher qualquer divisão.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar clube...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: filtered.isEmpty
                ? _emptyState(theme)
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final c = filtered[index];
                      return ListTile(
                        leading: _clubAvatar(theme, c),
                        title: Text(
                          c.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${_divisionLabel(c.divisao)} • ${c.slug}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _confirmPick(c),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Nenhum clube encontrado.\nTenta buscar por nome.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _clubAvatar(ThemeData theme, ClubeSeed c) {
    // Placeholder leve (depois troca por escudo/asset)
    final initials = _initials(c.shortName.isNotEmpty ? c.shortName : c.name);
    return CircleAvatar(
      backgroundColor: theme.colorScheme.primary.withOpacity(0.10),
      foregroundColor: theme.colorScheme.primary,
      child: Text(
        initials,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final list = parts.toList();
    if (list.isEmpty) return 'FC';
    if (list.length == 1) {
      final w = list.first;
      return w.length >= 2
          ? w.substring(0, 2).toUpperCase()
          : w[0].toUpperCase();
    }
    final a = list.first[0].toUpperCase();
    final b = list.last[0].toUpperCase();
    return '$a$b';
  }

  String _divisionLabel(Divisao d) {
    switch (d) {
      case Divisao.a:
        return 'Série A';
      case Divisao.b:
        return 'Série B';
      case Divisao.c:
        return 'Série C';
      case Divisao.d:
        return 'Série D';
    }
  }

  Future<void> _confirmPick(ClubeSeed c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Confirmar clube'),
          content: Text(
              'Começar carreira com:\n\n${c.name}\n(${_divisionLabel(c.divisao)})'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Escolher'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;
    if (!mounted) return;
    Navigator.of(context).pop<ClubeSeed>(c);
  }
}
