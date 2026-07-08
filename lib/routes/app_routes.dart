// lib/routes/app_routes.dart
//
// Rotas (VERSÃO FINAL ROBUSTA)
// - Centraliza nomes das rotas em constantes (evita typos).
// - Fornece `onGenerateRoute` com validação de argumentos.
// - Inclui classes de argumentos para rotas que exigem parâmetros.
// - Expõe também `routesMap()` com rotas que NÃO exigem args (útil no `MaterialApp.routes`).
//
// Observação: se você mover páginas/arquivos, ajuste os imports abaixo.

import 'package:flutter/material.dart';

// ===== PAGES =====
import '../pages/menu/menu_page.dart';

import '../pages/clubes/meu_clube_page.dart';
import '../pages/clubes/elenco_page.dart';
import '../pages/clubes/jogador_page.dart';
import '../pages/clubes/jogador_detalhe_page.dart';
import '../pages/clubes/tatica_page.dart';
import '../pages/clubes/treinos_page.dart';

import '../pages/evolucao/evolucao_page.dart';

// ✅ Mercado real do seu projeto exige `clube`
import '../pages/mercado/mercado_page.dart';

import '../pages/league/rodadas_page.dart';
import '../pages/league/tabela_page.dart';
import '../pages/league/jogos_rodada_page.dart';

// ⚠️ Removidos imports inexistentes de dev
// import '../pages/dev/assets_debug_page.dart';
// import '../pages/dev/quick_temporada_page.dart';

import '../pages/boot/choose_clube_estilo_page.dart';

import '../models/jogador.dart';
import '../domain/models/clube_state.dart';

class AppRoutes {
  // ===== nomes das rotas =====
  static const home = '/';

  // Boot
  static const bootChooseClubeEstilo = '/boot/choose_clube_estilo';

  // Menu / navegação principal
  static const menu = '/menu';

  // Clubes
  static const meuClube = '/clubes/meu';
  static const elenco = '/clubes/elenco';
  static const jogador = '/clubes/jogador';
  static const jogadorDetalhe = '/clubes/jogador_detalhe';
  static const tatica = '/clubes/tatica';
  static const treinos = '/clubes/treinos';

  // Evolução / Mercado
  static const evolucao = '/evolucao';
  static const mercado = '/mercado';

  // Liga
  static const rodadas = '/league/rodadas';
  static const tabela = '/league/tabela';
  static const jogosRodada = '/league/jogos_rodada';

  // Dev / util
  static const devAssetsDebug = '/dev/assets_debug';
  static const devQuickTemporada = '/dev/quick_temporada';

  // ===== map de rotas “sem args” (opcional para MaterialApp.routes) =====
  // ✅ ATENÇÃO: Mercado exige args (clube), então NÃO entra aqui.
  static Map<String, WidgetBuilder> routesMap() => <String, WidgetBuilder>{
        home: (_) => const MenuPage(),
        menu: (_) => const MenuPage(),
        evolucao: (_) => const EvolucaoPage(),
        rodadas: (_) => const RodadasPage(),
        tabela: (_) => const TabelaPage(),
        jogosRodada: (_) => const JogosRodadaPage(),
        // Dev placeholders locais
        devAssetsDebug: (_) => const AssetsDebugPage(),
        devQuickTemporada: (_) => const QuickTemporadaPage(),
        bootChooseClubeEstilo: (_) => const ChooseClubeEstiloPage(),
      };

