/// Domain model representing a world currency.
class Currency {
  const Currency({
    required this.code,
    required this.name,
    this.symbol = '',
    this.flag = '',
  });

  /// 3-letter ISO 4217 currency code (e.g. USD, EUR, BDT).
  final String code;

  /// Full English name of the currency (e.g. United States Dollar, Bangladeshi Taka).
  final String name;

  /// Conventional currency symbol (e.g. $, €, ৳, £, ₹), or empty if none.
  final String symbol;

  /// Emoji flag representation (e.g. 🇺🇸, 🇪🇺, 🇧🇩).
  final String flag;

  /// Generates a country flag emoji from a 3-letter ISO 4217 currency code.
  static String flagForCode(String code) {
    final upper = code.trim().toUpperCase();
    if (upper == 'EUR') return '🇪🇺';
    if (upper == 'XAU' || upper == 'XAG' || upper == 'XPD' || upper == 'XPT') {
      return '🪙';
    }
    if (upper == 'XDR' || upper == 'XAF' || upper == 'XOF' || upper == 'XPF') {
      return '🌍';
    }
    if (upper.length >= 2) {
      final c0 = upper.codeUnitAt(0);
      final c1 = upper.codeUnitAt(1);
      if (c0 >= 65 && c0 <= 90 && c1 >= 65 && c1 <= 90) {
        final first = 0x1F1E6 + (c0 - 65);
        final second = 0x1F1E6 + (c1 - 65);
        return String.fromCharCode(first) + String.fromCharCode(second);
      }
    }
    return '🌐';
  }

  factory Currency.fromJson(Map<String, dynamic> json) {
    final code = (json['code'] ?? json['iso_code'] ?? '')
        .toString()
        .toUpperCase();
    final name = (json['name'] ?? '').toString();
    final symbol = (json['symbol'] ?? '').toString();
    final flag = (json['flag'] ?? '').toString();

    return Currency(
      code: code,
      name: name,
      symbol: symbol,
      flag: flag.isNotEmpty ? flag : flagForCode(code),
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'symbol': symbol,
    'flag': flag,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$code ($name)';
}
