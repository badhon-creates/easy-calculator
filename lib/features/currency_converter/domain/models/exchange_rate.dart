/// Domain model representing a snapshot of exchange rates against a reference base currency.
class ExchangeRatesSnapshot {
  const ExchangeRatesSnapshot({
    required this.baseCurrency,
    required this.date,
    required this.rates,
    required this.timestamp,
    this.isCached = false,
  });

  /// The reference base currency code (typically 'USD' or 'EUR').
  final String baseCurrency;

  /// The official date of the exchange rate publication (YYYY-MM-DD).
  final String date;

  /// Map of currency code to rate relative to 1 unit of [baseCurrency].
  final Map<String, double> rates;

  /// Local timestamp when the rates were fetched or saved to cache.
  final DateTime timestamp;

  /// Whether this snapshot was loaded from offline cache rather than live network.
  final bool isCached;

  /// Returns the rate from [fromCode] to [toCode].
  ///
  /// Uses cross-rate calculation if neither matches [baseCurrency]:
  /// Rate(from -> to) = Rate(base -> to) / Rate(base -> from)
  double? getRate({required String fromCode, required String toCode}) {
    final from = fromCode.trim().toUpperCase();
    final to = toCode.trim().toUpperCase();

    if (from == to) return 1.0;

    final base = baseCurrency.trim().toUpperCase();

    // From is base currency: rate is directly rates[to]
    if (from == base) {
      return rates[to];
    }

    // To is base currency: rate is 1 / rates[from]
    if (to == base) {
      final rateFrom = rates[from];
      if (rateFrom != null && rateFrom > 0) {
        return 1.0 / rateFrom;
      }
      return null;
    }

    // Cross-rate calculation
    final rateFrom = rates[from];
    final rateTo = rates[to];
    if (rateFrom != null && rateTo != null && rateFrom > 0) {
      return rateTo / rateFrom;
    }

    return null;
  }

  ExchangeRatesSnapshot copyWith({
    String? baseCurrency,
    String? date,
    Map<String, double>? rates,
    DateTime? timestamp,
    bool? isCached,
  }) {
    return ExchangeRatesSnapshot(
      baseCurrency: baseCurrency ?? this.baseCurrency,
      date: date ?? this.date,
      rates: rates ?? this.rates,
      timestamp: timestamp ?? this.timestamp,
      isCached: isCached ?? this.isCached,
    );
  }

  factory ExchangeRatesSnapshot.fromJson(Map<String, dynamic> json) {
    final rawRates = json['rates'] as Map<String, dynamic>? ?? {};
    final parsedRates = <String, double>{};
    for (final entry in rawRates.entries) {
      final val = entry.value;
      if (val is num) {
        parsedRates[entry.key.toUpperCase()] = val.toDouble();
      }
    }

    final base = (json['base'] ?? json['baseCurrency'] ?? 'USD')
        .toString()
        .toUpperCase();
    // Ensure base currency has 1.0 rate
    parsedRates[base] = 1.0;

    final date = (json['date'] ?? '').toString();
    final rawTime = json['timestamp'];
    final timestamp = rawTime != null
        ? DateTime.tryParse(rawTime.toString()) ?? DateTime.now()
        : DateTime.now();
    final isCached = json['isCached'] == true;

    return ExchangeRatesSnapshot(
      baseCurrency: base,
      date: date,
      rates: parsedRates,
      timestamp: timestamp,
      isCached: isCached,
    );
  }

  Map<String, dynamic> toJson() => {
    'baseCurrency': baseCurrency,
    'date': date,
    'rates': rates,
    'timestamp': timestamp.toIso8601String(),
    'isCached': isCached,
  };
}
