import 'package:flutter/material.dart';
import 'package:futsim/models/estilos.dart';
import 'package:futsim/services/evolucao/evolucao_service.dart';
import 'package:futsim/services/evolucao/evolucao_codes.dart';

class EvolucaoPage extends StatefulWidget {
  const EvolucaoPage({super.key});

  @override
  State<EvolucaoPage> createState() => _EvolucaoPageState();
}

class _EvolucaoPageState extends State<EvolucaoPage> {
  final _evolucao = EvolucaoService();

  // Estilo do time (use os estilos prontos do estilos.dart)
  Estilo _estiloSelecionado = estiloPosicional;

  // Plano de treino atual (usa o stub ofensivo)
  PlanoTreino _plano = PlanoTreino.ofensivo();

  // Exemplo de “time/jogador” apenas para compilar o MVP
  final Object _timeExemplo = const Object();

  int _codigoPlanoAtual() {
    final id = _plano.id;
    switch (id) {
      case 'pt_ofensivo':
        return EvolucaoCodes.planoOfensivo;
      case 'pt_defensivo':
        return EvolucaoCodes.planoDefensivo;
      case 'pt_equilibrado':
        return EvolucaoCodes.planoEquilibrado;
      case 'pt_custom':
        return EvolucaoCodes.planoCustom;
      default:
        return EvolucaoCodes.planoCustom;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evolução')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Estilo do time',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButton<Estilo>(
              value: _estiloSelecionado,
              isExpanded: true,
              items: estilosPadrao
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.titulo.isNotEmpty ? e.titulo : e.nome),
                    ),
                  )
                  .toList(),
              onChanged: (novo) {
                if (novo != null) {
                  setState(() => _estiloSelecionado = novo);
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Plano de treino',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() => _plano = PlanoTreino.ofensivo());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Plano ofensivo selecionado'),
                      ),
                    );
                  },
                  child: const Text('Usar plano ofensivo'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _plano = const PlanoTreino(
                        id: 'pt_custom',
                        titulo: 'Personalizado',
                        nome: 'Custom',
                        pontosPorSemana: 4,
                        pesosAtributos: {'passe': 0.8, 'marcacao': 0.5},
                      );
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Plano personalizado selecionado'),
                      ),
                    );
                  },
                  child: const Text('Criar plano custom'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Pontos/semana: ${_plano.pontosPorSemana}'),
            const SizedBox(height: 8),
            Text('Pesos do plano: ${_plano.pesosAtributos}'),
            const SizedBox(height: 24),
            const Text(
              'Ações',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // EvolucaoService espera INT → mandamos o código do plano
                    _evolucao.aplicarTreinoSemanal(
                      _timeExemplo,
                      _codigoPlanoAtual(),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Treino semanal aplicado')),
                    );
                  },
                  child: const Text('Aplicar treino semanal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // EvolucaoService espera INT → mandamos o código da carta
                    _evolucao.aplicarCarta(
                      _timeExemplo,
                      EvolucaoCodes.cartaMaisTecnica,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Carta aplicada: +1 Técnica'),
                      ),
                    );
                  },
                  child: const Text('Aplicar carta'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _evolucao.evoluirTimeFimDeTemporada(_timeExemplo);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Evolução de fim de temporada aplicada'),
                      ),
                    );
                  },
                  child: const Text('Evoluir fim de temporada'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
