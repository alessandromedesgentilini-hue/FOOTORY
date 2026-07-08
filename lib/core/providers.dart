import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:footory26/services/world/game_state.dart';

/// Providers do app (camada core).
/// Regra: UI só acessa estado via providers.
final gameStateProvider = ChangeNotifierProvider<GameState>((ref) {
  return GameState();
});

/// (futuro) aqui você vai colocando outros providers globais,
/// por exemplo: settings, audio, save slots, etc.
/// Mantém tudo centralizado e padronizado.