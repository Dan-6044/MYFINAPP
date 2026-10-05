namespace MYFIN.API.DTOs.Masters;

public class TransactionTypeResponse
{
    public int TransactionTypeID { get; set; }
    public int TransactionTypeCode { get; set; }
    public string TransactionTypeName { get; set; } = string.Empty;
    public string? Description { get; set; }

    public bool IsSystem { get; set; }
    public bool IsActive { get; set; }

    public int RuleCount { get; set; }
    public int ComponentCount { get; set; }
    public int TransactionCount { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}
