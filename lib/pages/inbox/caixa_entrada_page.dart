// lib/pages/inbox/caixa_entrada_page.dart
//
// Caixa de Entrada MVP: mensagens amarelas/vermelhas, etc.

import 'package:flutter/material.dart';

import '../../services/inbox/inbox_service.dart';

class CaixaEntradaPage extends StatefulWidget {
  const CaixaEntradaPage({super.key});

  @override
  State<CaixaEntradaPage> createState() => _CaixaEntradaPageState();
}

class _CaixaEntradaPageState extends State<CaixaEntradaPage> {
  @override
  Widget build(BuildContext context) {
    final items = InboxService.I.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caixa de Entrada'),
        actions: [
          IconButton(
            tooltip: 'Limpar',
            onPressed: () {
              InboxService.I.clear();
              setState(() {});
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: items.isEmpty
          ? const Center(
              child: Text('Sem mensagens.'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (_, i) => _tile(context, items[i]),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemCount: items.length,
            ),
    );
  }

  Widget _tile(BuildContext context, InboxMessage m) {
    final cs = Theme.of(context).colorScheme;

    Color bg;
    Color fg;
    IconData icon;

    switch (m.kind) {
      case InboxKind.critical:
        bg = Colors.red.withOpacity(0.10);
        fg = Colors.red.shade800;
        icon = Icons.error_outline;
        break;
      case InboxKind.warning:
        bg = Colors.amber.withOpacity(0.18);
        fg = Colors.brown.shade800;
        icon = Icons.warning_amber_rounded;
        break;
      case InboxKind.info:
      default:
        bg = cs.surface;
        fg = cs.onSurface;
        icon = Icons.info_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: fg,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  m.body,
                  style: TextStyle(
                    height: 1.25,
                    color: fg.withOpacity(0.95),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _fmtDate(m.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: fg.withOpacity(0.7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final mo = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return '$dd/$mo/$yy • $hh:$mm';
  }
}
