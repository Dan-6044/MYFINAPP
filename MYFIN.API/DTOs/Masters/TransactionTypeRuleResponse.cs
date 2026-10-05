namespace MYFIN.API.DTOs.Masters;

public class TransactionTypeRuleResponse
{
    public int TransactionTypeRuleID { get; set; }

    public int TransactionTypeID { get; set; }
    public int TransactionTypeCode { get; set; }
    public string TransactionTypeName { get; set; } = string.Empty;

    public bool TransactionTypeIsSystem { get; set; }
    public bool TransactionTypeIsActive { get; set; }

    public string EntrySide { get; set; } = string.Empty;

    public int MainHeadID { get; set; }
    public int MainHeadCode { get; set; }
    public string MainHeadName { get; set; } = string.Empty;
    public string AccountingType { get; set; } = string.Empty;
    public string NormalBalance { get; set; } = string.Empty;

    public int SequenceNo { get; set; }
    public bool IsRequired { get; set; }

    public DateTime CreatedAt { get; set; }
}