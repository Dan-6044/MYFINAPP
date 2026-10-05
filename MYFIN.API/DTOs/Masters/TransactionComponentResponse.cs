namespace MYFIN.API.DTOs.Masters;

public class TransactionComponentResponse
{
    public int TransactionComponentID { get; set; }

    public int TransactionTypeID { get; set; }
    public int TransactionTypeCode { get; set; }
    public string TransactionTypeName { get; set; } = string.Empty;

    public string ComponentCode { get; set; } = string.Empty;
    public string ComponentName { get; set; } = string.Empty;
    public string? Description { get; set; }

    public bool IsRequired { get; set; }
    public bool IsActive { get; set; }
    public int SequenceNo { get; set; }

    public bool TransactionTypeIsSystem { get; set; }

    public int RuleCount { get; set; }
    public int TransactionLineCount { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}
