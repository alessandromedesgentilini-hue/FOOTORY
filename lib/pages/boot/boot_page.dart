import 'package:flutter/material.dart';
import '../../services/world/game_state.dart';
import '../home/home_page.dart';
import 'choose_clube_page.dart';

class BootPage extends StatelessWidget {
  const BootPage({super.key});

  void _novoJogoRapido(BuildContext context) {
    final gs = GameState.I;

    // Jogo rápido: Série D com clube genérico
    gs.divisionId = 'D';
    gs.registerUserClub(
      id: 'meu-clube',
      nome: 'Seu Clube',
      ovrMedia100: 60.0,
      idxEstruturas100: 55.0,
      taticaBonus: 5,
      artilheiros: const ['Centroavante', 'Camisa 10', 'Ponta'],
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  void _escolherClube(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ChooseClubePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('FutSim')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Modo Carreira — MVP',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Escolha como quer começar sua carreira. Depois disso o jogo cuida '
              'do calendário, subidas e descidas automaticamente.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _novoJogoRapido(context),
              child: const Text('Novo jogo rápido (Série D)'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _escolherClube(context),
              child: const Text('Escolher clube'),
            ),
            const Spacer(),
            Text(
              'MVP: primeiro o jogo fica liso. Depois a gente coloca base, mercado, '
              'faces e escudos personalizados.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
