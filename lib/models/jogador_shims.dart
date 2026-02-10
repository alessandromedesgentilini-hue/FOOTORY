// lib/models/jogador_shims.dart
//
// Shims de posições em estilo "FIFA" / "FM".
// Mantemos as siglas em MAIÚSCULO (GK, RB, CB, etc.) porque são padrão do futebol.
//
// Os avisos de lint sobre nome de constante são ignorados neste arquivo,
// para não atrapalhar a leitura.
//
// Se quiser seguir usando essas strings em qualquer lugar do app, é só importar:
//   import 'package:futsim/models/jogador_shims.dart';
//
// ignore_for_file: constant_identifier_names

// Goleiro
const String GK = 'GK';

// Defensores laterais e alas
const String RB = 'RB';
const String RWB = 'RWB';
const String CB = 'CB';
const String LB = 'LB';
const String LWB = 'LWB';

// Meio-campo defensivo / volantes
const String DM = 'DM';
const String CDM = 'CDM';

// Meio-campo central / ofensivo
const String CM = 'CM';
const String AM = 'AM';
const String CAM = 'CAM';

// Pontas e meias abertos
const String RW = 'RW';
const String RM = 'RM';
const String LW = 'LW';
const String LM = 'LM';

// Atacantes
const String ST = 'ST';
const String CF = 'CF';
const String SS = 'SS';

// Se precisar de mapeamentos futuros, dá pra colocar aqui, exemplo:
//
// const List<String> POSICOES_LINHA = [
//   RB, RWB, CB, LB, LWB,
//   DM, CDM, CM, AM, CAM,
//   RW, RM, LW, LM, ST, CF, SS,
// ];
//
// const List<String> POSICOES_TODAS = [GK, ...POSICOES_LINHA];
