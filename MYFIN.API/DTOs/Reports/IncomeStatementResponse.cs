namespace MYFIN.API.DTOs.Reports;

public class IncomeStatementResponse
{
    public int? FinancialPeriodID { get; set; }

    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }

    public decimal TotalIncome { get; set; }
    public decimal TotalExpenses { get; set; }
    public decimal NetIncome { get; set; }

    public string ResultStatus { get; set; } = string.Empty;

    public List<IncomeStatementLineResponse> Lines { get; set; } = new();
}

public class IncomeStatementLineResponse
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

    public decimal NetBalance { get; set; }
    public decimal StatementBalance { get; set; }
}