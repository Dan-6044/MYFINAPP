class CreateCurrencyCommand {
  final String currencyCode;
  final String currencyName;
  final String? currencySymbol;
  final int decimalPlaces;
  final bool isBaseCurrency;

  const CreateCurrencyCommand({
    required this.currencyCode,
    required this.currencyName,
    this.currencySymbol,
    this.decimalPlaces = 2,
    this.isBaseCurrency = false,
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
