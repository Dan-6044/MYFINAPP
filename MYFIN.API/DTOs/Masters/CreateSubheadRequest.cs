
using System.ComponentModel.DataAnnotations;

namespace MYFIN.API.DTOs.Masters;

public class CreateSubheadRequest
{
    [Required]
    public int SubheadCode { get; set; }

    [Required]
    [StringLength(100)]
    public string SubheadName { get; set; } = string.Empty;

    [Required]
    public int MainHeadID { get; set; }
}

