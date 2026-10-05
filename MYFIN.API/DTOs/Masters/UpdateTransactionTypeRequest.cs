using System.ComponentModel.DataAnnotations;

namespace MYFIN.API.DTOs.Masters;

public class UpdateTransactionTypeRequest
{
    [Required]
    public int TransactionTypeCode { get; set; }

    [Required]
    [StringLength(100)]
    public string TransactionTypeName { get; set; } = string.Empty;

    [StringLength(500)]
    public string? Description { get; set; }
}
