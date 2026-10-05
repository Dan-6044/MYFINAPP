namespace MYFIN.API.DTOs.Accounts;

public class AccountStatementResponse
{
    public long COAID { get; set; }
    public string COACode { get; set; } = string.Empty;
    public string COAName { get; set; } = string.Empty;

    public int SubheadID { get; set; }
    public int? CurrencyID { get; set; }

    public string? Description { get; set; }
    public bool IsControlAccount { get; set; }
    public bool AllowDirectPosting { get; set; }
    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }

    public decimal OpeningBalance { get; set; }
    public decimal StatementOpeningBalance { get; set; }

    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public int? FinancialPeriodID { get; set; }
    public string? PeriodCode { get; set; }
    public string? PeriodName { get; set; }

    public decimal TotalDebit { get; set; }
    public decimal TotalCredit { get; set; }
    public decimal NetMovement { get; set; }
    public decimal ClosingBalance { get; set; }

    public List<AccountStatementLineResponse> Lines { get; set; } = new();
}

public class AccountStatementLineResponse
{
    public long JournalID { get; set; }
    public string JournalNumber { get; set; } = string.Empty;

    public long TransactionID { get; set; }
    public string TransactionNumber { get; set; } = string.Empty;

    public int TransactionTypeID { get; set; }
    public int TransactionTypeCode { get; set; }
    public string TransactionTypeName { get; set; } = string.Empty;

    public int FinancialPeriodID { get; set; }
    public DateTime JournalDate { get; set; }
    public DateTime? PostedAt { get; set; }

    public long JournalLineID { get; set; }
    public int LineSequence { get; set; }

    public string? Description { get; set; }

    public long COAID { get; set; }
    public string COACode { get; set; } = string.Empty;
    public string COAName { get; set; } = string.Empty;

    public int MainHeadID { get; set; }
    public string MainHeadCode { get; set; } = string.Empty;
    public string MainHeadName { get; set; } = string.Empty;

    public string AccountingType { get; set; } = string.Empty;
    public string NormalBalance { get; set; } = string.Empty;

    public int SubheadID { get; set; }
    public string SubheadCode { get; set; } = string.Empty;
    public string SubheadName { get; set; } = string.Empty;

    public decimal DebitAmount { get; set; }
    public decimal CreditAmount { get; set; }
    public decimal NetMovement { get; set; }
    public decimal RunningBalance { get; set; }
}
