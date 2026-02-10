import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ResultTierConfig {
  final List<int> wdl; // [winA, draw, winB]
  final List<int> golsA; // [min, max]
  final List<int> golsB; // [min, max]
  const ResultTierConfig(
      {required this.wdl, required this.golsA, required this.golsB});
}

class ResultTablesService {
  static final ResultTablesService _i = ResultTablesService._();
  ResultTablesService._();
  factory ResultTablesService() => _i;

  Map<String, ResultTierConfig>? _cache;

  Future<Map<String, ResultTierConfig>> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/result_tables.json');
    final map = json.decode(raw) as Map<String, dynamic>;
    final tiers = (map['tiers'] as Map<String, dynamic>);
    _cache = tiers.map((key, value) {
      final v = value as Map<String, dynamic>;
      return MapEntry(
        key,
        ResultTierConfig(
          wdl: List<int>.from(v['wdl'] as List<dynamic>),
          golsA: List<int>.from(v['golsA'] as List<dynamic>),
          golsB: List<int>.from(v['golsB'] as List<dynamic>),
        ),
      );
    });
    return _cache!;
  }
}
