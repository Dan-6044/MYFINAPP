using System.ComponentModel.DataAnnotations;

namespace MYFIN.API.DTOs.Masters;

public class CreateTransactionComponentRequest
{
    [Range(1, int.MaxValue)]
    public int TransactionTypeID { get; set; }

    [Required]
    [StringLength(30)]
    public string ComponentCode { get; set; } = string.Empty;

    [Required]
    [StringLength(100)]
    public string ComponentName { get; set; } = string.Empty;

    [StringLength(500)]
    public string? Description { get; set; }

    public bool IsRequired { get; set; } = true;

    [Range(1, int.MaxValue)]
    public int SequenceNo { get; set; } = 1;
}
