
using System.ComponentModel.DataAnnotations;

namespace MYFIN.API.DTOs.Masters;

public class CreateMainHeadRequest
{
    [Required]
    public int MainHeadCode { get; set; }

    [Required]
    [StringLength(100)]
    public string MainHeadName { get; set; } = string.Empty;

    [Required]
    [StringLength(20)]
    public string AccountingType { get; set; } = string.Empty;

    [Required]
    [StringLength(1)]
    public string NormalBalance { get; set; } = string.Empty;
}

