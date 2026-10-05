class TransactionType {
  final int transactionTypeID;
  final int transactionTypeCode;
  final String transactionTypeName;
  final String? description;
  final bool isSystem;
  final bool isActive;
  final int ruleCount;
  final int componentCount;
  final int transactionCount;
  final String createdAt;
  final String? updatedAt;

  const TransactionType({
    required this.transactionTypeID,
    required this.transactionTypeCode,
    required this.transactionTypeName,
    this.description,
    required this.isSystem,
    required this.isActive,
    required this.ruleCount,
    required this.componentCount,
    required this.transactionCount,
    required this.createdAt,
    this.updatedAt,
  });

  factory TransactionType.fromJson(Map<String, dynamic> json) {
    return TransactionType(
      transactionTypeID: json['transactionTypeID'] as int,
      transactionTypeCode: json['transactionTypeCode'] as int,
      transactionTypeName: json['transactionTypeName'] as String,
      description: json['description'] as String?,
      isSystem: json['isSystem'] as bool,
      isActive: json['isActive'] as bool,
      ruleCount: json['ruleCount'] as int,
      componentCount: json['componentCount'] as int,
      transactionCount: json['transactionCount'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}
