namespace MYFIN.API.DTOs.Masters;

public class AccountResponse
{
    public long COAID { get; set; }

    public string COACode { get; set; } = string.Empty;

    public string COAName { get; set; } = string.Empty;

    public SubheadInfo Subhead { get; set; } = new();

    public MainHeadInfo MainHead { get; set; } = new();

    public CurrencyInfo? Currency { get; set; }

    public string? Description { get; set; }

    public bool IsControlAccount { get; set; }

    public bool AllowDirectPosting { get; set; }

    public bool IsActive { get; set; }

    public decimal OpeningBalance { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }
}

public class SubheadInfo
{
    public int SubheadID { get; set; }

    public int SubheadCode { get; set; }

    public string SubheadName { get; set; } = string.Empty;
}

public class CurrencyInfo
{
    public int CurrencyID { get; set; }

    public string CurrencyCode { get; set; } = string.Empty;

    public string CurrencyName { get; set; } = string.Empty;

    public string? CurrencySymbol { get; set; }

    public byte DecimalPlaces { get; set; }
}


public class MainHeadInfo
{
    public int MainHeadID { get; set; }
    public int MainHeadCode { get; set; }
    public string MainHeadName { get; set; } = string.Empty;
    public string AccountingType { get; set; } = string.Empty;
    public string NormalBalance { get; set; } = string.Empty;
    public string NormalBalanceName { get; set; } = string.Empty;
}