  // ===== onGenerateRoute com validação de argumentos =====
  static Route<dynamic>? onGenerate(RouteSettings settings) {
    switch (settings.name) {
      case home:
      case menu:
        return _mat(const MenuPage(), settings);

      case bootChooseClubeEstilo:
        return _mat(const ChooseClubeEstiloPage(), settings);

      // --- Clubes
      case meuClube:
        {
          final args = settings.arguments as MeuClubeRouteArgs?;
          if (args == null || args.slug.isEmpty) {
            return _error('MeuClubePage requer slug válido.', settings);
          }
          return _mat(
            MeuClubePage(slug: args.slug, titulo: args.titulo),
            settings,
          );
        }

      case elenco:
        {
          final args = settings.arguments as ElencoRouteArgs?;
          return _mat(ElencoPage(titulo: args?.titulo), settings);
        }

      case jogador:
        {
          final args = settings.arguments as JogadorRouteArgs?;
          if (args == null) {
            return _error('JogadorPage requer Jogador em arguments.', settings);
          }
          return _mat(JogadorPage(jogador: args.jogador), settings);
        }

      case jogadorDetalhe:
        {
          final args = settings.arguments as JogadorRouteArgs?;
          if (args == null) {
            return _error(
              'JogadorDetalhePage requer Jogador em arguments.',
              settings,
            );
          }
          return _mat(JogadorDetalhePage(jogador: args.jogador), settings);
        }

      case tatica:
        {
          final args = settings.arguments as SlugRouteArgs?;
          return _mat(TaticaPage(slug: args?.slug), settings);
        }

      case treinos:
        {
          final args = settings.arguments as SlugRouteArgs?;
          return _mat(TreinosPage(slug: args?.slug), settings);
        }

      // --- Evolução / Mercado
      case evolucao:
        return _mat(const EvolucaoPage(), settings);

      case mercado:
        {
          // ✅ Mercado exige ClubeState
          final args = settings.arguments as MercadoRouteArgs?;
          if (args == null) {
            return _error(
              'MercadoPage requer MercadoRouteArgs(clube).',
              settings,
            );
          }
          return _mat(MercadoPage(clube: args.clube), settings);
        }

      // --- Liga
      case rodadas:
        return _mat(const RodadasPage(), settings);
      case tabela:
        return _mat(const TabelaPage(), settings);
      case jogosRodada:
        return _mat(const JogosRodadaPage(), settings);

      // --- Dev (placeholders locais)
      case devAssetsDebug:
        return _mat(const AssetsDebugPage(), settings);
      case devQuickTemporada:
        return _mat(const QuickTemporadaPage(), settings);

      default:
        return _error('Rota desconhecida: ${settings.name}', settings);
    }
  }

  // ===== helpers =====
  static MaterialPageRoute _mat(Widget child, RouteSettings s) =>
      MaterialPageRoute(builder: (_) => child, settings: s);

  static MaterialPageRoute _error(String msg, RouteSettings s) =>
      MaterialPageRoute(
        settings: s,
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Rota inválida')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(msg, textAlign: TextAlign.center),
            ),
          ),
        ),
      );
}

// ===== tipos de argumentos (rotas com parâmetros) =====

class MeuClubeRouteArgs {
  final String slug;
  final String? titulo;
  const MeuClubeRouteArgs({required this.slug, this.titulo});
}

class ElencoRouteArgs {
  final String? titulo;
  const ElencoRouteArgs({this.titulo});
}

class JogadorRouteArgs {
  final Jogador jogador;
  const JogadorRouteArgs(this.jogador);
}

class SlugRouteArgs {
  final String? slug;
  const SlugRouteArgs(this.slug);
}

// ✅ Mercado exige ClubeState
class MercadoRouteArgs {
  final ClubeState clube;
  const MercadoRouteArgs(this.clube);
}

// ======= DEV PLACEHOLDERS (remova se criar as telas reais) =======

class AssetsDebugPage extends StatelessWidget {
  const AssetsDebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assets Debug (DEV)')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Placeholder de debug de assets.\n'
            'Crie lib/pages/dev/assets_debug_page.dart para substituir.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class QuickTemporadaPage extends StatelessWidget {
  const QuickTemporadaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Temporada (DEV)')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Placeholder da página de temporada rápida.\n'
            'Crie lib/pages/dev/quick_temporada_page.dart para substituir.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
