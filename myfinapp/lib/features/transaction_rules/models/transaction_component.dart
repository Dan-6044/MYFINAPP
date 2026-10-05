class TransactionComponent {
  final int transactionComponentID;
  final int transactionTypeID;
  final int transactionTypeCode;
  final String transactionTypeName;
  final String componentCode;
  final String componentName;
  final String? description;
  final bool isRequired;
  final bool isActive;
  final int sequenceNo;
  final bool transactionTypeIsSystem;
  final int ruleCount;
  final int transactionLineCount;
  final String createdAt;
  final String? updatedAt;

  const TransactionComponent({
    required this.transactionComponentID,
    required this.transactionTypeID,
    required this.transactionTypeCode,
    required this.transactionTypeName,
    required this.componentCode,
    required this.componentName,
    this.description,
    required this.isRequired,
    required this.isActive,
    required this.sequenceNo,
    required this.transactionTypeIsSystem,
    required this.ruleCount,
    required this.transactionLineCount,
    required this.createdAt,
    this.updatedAt,
  });

  factory TransactionComponent.fromJson(Map<String, dynamic> json) {
    return TransactionComponent(
      transactionComponentID: json['transactionComponentID'] as int,
      transactionTypeID: json['transactionTypeID'] as int,
      transactionTypeCode: json['transactionTypeCode'] as int,
      transactionTypeName: json['transactionTypeName'] as String,
      componentCode: json['componentCode'] as String,
      componentName: json['componentName'] as String,
      description: json['description'] as String?,
      isRequired: json['isRequired'] as bool,
      isActive: json['isActive'] as bool,
      sequenceNo: json['sequenceNo'] as int,
      transactionTypeIsSystem: json['transactionTypeIsSystem'] as bool,
      ruleCount: json['ruleCount'] as int,
      transactionLineCount: json['transactionLineCount'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionComponent &&
          runtimeType == other.runtimeType &&
          transactionComponentID == other.transactionComponentID;

  @override
  int get hashCode => transactionComponentID.hashCode;
}

class TransactionComponentRule {
  final int transactionComponentRuleID;
  final int transactionComponentID;
  final int transactionTypeID;
  final int transactionTypeCode;
  final String transactionTypeName;
  final bool transactionTypeIsSystem;
  final bool transactionTypeIsActive;
  final String componentCode;
  final String componentName;
  final bool componentIsRequired;
  final bool componentIsActive;
  final String entrySide;
  final int mainHeadID;
  final int mainHeadCode;
  final String mainHeadName;
  final String accountingType;
  final String normalBalance;
  final int? subheadID;
  final int? subheadCode;
  final String? subheadName;
  final int? coaID;
  final String? coaCode;
  final String? coaName;
  final bool isRequired;
  final int sequenceNo;
  final String createdAt;
  final String? updatedAt;

  const TransactionComponentRule({
    required this.transactionComponentRuleID,
    required this.transactionComponentID,
    required this.transactionTypeID,
    required this.transactionTypeCode,
    required this.transactionTypeName,
    required this.transactionTypeIsSystem,
    required this.transactionTypeIsActive,
    required this.componentCode,
    required this.componentName,
    required this.componentIsRequired,
    required this.componentIsActive,
    required this.entrySide,
    required this.mainHeadID,
    required this.mainHeadCode,
    required this.mainHeadName,
    required this.accountingType,
    required this.normalBalance,
    this.subheadID,
    this.subheadCode,
    this.subheadName,
    this.coaID,
    this.coaCode,
    this.coaName,
    required this.isRequired,
    required this.sequenceNo,
    required this.createdAt,
    this.updatedAt,
  });

  factory TransactionComponentRule.fromJson(Map<String, dynamic> json) {
    return TransactionComponentRule(
      transactionComponentRuleID: json['transactionComponentRuleID'] as int,
      transactionComponentID: json['transactionComponentID'] as int,
      transactionTypeID: json['transactionTypeID'] as int,
      transactionTypeCode: json['transactionTypeCode'] as int,
      transactionTypeName: json['transactionTypeName'] as String,
      transactionTypeIsSystem: json['transactionTypeIsSystem'] as bool,
      transactionTypeIsActive: json['transactionTypeIsActive'] as bool,
      componentCode: json['componentCode'] as String,
      componentName: json['componentName'] as String,
      componentIsRequired: json['componentIsRequired'] as bool,
      componentIsActive: json['componentIsActive'] as bool,
      entrySide: json['entrySide'] as String,
      mainHeadID: json['mainHeadID'] as int,
      mainHeadCode: json['mainHeadCode'] as int,
      mainHeadName: json['mainHeadName'] as String,
      accountingType: json['accountingType'] as String,
      normalBalance: json['normalBalance'] as String,
      subheadID: json['subheadID'] == null ? null : json['subheadID'] as int,
      subheadCode: json['subheadCode'] == null ? null : json['subheadCode'] as int,
      subheadName: json['subheadName'] as String?,
      coaID: json['coaID'] == null ? null : json['coaID'] as int,
      coaCode: json['coaCode'] as String?,
      coaName: json['coaName'] as String?,
      isRequired: json['isRequired'] as bool,
      sequenceNo: json['sequenceNo'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionComponentRule &&
          runtimeType == other.runtimeType &&
          transactionComponentRuleID == other.transactionComponentRuleID;

  @override
  int get hashCode => transactionComponentRuleID.hashCode;
}
