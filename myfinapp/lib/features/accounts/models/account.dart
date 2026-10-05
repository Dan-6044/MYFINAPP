class Account {
  final int coaID;
  final String coaCode;
  final String coaName;
  final AccountSubhead subhead;
  final AccountMainHead mainHead;
  final AccountCurrency? currency;
  final String? description;
  final bool isControlAccount;
  final bool allowDirectPosting;
  final bool isActive;
  final num openingBalance;
  final String createdAt;
  final String? updatedAt;

  const Account({
    required this.coaID,
    required this.coaCode,
    required this.coaName,
    required this.subhead,
    required this.mainHead,
    this.currency,
    this.description,
    required this.isControlAccount,
    required this.allowDirectPosting,
    required this.isActive,
    required this.openingBalance,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Account &&
          runtimeType == other.runtimeType &&
          coaID == other.coaID;

  @override
  int get hashCode => coaID.hashCode;

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      coaID: (json['coaID'] ?? json['coaid']) as int,
      coaCode: json['coaCode'] as String,
      coaName: json['coaName'] as String,
      subhead: AccountSubhead.fromJson(json['subhead'] as Map<String, dynamic>),
      mainHead: AccountMainHead.fromJson(json['mainHead'] as Map<String, dynamic>),
      currency: json['currency'] != null
          ? AccountCurrency.fromJson(json['currency'] as Map<String, dynamic>)
          : null,
      description: json['description'] as String?,
      isControlAccount: json['isControlAccount'] as bool,
      allowDirectPosting: json['allowDirectPosting'] as bool,
      isActive: json['isActive'] as bool,
      openingBalance: (json['openingBalance'] as num).toDouble(),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class AccountSubhead {
  final int subheadID;
  final int subheadCode;
  final String subheadName;

  const AccountSubhead({
    required this.subheadID,
    required this.subheadCode,
    required this.subheadName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountSubhead &&
          runtimeType == other.runtimeType &&
          subheadID == other.subheadID;

  @override
  int get hashCode => subheadID.hashCode;

  factory AccountSubhead.fromJson(Map<String, dynamic> json) {
    return AccountSubhead(
      subheadID: json['subheadID'] as int,
      subheadCode: json['subheadCode'] as int,
      subheadName: json['subheadName'] as String,
    );
  }
}

class AccountMainHead {
  final int mainHeadID;
  final int mainHeadCode;
  final String mainHeadName;
  final String? accountingType;
  final String? normalBalance;
  final String? normalBalanceName;

  const AccountMainHead({
    required this.mainHeadID,
    required this.mainHeadCode,
    required this.mainHeadName,
    this.accountingType,
    this.normalBalance,
    this.normalBalanceName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountMainHead &&
          runtimeType == other.runtimeType &&
          mainHeadID == other.mainHeadID;

  @override
  int get hashCode => mainHeadID.hashCode;

  factory AccountMainHead.fromJson(Map<String, dynamic> json) {
    return AccountMainHead(
      mainHeadID: json['mainHeadID'] as int,
      mainHeadCode: json['mainHeadCode'] as int,
      mainHeadName: json['mainHeadName'] as String,
      accountingType: json['accountingType'] as String?,
      normalBalance: json['normalBalance'] as String?,
      normalBalanceName: json['normalBalanceName'] as String?,
    );
  }
}

class AccountCurrency {
  final int currencyID;
  final String currencyCode;
  final String currencyName;
  final String? currencySymbol;
  final int decimalPlaces;

  const AccountCurrency({
    required this.currencyID,
    required this.currencyCode,
    required this.currencyName,
    this.currencySymbol,
    required this.decimalPlaces,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountCurrency &&
          runtimeType == other.runtimeType &&
          currencyID == other.currencyID;

  @override
  int get hashCode => currencyID.hashCode;

  factory AccountCurrency.fromJson(Map<String, dynamic> json) {
    return AccountCurrency(
      currencyID: json['currencyID'] as int,
      currencyCode: json['currencyCode'] as String,
      currencyName: json['currencyName'] as String,
      currencySymbol: json['currencySymbol'] as String?,
      decimalPlaces: json['decimalPlaces'] as int,
    );
  }
}
