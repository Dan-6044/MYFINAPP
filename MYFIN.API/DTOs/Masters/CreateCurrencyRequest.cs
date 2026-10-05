
using System.ComponentModel.DataAnnotations;

namespace MYFIN.API.DTOs.Masters;

public class CreateCurrencyRequest
{
    [Required]
    [StringLength(3, MinimumLength = 3)]
    public string CurrencyCode { get; set; } = string.Empty;

    [Required]
    [StringLength(100)]
    public string CurrencyName { get; set; } = string.Empty;

    [StringLength(10)]
    public string? CurrencySymbol { get; set; }

    [Range(0, 6)]
    public byte DecimalPlaces { get; set; } = 2;

    public bool IsBaseCurrency { get; set; } = false;
}

