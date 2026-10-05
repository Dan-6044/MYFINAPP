namespace MYFIN.API.DTOs.Reports;

public class CashFlowStatementResponse
{
    public int? FinancialPeriodID { get; set; }
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }

    public decimal TotalCashInflows { get; set; }
    public decimal TotalCashOutflows { get; set; }
    public decimal NetCashMovement { get; set; }
    public string CashFlowStatus { get; set; } = string.Empty;

    public List<CashFlowLineResponse> Lines { get; set; } = new();
    public List<CashAccountBalanceResponse> CashAccounts { get; set; } = new();
}

public class CashFlowLineResponse
{
    public long JournalID { get; set; }
    public string JournalNumber { get; set; } = string.Empty;

    public long TransactionID { get; set; }

    public DateTime JournalDate { get; set; }

    public long JournalLineID { get; set; }
    public int LineSequence { get; set; }

    public long COAID { get; set; }
    public string COACode { get; set; } = string.Empty;
    public string COAName { get; set; } = string.Empty;
    public string CashAccountType { get; set; } = string.Empty;

    public decimal DebitAmount { get; set; }
    public decimal CreditAmount { get; set; }
    public decimal NetCashMovement { get; set; }

    public string? Description { get; set; }
}

public class CashAccountBalanceResponse
{
    public long COAID { get; set; }
    public string COACode { get; set; } = string.Empty;
    public string COAName { get; set; } = string.Empty;
    public string CashAccountType { get; set; } = string.Empty;

    public decimal TotalDebit { get; set; }
    public decimal TotalCredit { get; set; }
    public decimal ClosingBalance { get; set; }
}
