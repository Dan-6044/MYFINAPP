using System.ComponentModel.DataAnnotations;

namespace MYFIN.API.DTOs.Masters;

public class CreateTransactionTypeRuleRequest
{
    [Range(1, int.MaxValue)]
    public int TransactionTypeID { get; set; }

    [Required]
    [RegularExpression(
        "^[DdCc]$",
        ErrorMessage = "EntrySide must be D or C.")]
    public string EntrySide { get; set; } = string.Empty;

    [Range(1, int.MaxValue)]
    public int MainHeadID { get; set; }

    [Range(1, int.MaxValue)]
    public int SequenceNo { get; set; } = 1;

    public bool IsRequired { get; set; } = true;
}