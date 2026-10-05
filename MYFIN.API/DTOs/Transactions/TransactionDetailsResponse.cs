
namespace MYFIN.API.DTOs.Transactions;

public class TransactionDetailsResponse
{
    public long TransactionID { get; set; }
    public string TransactionNumber { get; set; } = string.Empty;

    public int TransactionTypeID { get; set; }
    public string TransactionTypeCode { get; set; } = string.Empty;
    public string TransactionTypeName { get; set; } = string.Empty;

    public int FinancialPeriodID { get; set; }

    public DateTime TransactionDate { get; set; }

    public string? Description { get; set; }
    public string? ReferenceNumber { get; set; }

    public string Status { get; set; } = string.Empty;

    public int CreatedByUserID { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }

    public DateTime? PostedAt { get; set; }
    public int? PostedByUserID { get; set; }

    public DateTime? VoidedAt { get; set; }
    public int? VoidedByUserID { get; set; }
    public string? VoidReason { get; set; }

    public decimal TotalDebit { get; set; }
    public decimal TotalCredit { get; set; }

    public List<TransactionDetailLineResponse> Lines { get; set; } = new();

    public TransactionJournalResponse? Journal { get; set; }
}

public class TransactionDetailLineResponse
{
    public long TransactionLineID { get; set; }
    public int LineSequence { get; set; }

    public int TransactionComponentID { get; set; }
    public string ComponentCode { get; set; } = string.Empty;
    public string ComponentName { get; set; } = string.Empty;

    public long COAID { get; set; }
    public string COACode { get; set; } = string.Empty;
    public string COAName { get; set; } = string.Empty;

    public decimal DebitAmount { get; set; }
    public decimal CreditAmount { get; set; }

    public string? Description { get; set; }
}

public class TransactionJournalResponse
{
    public long JournalID { get; set; }
    public string JournalNumber { get; set; } = string.Empty;

    public int FinancialPeriodID { get; set; }
    public DateTime JournalDate { get; set; }

    public string? Description { get; set; }
    public string Status { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; }
    public DateTime? PostedAt { get; set; }

    public decimal TotalDebit { get; set; }
    public decimal TotalCredit { get; set; }

    public List<TransactionJournalLineResponse> Lines { get; set; } = new();
}

public class TransactionJournalLineResponse
{
    public long JournalLineID { get; set; }
    public int LineSequence { get; set; }

    public long COAID { get; set; }
    public string COACode { get; set; } = string.Empty;
    public string COAName { get; set; } = string.Empty;

    public decimal DebitAmount { get; set; }
    public decimal CreditAmount { get; set; }

    public string? Description { get; set; }
}
