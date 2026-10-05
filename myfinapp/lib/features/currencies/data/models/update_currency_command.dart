class UpdateCurrencyCommand {
  final String currencyCode;
  final String currencyName;
  final String? currencySymbol;
  final int decimalPlaces;
  final bool isBaseCurrency;

  const UpdateCurrencyCommand({
    required this.currencyCode,
    required this.currencyName,
    this.currencySymbol,
    required this.decimalPlaces,
    required this.isBaseCurrency,
  });

  Map<String, dynamic> toJson() {
    return {
      'currencyCode': currencyCode,
      'currencyName': currencyName,
      if (currencySymbol != null) 'currencySymbol': currencySymbol,
      'decimalPlaces': decimalPlaces,
      'isBaseCurrency': isBaseCurrency,
    };
  }
}
