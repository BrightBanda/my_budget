/// A supported display currency. Values are const so the whole set is known at
/// compile time — see [Currency.all].
class Currency {
  final String code; // ISO 4217, e.g. 'MWK'
  final String name; // e.g. 'Malawian Kwacha'
  final String symbol; // e.g. 'MK'
  final String country; // e.g. 'Malawi'
  final String flag; // emoji

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.country,
    required this.flag,
  });

  static const malawi = Currency(
    code: 'MWK',
    name: 'Malawian Kwacha',
    symbol: 'MK',
    country: 'Malawi',
    flag: '🇲🇼',
  );

  static const zambia = Currency(
    code: 'ZMW',
    name: 'Zambian Kwacha',
    symbol: 'K',
    country: 'Zambia',
    flag: '🇿🇲',
  );

  static const tanzania = Currency(
    code: 'TZS',
    name: 'Tanzanian Shilling',
    symbol: 'TSh',
    country: 'Tanzania',
    flag: '🇹🇿',
  );

  static const usa = Currency(
    code: 'USD',
    name: 'US Dollar',
    symbol: '\$',
    country: 'United States',
    flag: '🇺🇸',
  );

  static const canada = Currency(
    code: 'CAD',
    name: 'Canadian Dollar',
    symbol: 'C\$',
    country: 'Canada',
    flag: '🇨🇦',
  );

  static const europe = Currency(
    code: 'EUR',
    name: 'Euro',
    symbol: '€',
    country: 'Europe',
    flag: '🇪🇺',
  );

  static const britain = Currency(
    code: 'GBP',
    name: 'British Pound',
    symbol: '£',
    country: 'United Kingdom',
    flag: '🇬🇧',
  );

  /// Malawi first — it's the default and the app's home market.
  static const all = <Currency>[
    malawi,
    zambia,
    tanzania,
    usa,
    canada,
    europe,
    britain,
  ];

  /// Resolves a stored ISO code back to a [Currency], falling back to the default.
  static Currency fromCode(String? code) {
    return all.firstWhere(
      (c) => c.code == code,
      orElse: () => malawi,
    );
  }
}
