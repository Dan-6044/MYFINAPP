class Currency {
  final int currencyID;
  final String currencyCode;
  final String currencyName;
  final String? currencySymbol;
  final int decimalPlaces;
  final bool isBaseCurrency;
  final bool isActive;
  final int accountCount;
  final String createdAt;

  const Currency({
    required this.currencyID,
    required this.currencyCode,
    required this.currencyName,
    this.currencySymbol,
    required this.decimalPlaces,
    required this.isBaseCurrency,
    required this.isActive,
    required this.accountCount,
    required this.createdAt,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      currencyID: json['currencyID'] as int,
      currencyCode: json['currencyCode'] as String,
      currencyName: json['currencyName'] as String,
      currencySymbol: json['currencySymbol'] as String?,
      decimalPlaces: json['decimalPlaces'] as int,
      isBaseCurrency: json['isBaseCurrency'] as bool,
      isActive: json['isActive'] as bool,
      accountCount: json['accountCount'] as int,
      createdAt: json['createdAt'] as String,
    );
  }
}
