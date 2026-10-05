namespace MYFIN.API.DTOs.Reports;

public class TrialBalanceResponse
{
    public int? FinancialPeriodID { get; set; }

    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }

    public decimal TotalDebit { get; set; }
    public decimal TotalCredit { get; set; }
    public decimal Difference { get; set; }

    public string Status { get; set; } = string.Empty;

    public List<TrialBalanceLineResponse> Lines { get; set; } = new();
}

public class TrialBalanceLineResponse
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