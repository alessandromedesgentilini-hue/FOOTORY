import 'package:flutter/material.dart';
import 'package:futsim/models/estilos.dart';
import 'package:futsim/services/mercado/mercado_service.dart';

class MercadoPage extends StatefulWidget {
  const MercadoPage({super.key});

  @override
  State<MercadoPage> createState() => _MercadoPageState();
}

class _MercadoPageState extends State<MercadoPage> {
  final _mercado = MercadoService();

  // estilos básicos vindos de lib/models/estilos.dart
  Estilo _estiloSelecionado = estiloPosicional;

  // exemplo de “jogador” só para compilar (troque pelo seu modelo depois)
  final Object _jogadorExemplo = const Object();

  Negociacao? _negociacao;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mercado')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Estilo do time',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButton<Estilo>(
              value: _estiloSelecionado,
              isExpanded: true,
              items: estilosPadrao
                  .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.titulo.isNotEmpty ? e.titulo : e.nome)))
                  .toList(),
              onChanged: (novo) {
                if (novo != null) {
                  setState(() => _estiloSelecionado = novo);
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // avalia valor/salário usando os stubs
                    final valor = _mercado.avaliarValor(_jogadorExemplo);
                    final salario = _mercado.salarioAlvo(_jogadorExemplo);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Valor: \$${valor.toStringAsFixed(0)} | Salário alvo: \$${salario.toStringAsFixed(0)}')),
                    );
                  },
                  child: const Text('Avaliar jogador'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // inicia negociação (stub)
                    setState(() {
                      _mercado.iniciarNegociacao(_jogadorExemplo);
                      _negociacao = Negociacao(
                          jogador: _jogadorExemplo, roundsRestantes: 3);
                    });
                  },
                  child: const Text('Iniciar negociação'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_negociacao != null) ...[
              const Text('Negociação',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Rounds restantes: ${_negociacao!.roundsRestantes}'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // stub: proposta ao clube
                      _mercado.proporAoClube(_negociacao!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Proposta enviada ao clube')),
                      );
                    },
                    child: const Text('Propor ao clube'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // stub: proposta ao jogador
                      _mercado.proporAoJogador(_negociacao!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Proposta enviada ao jogador')),
                      );
                    },
                    child: const Text('Propor ao jogador'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
