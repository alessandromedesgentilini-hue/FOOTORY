import 'package:flutter/material.dart';
import 'pages/menu/menu_page.dart';
import 'pages/mercado/mercado_page.dart';
import 'pages/evolucao/evolucao_page.dart';

/// Rotas definitivas do FUTSIM (núcleo). Você pode expandir depois
/// adicionando outras páginas ao mapa `builders`.
class AppRoutes {
  static const menu = '/';
  static const mercado = '/mercado';
  static const evolucao = '/evolucao';

  static Map<String, WidgetBuilder> get builders => {
        menu: (_) => const MenuPage(),
        mercado: (_) => const MercadoPage(),
        evolucao: (_) => const EvolucaoPage(),
      };
}
