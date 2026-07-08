import 'package:flutter/material.dart';

import 'pages/menu/menu_page.dart';
import 'pages/mercado/mercado_page.dart';
import 'pages/evolucao/evolucao_page.dart';

import 'services/world/game_state.dart';

/// Rotas definitivas do FUTSIM (núcleo).
/// Simples, explícitas e compatíveis com o MVP atual.
class AppRoutes {
  static const menu = '/';
  static const mercado = '/mercado';
  static const evolucao = '/evolucao';

  static Map<String, WidgetBuilder> get builders => {
        menu: (_) => const MenuPage(),
        mercado: (_) {
          final clube = GameState.I.userClubState;
          if (clube == null) {
            return const _ErroRotaPage(
              mensagem: 'Clube do usuário não inicializado.',
            );
          }
          return MercadoPage(clube: clube);
        },
        evolucao: (_) => const EvolucaoPage(),
      };
}

/// Página de erro simples para falha de rota (MVP-safe)
class _ErroRotaPage extends StatelessWidget {
  final String mensagem;

  const _ErroRotaPage({required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erro')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            mensagem,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
