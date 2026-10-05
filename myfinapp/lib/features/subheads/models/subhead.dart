class Subhead {
  final int subheadID;
  final int subheadCode;
  final String subheadName;
  final MainHeadInfo mainHead;
  final bool isActive;
  final int accountCount;
  final int componentRuleCount;
  final String createdAt;
  final String? updatedAt;

  const Subhead({
    required this.subheadID,
    required this.subheadCode,
    required this.subheadName,
    required this.mainHead,
    required this.isActive,
    required this.accountCount,
    required this.componentRuleCount,
    required this.createdAt,
    this.updatedAt,
  });

  factory Subhead.fromJson(Map<String, dynamic> json) {
    return Subhead(
      subheadID: json['subheadID'] as int,
      subheadCode: json['subheadCode'] as int,
      subheadName: json['subheadName'] as String,
      mainHead: MainHeadInfo.fromJson(json['mainHead'] as Map<String, dynamic>),
      isActive: json['isActive'] as bool,
      accountCount: json['accountCount'] as int,
      componentRuleCount: json['componentRuleCount'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class MainHeadInfo {
  final int mainHeadID;
  final int mainHeadCode;
  final String mainHeadName;
  final String accountingType;
  final String normalBalance;
  final String normalBalanceName;

  const MainHeadInfo({
    required this.mainHeadID,
    required this.mainHeadCode,
    required this.mainHeadName,
    required this.accountingType,
    required this.normalBalance,
    required this.normalBalanceName,
  });

  factory MainHeadInfo.fromJson(Map<String, dynamic> json) {
    return MainHeadInfo(
      mainHeadID: json['mainHeadID'] as int,
      mainHeadCode: json['mainHeadCode'] as int,
      mainHeadName: json['mainHeadName'] as String,
      accountingType: json['accountingType'] as String,
      normalBalance: json['normalBalance'] as String,
      normalBalanceName: json['normalBalanceName'] as String,
    );
  }
}
