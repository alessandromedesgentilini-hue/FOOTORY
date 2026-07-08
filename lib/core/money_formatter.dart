class MoneyFormatter {
  const MoneyFormatter._();

  /// ================================
  /// FORMATO COMPACTO (UX PRINCIPAL)
  /// ================================
  /// Ex:
  /// 54500 -> 54,5 mil
  /// 540000 -> 540 mil
  /// 3500000 -> 3,5 milhões
  /// 260000000 -> 260 milhões
  /// 1000000000 -> 1 bilhão
  ///
  static String formatCompact(int value) {
    final abs = value.abs();
    final sign = value < 0 ? '-' : '';

    if (abs >= 1000000000) {
      final v = abs / 1000000000;
      return '$sign${_formatNumber(v)} ${_plural(v, 'bilhão', 'bilhões')}';
    }

    if (abs >= 1000000) {
      final v = abs / 1000000;
      return '$sign${_formatNumber(v)} ${_plural(v, 'milhão', 'milhões')}';
    }

    if (abs >= 1000) {
      final v = abs / 1000;

      if (abs >= 100000) {
        return '$sign${v.toStringAsFixed(0)} mil';
      }

      return '$sign${_formatNumber(v)} mil';
    }

    return '$sign$abs';
  }

  static String formatCurrency(int value) {
    return 'R\$ ${formatCompact(value)}';
  }

  static String formatFull(int value) {
    final sign = value < 0 ? '-' : '';
    final abs = value.abs().toString();

    final buffer = StringBuffer();

    for (int i = 0; i < abs.length; i++) {
      final indexFromEnd = abs.length - i;

      buffer.write(abs[i]);

      if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return '$sign${buffer.toString()}';
  }

  static String formatCurrencyFull(int value) {
    return 'R\$ ${formatFull(value)}';
  }

  static String _plural(double value, String singular, String plural) {
    return value >= 2 ? plural : singular;
  }

  static String _formatNumber(double value) {
    String text;

    if (value >= 100) {
      text = value.toStringAsFixed(0);
    } else if (value >= 10) {
      text = value.toStringAsFixed(1);
    } else {
      text = value.toStringAsFixed(2);
    }

    if (text.contains('.')) {
      while (text.endsWith('0')) {
        text = text.substring(0, text.length - 1);
      }

      if (text.endsWith('.')) {
        text = text.substring(0, text.length - 1);
      }
    }

    return text.replaceAll('.', ',');
  }
}
