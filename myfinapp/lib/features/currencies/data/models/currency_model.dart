class CurrencyModel {
  final int currencyId;
  final String currencyCode;
  final String currencyName;
  final String? currencySymbol;
  final int decimalPlaces;
  final bool isBaseCurrency;
  final bool isActive;
  final String createdAt;

  const CurrencyModel({
    required this.currencyId,
    required this.currencyCode,
    required this.currencyName,
    this.currencySymbol,
    required this.decimalPlaces,
    required this.isBaseCurrency,
    required this.isActive,
    required this.createdAt,
  });

  factory CurrencyModel.fromMap(Map<String, dynamic> map) {
    return CurrencyModel(
      currencyId: map['currency_id'] as int,
      currencyCode: map['currency_code'] as String,
      currencyName: map['currency_name'] as String,
      currencySymbol: map['currency_symbol'] as String?,
      decimalPlaces: map['decimal_places'] as int,
      isBaseCurrency: (map['is_base_currency'] as int) == 1,
      isActive: (map['is_active'] as int) == 1,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currency_id': currencyId,
      'currency_code': currencyCode,
      'currency_name': currencyName,
      'currency_symbol': currencySymbol,
      'decimal_places': decimalPlaces,
      'is_base_currency': isBaseCurrency ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
    };
  }
}
