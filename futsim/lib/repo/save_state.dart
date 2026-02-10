class SaveState {
  final Map<String, List<String>> rosterPorClube;
  final Set<String> freeAgents;
  final Map<String, Emprestimo> emprestimos;

  SaveState({
    required this.rosterPorClube,
    Set<String>? freeAgents,
    Map<String, Emprestimo>? emprestimos,
  })  : freeAgents = freeAgents ?? <String>{},
        emprestimos = emprestimos ?? <String, Emprestimo>{};

  factory SaveState.fromSeeds(Map<String, List<String>> rosterSeed) {
    final clone = <String, List<String>>{};
    rosterSeed.forEach((k, v) => clone[k] = List<String>.from(v));
    return SaveState(rosterPorClube: clone);
  }

  String? clubeDoJogador(String playerId) {
    for (final e in rosterPorClube.entries) {
      if (e.value.contains(playerId)) return e.key;
    }
    return null;
  }
}

class Emprestimo {
  final String jogadorId, clubeOrigem, clubeDestino;
  final DateTime termino;
  Emprestimo({
    required this.jogadorId,
    required this.clubeOrigem,
    required this.clubeDestino,
    required this.termino,
  });
}

class TransferService {
  static bool transferir({
    required SaveState save,
    required String jogadorId,
    String? deClube,
    required String paraClube,
  }) {
    final origem = deClube ?? save.clubeDoJogador(jogadorId);
    if (origem != null) {
      save.rosterPorClube[origem]?.remove(jogadorId);
    } else {
      save.freeAgents.remove(jogadorId);
    }

    save.emprestimos.remove(jogadorId);

    save.rosterPorClube.putIfAbsent(paraClube, () => <String>[]);
    final dest = save.rosterPorClube[paraClube]!;
    if (!dest.contains(jogadorId)) dest.add(jogadorId);
    return true;
  }
}
