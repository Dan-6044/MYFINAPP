namespace MYFIN.API.DTOs.Reports;

public class BalanceSheetResponse
{
    public int? FinancialPeriodID { get; set; }
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }

    public decimal TotalAssets { get; set; }
    public decimal TotalLiabilities { get; set; }
    public decimal Capital { get; set; }
    public decimal CurrentPeriodNetIncome { get; set; }
    public decimal TotalEquity { get; set; }
    public decimal BalanceDifference { get; set; }
    public string BalanceSheetStatus { get; set; } = string.Empty;

    public List<BalanceSheetLineResponse> Lines { get; set; } = new();
}

public class BalanceSheetLineResponse
{
    public long COAID { get; set; }
    public string COACode { get; set; } = string.Empty;
    public string COAName { get; set; } = string.Empty;

    public int MainHeadID { get; set; }
    public int MainHeadCode { get; set; }
    public string MainHeadName { get; set; } = string.Empty;

    public string AccountingType { get; set; } = string.Empty;
    public string NormalBalance { get; set; } = string.Empty;

    public int SubheadID { get; set; }
    public int SubheadCode { get; set; }
    public string SubheadName { get; set; } = string.Empty;

    public decimal TotalDebit { get; set; }
    public decimal TotalCredit { get; set; }
    public decimal Balance { get; set; }
}