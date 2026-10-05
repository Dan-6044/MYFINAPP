namespace MYFIN.API.DTOs.Transactions;

public class CreateTransactionResponse
{
    public long TransactionID { get; set; }

    public string TransactionNumber { get; set; } = string.Empty;

    public int TransactionTypeID { get; set; }

    public string TransactionTypeCode { get; set; } = string.Empty;

    public string TransactionTypeName { get; set; } = string.Empty;

    public int FinancialPeriodID { get; set; }

    public string PeriodCode { get; set; } = string.Empty;

    public DateTime TransactionDate { get; set; }

    public string? Description { get; set; }

    public string? ReferenceNumber { get; set; }

    public string Status { get; set; } = string.Empty;

    public int CreatedByUserID { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public DateTime? PostedAt { get; set; }

    public List<CreateTransactionLineResponse> Lines { get; set; } = new();
}

public class CreateTransactionLineResponse
{
    public long TransactionLineID { get; set; }

    public long TransactionID { get; set; }

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