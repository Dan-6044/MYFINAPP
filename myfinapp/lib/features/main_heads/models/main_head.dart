class MainHead {
  final int mainHeadID;
  final int mainHeadCode;
  final String mainHeadName;
  final String accountingType;
  final String normalBalance;
  final String normalBalanceName;
  final bool isActive;
  final int subheadCount;
  final int transactionTypeRuleCount;
  final String createdAt;
  final String? updatedAt;

  const MainHead({
    required this.mainHeadID,
    required this.mainHeadCode,
    required this.mainHeadName,
    required this.accountingType,
    required this.normalBalance,
    required this.normalBalanceName,
    required this.isActive,
    required this.subheadCount,
    required this.transactionTypeRuleCount,
    required this.createdAt,
    this.updatedAt,
  });

  factory MainHead.fromJson(Map<String, dynamic> json) {
    return MainHead(
      mainHeadID: json['mainHeadID'] as int,
      mainHeadCode: json['mainHeadCode'] as int,
      mainHeadName: json['mainHeadName'] as String,
      accountingType: json['accountingType'] as String,
      normalBalance: json['normalBalance'] as String,
      normalBalanceName: json['normalBalanceName'] as String,
      isActive: json['isActive'] as bool,
      subheadCount: json['subheadCount'] as int,
      transactionTypeRuleCount: json['transactionTypeRuleCount'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}
