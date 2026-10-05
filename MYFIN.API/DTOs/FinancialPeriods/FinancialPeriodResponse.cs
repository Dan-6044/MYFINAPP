namespace MYFIN.API.DTOs.FinancialPeriods;

public class FinancialPeriodResponse
{
    public int FinancialPeriodID { get; set; }

    public string PeriodCode { get; set; } = string.Empty;

    public string PeriodName { get; set; } = string.Empty;

    public DateTime StartDate { get; set; }

    public DateTime EndDate { get; set; }

    public string Status { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; }

    public DateTime? ClosedAt { get; set; }

    public int UserID { get; set; }

    public bool IsCurrent { get; set; }

    public DateTime OpenedAt { get; set; }

    public int? ClosedBy { get; set; }

    public DateTime? UpdatedAt { get; set; }
}