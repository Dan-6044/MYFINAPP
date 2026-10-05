class TransactionTypeRule {
  final int transactionTypeRuleID;
  final int transactionTypeID;
  final int transactionTypeCode;
  final String transactionTypeName;
  final bool transactionTypeIsSystem;
  final bool transactionTypeIsActive;
  final String entrySide;
  final int mainHeadID;
  final int mainHeadCode;
  final String mainHeadName;
  final String accountingType;
  final String normalBalance;
  final int sequenceNo;
  final bool isRequired;
  final String createdAt;

  const TransactionTypeRule({
    required this.transactionTypeRuleID,
    required this.transactionTypeID,
    required this.transactionTypeCode,
    required this.transactionTypeName,
    required this.transactionTypeIsSystem,
    required this.transactionTypeIsActive,
    required this.entrySide,
    required this.mainHeadID,
    required this.mainHeadCode,
    required this.mainHeadName,
    required this.accountingType,
    required this.normalBalance,
    required this.sequenceNo,
    required this.isRequired,
    required this.createdAt,
  });

  factory TransactionTypeRule.fromJson(Map<String, dynamic> json) {
    return TransactionTypeRule(
      transactionTypeRuleID: json['transactionTypeRuleID'] as int,
      transactionTypeID: json['transactionTypeID'] as int,
      transactionTypeCode: json['transactionTypeCode'] as int,
      transactionTypeName: json['transactionTypeName'] as String,
      transactionTypeIsSystem: json['transactionTypeIsSystem'] as bool,
      transactionTypeIsActive: json['transactionTypeIsActive'] as bool,
      entrySide: json['entrySide'] as String,
      mainHeadID: json['mainHeadID'] as int,
      mainHeadCode: json['mainHeadCode'] as int,
      mainHeadName: json['mainHeadName'] as String,
      accountingType: json['accountingType'] as String,
      normalBalance: json['normalBalance'] as String,
      sequenceNo: json['sequenceNo'] as int,
      isRequired: json['isRequired'] as bool,
      createdAt: json['createdAt'] as String,
    );
  }
}
