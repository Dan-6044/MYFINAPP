class TransactionListModel {
  final int page;
  final int pageSize;
  final int totalRecords;
  final int totalPages;
  final List<TransactionListItemModel> transactions;

  const TransactionListModel({
    required this.page,
    required this.pageSize,
    required this.totalRecords,
    required this.totalPages,
    required this.transactions,
  });

  factory TransactionListModel.fromJson(Map<String, dynamic> json) {
    return TransactionListModel(
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      totalRecords: json['totalRecords'] as int,
      totalPages: json['totalPages'] as int,
      transactions: (json['transactions'] as List<dynamic>)
          .map((e) => TransactionListItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TransactionListItemModel {
  final int transactionId;
  final String transactionNumber;
  final int transactionTypeId;
  final String transactionTypeCode;
  final String transactionTypeName;
  final int financialPeriodId;
  final DateTime transactionDate;
  final String? description;
  final String? referenceNumber;
  final String status;
  final int createdByUserId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? postedAt;
  final int? postedByUserId;
  final DateTime? voidedAt;
  final int? voidedByUserId;
  final String? voidReason;
  final double totalDebit;
  final double totalCredit;

  const TransactionListItemModel({
    required this.transactionId,
    required this.transactionNumber,
    required this.transactionTypeId,
    required this.transactionTypeCode,
    required this.transactionTypeName,
    required this.financialPeriodId,
    required this.transactionDate,
    this.description,
    this.referenceNumber,
    required this.status,
    required this.createdByUserId,
    required this.createdAt,
    this.updatedAt,
    this.postedAt,
    this.postedByUserId,
    this.voidedAt,
    this.voidedByUserId,
    this.voidReason,
    required this.totalDebit,
    required this.totalCredit,
  });

  factory TransactionListItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionListItemModel(
      transactionId: json['transactionID'] as int,
      transactionNumber: json['transactionNumber'] as String,
      transactionTypeId: json['transactionTypeID'] as int,
      transactionTypeCode: json['transactionTypeCode'] as String,
      transactionTypeName: json['transactionTypeName'] as String,
      financialPeriodId: json['financialPeriodID'] as int,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      description: json['description'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
      status: json['status'] as String,
      createdByUserId: json['createdByUserID'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt'] as String),
      postedAt: json['postedAt'] == null ? null : DateTime.parse(json['postedAt'] as String),
      postedByUserId: json['postedByUserID'] as int?,
      voidedAt: json['voidedAt'] == null ? null : DateTime.parse(json['voidedAt'] as String),
      voidedByUserId: json['voidedByUserID'] as int?,
      voidReason: json['voidReason'] as String?,
      totalDebit: (json['totalDebit'] as num).toDouble(),
      totalCredit: (json['totalCredit'] as num).toDouble(),
    );
  }
}

class TransactionDetailModel {
  final int transactionId;
  final String transactionNumber;
  final int transactionTypeId;
  final String transactionTypeCode;
  final String transactionTypeName;
  final int financialPeriodId;
  final DateTime transactionDate;
  final String? description;
  final String? referenceNumber;
  final String status;
  final int createdByUserId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? postedAt;
  final int? postedByUserId;
  final DateTime? voidedAt;
  final int? voidedByUserId;
  final String? voidReason;
  final double totalDebit;
  final double totalCredit;
  final List<TransactionDetailLineModel> lines;
  final TransactionJournalModel? journal;

  const TransactionDetailModel({
    required this.transactionId,
    required this.transactionNumber,
    required this.transactionTypeId,
    required this.transactionTypeCode,
    required this.transactionTypeName,
    required this.financialPeriodId,
    required this.transactionDate,
    this.description,
    this.referenceNumber,
    required this.status,
    required this.createdByUserId,
    required this.createdAt,
    this.updatedAt,
    this.postedAt,
    this.postedByUserId,
    this.voidedAt,
    this.voidedByUserId,
    this.voidReason,
    required this.totalDebit,
    required this.totalCredit,
    required this.lines,
    this.journal,
  });

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) {
    return TransactionDetailModel(
      transactionId: json['transactionID'] as int,
      transactionNumber: json['transactionNumber'] as String,
      transactionTypeId: json['transactionTypeID'] as int,
      transactionTypeCode: json['transactionTypeCode'] as String,
      transactionTypeName: json['transactionTypeName'] as String,
      financialPeriodId: json['financialPeriodID'] as int,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      description: json['description'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
      status: json['status'] as String,
      createdByUserId: json['createdByUserID'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt'] as String),
      postedAt: json['postedAt'] == null ? null : DateTime.parse(json['postedAt'] as String),
      postedByUserId: json['postedByUserID'] as int?,
      voidedAt: json['voidedAt'] == null ? null : DateTime.parse(json['voidedAt'] as String),
      voidedByUserId: json['voidedByUserID'] as int?,
      voidReason: json['voidReason'] as String?,
      totalDebit: (json['totalDebit'] as num).toDouble(),
      totalCredit: (json['totalCredit'] as num).toDouble(),
      lines: (json['lines'] as List<dynamic>)
          .map((e) => TransactionDetailLineModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      journal: json['journal'] == null
          ? null
          : TransactionJournalModel.fromJson(json['journal'] as Map<String, dynamic>),
    );
  }
}

class TransactionDetailLineModel {
  final int transactionLineId;
  final int lineSequence;
  final int transactionComponentId;
  final String componentCode;
  final String componentName;
  final int coaId;
  final String coaCode;
  final String coaName;
  final double debitAmount;
  final double creditAmount;
  final String? description;

  const TransactionDetailLineModel({
    required this.transactionLineId,
    required this.lineSequence,
    required this.transactionComponentId,
    required this.componentCode,
    required this.componentName,
    required this.coaId,
    required this.coaCode,
    required this.coaName,
    required this.debitAmount,
    required this.creditAmount,
    this.description,
  });

  factory TransactionDetailLineModel.fromJson(Map<String, dynamic> json) {
    return TransactionDetailLineModel(
      transactionLineId: json['transactionLineID'] as int,
      lineSequence: json['lineSequence'] as int,
      transactionComponentId: json['transactionComponentID'] as int,
      componentCode: json['componentCode'] as String,
      componentName: json['componentName'] as String,
      coaId: json['coaId'] as int,
      coaCode: json['coaCode'] as String,
      coaName: json['coaName'] as String,
      debitAmount: (json['debitAmount'] as num).toDouble(),
      creditAmount: (json['creditAmount'] as num).toDouble(),
      description: json['description'] as String?,
    );
  }
}

class TransactionJournalModel {
  final int journalId;
  final String journalNumber;
  final int financialPeriodId;
  final DateTime journalDate;
  final String? description;
  final String status;
  final DateTime createdAt;
  final DateTime? postedAt;
  final double totalDebit;
  final double totalCredit;
  final List<TransactionJournalLineModel> lines;

  const TransactionJournalModel({
    required this.journalId,
    required this.journalNumber,
    required this.financialPeriodId,
    required this.journalDate,
    this.description,
    required this.status,
    required this.createdAt,
    this.postedAt,
    required this.totalDebit,
    required this.totalCredit,
    required this.lines,
  });

  factory TransactionJournalModel.fromJson(Map<String, dynamic> json) {
    return TransactionJournalModel(
      journalId: json['journalID'] as int,
      journalNumber: json['journalNumber'] as String,
      financialPeriodId: json['financialPeriodID'] as int,
      journalDate: DateTime.parse(json['journalDate'] as String),
      description: json['description'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      postedAt: json['postedAt'] == null ? null : DateTime.parse(json['postedAt'] as String),
      totalDebit: (json['totalDebit'] as num).toDouble(),
      totalCredit: (json['totalCredit'] as num).toDouble(),
      lines: (json['lines'] as List<dynamic>)
          .map((e) => TransactionJournalLineModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TransactionJournalLineModel {
  final int journalLineId;
  final int lineSequence;
  final int coaId;
  final String coaCode;
  final String coaName;
  final double debitAmount;
  final double creditAmount;
  final String? description;

  const TransactionJournalLineModel({
    required this.journalLineId,
    required this.lineSequence,
    required this.coaId,
    required this.coaCode,
    required this.coaName,
    required this.debitAmount,
    required this.creditAmount,
    this.description,
  });

  factory TransactionJournalLineModel.fromJson(Map<String, dynamic> json) {
    return TransactionJournalLineModel(
      journalLineId: json['journalLineID'] as int,
      lineSequence: json['lineSequence'] as int,
      coaId: json['coaId'] as int,
      coaCode: json['coaCode'] as String,
      coaName: json['coaName'] as String,
      debitAmount: (json['debitAmount'] as num).toDouble(),
      creditAmount: (json['creditAmount'] as num).toDouble(),
      description: json['description'] as String?,
    );
  }
}

class CreateTransactionRequestModel {
  final int transactionTypeId;
  final int financialPeriodId;
  final DateTime transactionDate;
  final String description;
  final String? referenceNumber;
  final int createdByUserId;
  final List<TransactionLineRequestModel> lines;

  const CreateTransactionRequestModel({
    required this.transactionTypeId,
    required this.financialPeriodId,
    required this.transactionDate,
    required this.description,
    this.referenceNumber,
    required this.createdByUserId,
    required this.lines,
  });

  Map<String, dynamic> toJson() {
    return {
      'transactionTypeID': transactionTypeId,
      'financialPeriodID': financialPeriodId,
      'transactionDate': transactionDate.toIso8601String(),
      'description': description,
      if (referenceNumber != null) 'referenceNumber': referenceNumber,
      'createdByUserID': createdByUserId,
      'lines': lines.map((e) => e.toJson()).toList(),
    };
  }
}

class TransactionLineRequestModel {
  final String componentCode;
  final String entrySide;
  final int coaId;
  final double amount;
  final String? description;

  const TransactionLineRequestModel({
    required this.componentCode,
    required this.entrySide,
    required this.coaId,
    required this.amount,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'componentCode': componentCode,
      'entrySide': entrySide,
      'coaid': coaId,
      'amount': amount,
      if (description != null) 'description': description,
    };
  }

  TransactionLineRequestModel copyWith({
    String? componentCode,
    String? entrySide,
    int? coaId,
    double? amount,
    String? description,
  }) {
    return TransactionLineRequestModel(
      componentCode: componentCode ?? this.componentCode,
      entrySide: entrySide ?? this.entrySide,
      coaId: coaId ?? this.coaId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
    );
  }
}

class CreateTransactionResponseModel {
  final int transactionId;
  final String transactionNumber;
  final int transactionTypeId;
  final String transactionTypeCode;
  final String transactionTypeName;
  final int financialPeriodId;
  final String periodCode;
  final DateTime transactionDate;
  final String? description;
  final String? referenceNumber;
  final String status;
  final int createdByUserId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? postedAt;
  final List<CreateTransactionLineResponseModel> lines;

  const CreateTransactionResponseModel({
    required this.transactionId,
    required this.transactionNumber,
    required this.transactionTypeId,
    required this.transactionTypeCode,
    required this.transactionTypeName,
    required this.financialPeriodId,
    required this.periodCode,
    required this.transactionDate,
    this.description,
    this.referenceNumber,
    required this.status,
    required this.createdByUserId,
    required this.createdAt,
    this.updatedAt,
    this.postedAt,
    required this.lines,
  });

  factory CreateTransactionResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic linesRaw = json['lines'];
    final List<dynamic> linesList = linesRaw is List<dynamic>
        ? linesRaw
        : const <dynamic>[];

    return CreateTransactionResponseModel(
      transactionId: json['transactionID'] as int,
      transactionNumber: json['transactionNumber'] as String,
      transactionTypeId: json['transactionTypeID'] as int,
      transactionTypeCode: json['transactionTypeCode'] as String,
      transactionTypeName: json['transactionTypeName'] as String,
      financialPeriodId: json['financialPeriodID'] as int,
      periodCode: json['periodCode'] as String,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      description: json['description'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
      status: json['status'] as String,
      createdByUserId: json['createdByUserID'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt'] as String),
      postedAt: json['postedAt'] == null ? null : DateTime.parse(json['postedAt'] as String),
      lines: linesList
          .map((e) => CreateTransactionLineResponseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CreateTransactionLineResponseModel {
  final int transactionLineId;
  final int transactionId;
  final int lineSequence;
  final int transactionComponentId;
  final String componentCode;
  final String componentName;
  final int coaId;
  final String coaCode;
  final String coaName;
  final double debitAmount;
  final double creditAmount;
  final String? description;

  const CreateTransactionLineResponseModel({
    required this.transactionLineId,
    required this.transactionId,
    required this.lineSequence,
    required this.transactionComponentId,
    required this.componentCode,
    required this.componentName,
    required this.coaId,
    required this.coaCode,
    required this.coaName,
    required this.debitAmount,
    required this.creditAmount,
    this.description,
  });

  factory CreateTransactionLineResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateTransactionLineResponseModel(
      transactionLineId: json['transactionLineID'] as int,
      transactionId: json['transactionID'] as int,
      lineSequence: json['lineSequence'] as int,
      transactionComponentId: json['transactionComponentID'] as int,
      componentCode: json['componentCode'] as String,
      componentName: json['componentName'] as String,
      coaId: json['coaID'] as int,
      coaCode: json['coaCode'] as String,
      coaName: json['coaName'] as String,
      debitAmount: (json['debitAmount'] as num).toDouble(),
      creditAmount: (json['creditAmount'] as num).toDouble(),
      description: json['description'] as String?,
    );
  }
}

class ValidateTransactionResponseModel {
  final int transactionId;
  final String transactionNumber;
  final int transactionTypeId;
  final String transactionTypeCode;
  final String transactionTypeName;
  final int financialPeriodId;
  final DateTime transactionDate;
  final String status;
  final double totalDebit;
  final double totalCredit;
  final String message;

  const ValidateTransactionResponseModel({
    required this.transactionId,
    required this.transactionNumber,
    required this.transactionTypeId,
    required this.transactionTypeCode,
    required this.transactionTypeName,
    required this.financialPeriodId,
    required this.transactionDate,
    required this.status,
    required this.totalDebit,
    required this.totalCredit,
    required this.message,
  });

  factory ValidateTransactionResponseModel.fromJson(Map<String, dynamic> json) {
    return ValidateTransactionResponseModel(
      transactionId: json['transactionID'] as int,
      transactionNumber: json['transactionNumber'] as String,
      transactionTypeId: json['transactionTypeID'] as int,
      transactionTypeCode: json['transactionTypeCode'] as String,
      transactionTypeName: json['transactionTypeName'] as String,
      financialPeriodId: json['financialPeriodID'] as int,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      status: json['status'] as String,
      totalDebit: (json['totalDebit'] as num).toDouble(),
      totalCredit: (json['totalCredit'] as num).toDouble(),
      message: json['message'] as String,
    );
  }
}

class PostTransactionResponseModel {
  final int transactionId;
  final String transactionNumber;
  final String transactionStatus;
  final int journalId;
  final String journalNumber;
  final String journalStatus;
  final int financialPeriodId;
  final DateTime journalDate;
  final DateTime postedAt;
  final double totalDebit;
  final double totalCredit;
  final String message;

  const PostTransactionResponseModel({
    required this.transactionId,
    required this.transactionNumber,
    required this.transactionStatus,
    required this.journalId,
    required this.journalNumber,
    required this.journalStatus,
    required this.financialPeriodId,
    required this.journalDate,
    required this.postedAt,
    required this.totalDebit,
    required this.totalCredit,
    required this.message,
  });

  factory PostTransactionResponseModel.fromJson(Map<String, dynamic> json) {
    return PostTransactionResponseModel(
      transactionId: json['transactionID'] as int,
      transactionNumber: json['transactionNumber'] as String,
      transactionStatus: json['transactionStatus'] as String,
      journalId: json['journalID'] as int,
      journalNumber: json['journalNumber'] as String,
      journalStatus: json['journalStatus'] as String,
      financialPeriodId: json['financialPeriodID'] as int,
      journalDate: DateTime.parse(json['journalDate'] as String),
      postedAt: DateTime.parse(json['postedAt'] as String),
      totalDebit: (json['totalDebit'] as num).toDouble(),
      totalCredit: (json['totalCredit'] as num).toDouble(),
      message: json['message'] as String,
    );
  }
}

class VoidTransactionResponseModel {
  final int transactionId;
  final String status;
  final DateTime voidedAt;
  final int voidedByUserId;
  final String voidReason;
  final int? originalJournalId;
  final int? reversalJournalId;
  final String? reversalJournalNumber;
  final String message;

  const VoidTransactionResponseModel({
    required this.transactionId,
    required this.status,
    required this.voidedAt,
    required this.voidedByUserId,
    required this.voidReason,
    this.originalJournalId,
    this.reversalJournalId,
    this.reversalJournalNumber,
    required this.message,
  });

  factory VoidTransactionResponseModel.fromJson(Map<String, dynamic> json) {
    return VoidTransactionResponseModel(
      transactionId: json['transactionID'] as int,
      status: json['status'] as String,
      voidedAt: DateTime.parse(json['voidedAt'] as String),
      voidedByUserId: json['voidedByUserID'] as int,
      voidReason: json['voidReason'] as String,
      originalJournalId: json['originalJournalID'] == null ? null : json['originalJournalID'] as int,
      reversalJournalId: json['reversalJournalID'] == null ? null : json['reversalJournalID'] as int,
      reversalJournalNumber: json['reversalJournalNumber'] as String?,
      message: json['message'] as String,
    );
  }
}

class JournalListModel {
  final int page;
  final int pageSize;
  final int totalRecords;
  final int totalPages;
  final List<JournalListItemModel> journals;

  const JournalListModel({
    required this.page,
    required this.pageSize,
    required this.totalRecords,
    required this.totalPages,
    required this.journals,
  });

  factory JournalListModel.fromJson(Map<String, dynamic> json) {
    return JournalListModel(
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      totalRecords: json['totalRecords'] as int,
      totalPages: json['totalPages'] as int,
      journals: (json['journals'] as List<dynamic>)
          .map((e) => JournalListItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class JournalListItemModel {
  final int journalId;
  final String journalNumber;
  final int transactionId;
  final String transactionNumber;
  final int transactionTypeId;
  final String transactionTypeCode;
  final String transactionTypeName;
  final int financialPeriodId;
  final DateTime journalDate;
  final String? description;
  final String status;
  final DateTime createdAt;
  final DateTime? postedAt;
  final double totalDebit;
  final double totalCredit;
  final List<JournalLineModel> lines;

  const JournalListItemModel({
    required this.journalId,
    required this.journalNumber,
    required this.transactionId,
    required this.transactionNumber,
    required this.transactionTypeId,
    required this.transactionTypeCode,
    required this.transactionTypeName,
    required this.financialPeriodId,
    required this.journalDate,
    this.description,
    required this.status,
    required this.createdAt,
    this.postedAt,
    required this.totalDebit,
    required this.totalCredit,
    required this.lines,
  });

  factory JournalListItemModel.fromJson(Map<String, dynamic> json) {
    return JournalListItemModel(
      journalId: json['journalID'] as int,
      journalNumber: json['journalNumber'] as String,
      transactionId: json['transactionID'] as int,
      transactionNumber: json['transactionNumber'] as String,
      transactionTypeId: json['transactionTypeID'] as int,
      transactionTypeCode: json['transactionTypeCode'] as String,
      transactionTypeName: json['transactionTypeName'] as String,
      financialPeriodId: json['financialPeriodID'] as int,
      journalDate: DateTime.parse(json['journalDate'] as String),
      description: json['description'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      postedAt: json['postedAt'] == null ? null : DateTime.parse(json['postedAt'] as String),
      totalDebit: (json['totalDebit'] as num).toDouble(),
      totalCredit: (json['totalCredit'] as num).toDouble(),
      lines: (json['lines'] as List<dynamic>? ?? const <dynamic>[])
          .map((e) => JournalLineModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class JournalDetailModel {
  final int journalId;
  final String journalNumber;
  final int transactionId;
  final String transactionNumber;
  final int transactionTypeId;
  final String transactionTypeCode;
  final String transactionTypeName;
  final int financialPeriodId;
  final DateTime journalDate;
  final String? description;
  final String status;
  final DateTime createdAt;
  final DateTime? postedAt;
  final double totalDebit;
  final double totalCredit;
  final List<JournalLineModel> lines;

  const JournalDetailModel({
    required this.journalId,
    required this.journalNumber,
    required this.transactionId,
    required this.transactionNumber,
    required this.transactionTypeId,
    required this.transactionTypeCode,
    required this.transactionTypeName,
    required this.financialPeriodId,
    required this.journalDate,
    this.description,
    required this.status,
    required this.createdAt,
    this.postedAt,
    required this.totalDebit,
    required this.totalCredit,
    required this.lines,
  });

  factory JournalDetailModel.fromJson(Map<String, dynamic> json) {
    return JournalDetailModel(
      journalId: json['journalID'] as int,
      journalNumber: json['journalNumber'] as String,
      transactionId: json['transactionID'] as int,
      transactionNumber: json['transactionNumber'] as String,
      transactionTypeId: json['transactionTypeID'] as int,
      transactionTypeCode: json['transactionTypeCode'] as String,
      transactionTypeName: json['transactionTypeName'] as String,
      financialPeriodId: json['financialPeriodID'] as int,
      journalDate: DateTime.parse(json['journalDate'] as String),
      description: json['description'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      postedAt: json['postedAt'] == null ? null : DateTime.parse(json['postedAt'] as String),
      totalDebit: (json['totalDebit'] as num).toDouble(),
      totalCredit: (json['totalCredit'] as num).toDouble(),
      lines: (json['lines'] as List<dynamic>)
          .map((e) => JournalLineModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class JournalLineModel {
  final int journalLineId;
  final int lineSequence;
  final int coaId;
  final String coaCode;
  final String coaName;
  final double debitAmount;
  final double creditAmount;
  final String? description;

  const JournalLineModel({
    required this.journalLineId,
    required this.lineSequence,
    required this.coaId,
    required this.coaCode,
    required this.coaName,
    required this.debitAmount,
    required this.creditAmount,
    this.description,
  });

  factory JournalLineModel.fromJson(Map<String, dynamic> json) {
    return JournalLineModel(
      journalLineId: json['journalLineID'] as int,
      lineSequence: json['lineSequence'] as int,
      coaId: json['coaid'] as int,
      coaCode: json['coaCode'] as String,
      coaName: json['coaName'] as String,
      debitAmount: (json['debitAmount'] as num).toDouble(),
      creditAmount: (json['creditAmount'] as num).toDouble(),
      description: json['description'] as String?,
    );
  }
}

