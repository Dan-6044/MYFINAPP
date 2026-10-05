using System.ComponentModel.DataAnnotations;

namespace MYFIN.API.DTOs.FinancialPeriods;

public class CreateFinancialPeriodRequest
{
    [Required]
    [StringLength(
        20,
        MinimumLength = 1,
        ErrorMessage = "PeriodCode must be between 1 and 20 characters.")]
    public string PeriodCode { get; set; } = string.Empty;

    [Required]
    [StringLength(
        100,
        MinimumLength = 1,
        ErrorMessage = "PeriodName must be between 1 and 100 characters.")]
    public string PeriodName { get; set; } = string.Empty;

    [Required]
    public DateTime StartDate { get; set; }

    [Required]
    public DateTime EndDate { get; set; }

    [Required]
    [Range(
        1,
        int.MaxValue,
        ErrorMessage = "UserID must be greater than zero.")]
    public int UserID { get; set; }

    public bool IsCurrent { get; set; } = true;
}