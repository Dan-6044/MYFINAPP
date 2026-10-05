
namespace MYFIN.API.DTOs.Masters;

public class CurrencyResponse
{
    public int CurrencyID { get; set; }

    public string CurrencyCode { get; set; } = string.Empty;

    public string CurrencyName { get; set; } = string.Empty;

    public string? CurrencySymbol { get; set; }

    public byte DecimalPlaces { get; set; }

    public bool IsBaseCurrency { get; set; }

    public bool IsActive { get; set; }

    public int AccountCount { get; set; }

    public DateTime CreatedAt { get; set; }
}

