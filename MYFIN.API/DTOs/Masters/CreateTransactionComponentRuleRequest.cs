using System.ComponentModel.DataAnnotations;

namespace MYFIN.API.DTOs.Masters;

public class CreateTransactionComponentRuleRequest
{
    [Range(1, int.MaxValue)]
    public int TransactionComponentID { get; set; }

    [Required]
    [RegularExpression(
        "^[DdCc]$",
        ErrorMessage = "EntrySide must be D or C.")]
    public string EntrySide { get; set; } = string.Empty;

    [Range(1, int.MaxValue)]
    public int MainHeadID { get; set; }

    public int? SubheadID { get; set; }

    public long? COAID { get; set; }

    public bool IsRequired { get; set; } = true;

    [Range(1, int.MaxValue)]
    public int SequenceNo { get; set; } = 1;
}