class FinancialPeriod {
  final int financialPeriodID;
  final String periodCode;
  final String periodName;
  final String startDate;
  final String endDate;
  final String status;
  final String createdAt;
  final String? closedAt;
  final int userID;
  final bool isCurrent;
  final String openedAt;
  final int? closedBy;
  final String? updatedAt;

  const FinancialPeriod({
    required this.financialPeriodID,
    required this.periodCode,
    required this.periodName,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    this.closedAt,
    required this.userID,
    required this.isCurrent,
    required this.openedAt,
    this.closedBy,
    this.updatedAt,
  });

  factory FinancialPeriod.fromJson(Map<String, dynamic> json) {
    return FinancialPeriod(
      financialPeriodID: json['financialPeriodID'] as int,
      periodCode: json['periodCode'] as String,
      periodName: json['periodName'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      closedAt: json['closedAt'] as String?,
      userID: json['userID'] as int,
      isCurrent: json['isCurrent'] as bool,
      openedAt: json['openedAt'] as String,
      closedBy: json['closedBy'] as int?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}
