using System.ComponentModel.DataAnnotations;

namespace MYFIN.API.DTOs.Masters;

public class UpdateAccountRequest
{
    [Required]
    [StringLength(30)]
    public string COACode { get; set; } = string.Empty;

    [Required]
    [StringLength(150)]
    public string COAName { get; set; } = string.Empty;

    [Required]
    public int SubheadID { get; set; }

    public int? CurrencyID { get; set; }

    [StringLength(500)]
    public string? Description { get; set; }

    public bool IsControlAccount { get; set; }

    public bool AllowDirectPosting { get; set; }

    public decimal OpeningBalance { get; set; }
}