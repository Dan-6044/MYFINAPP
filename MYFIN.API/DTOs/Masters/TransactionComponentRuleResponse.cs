namespace MYFIN.API.DTOs.Masters;

public class TransactionComponentRuleResponse
{
    public int TransactionComponentRuleID { get; set; }

    public int TransactionComponentID { get; set; }

    public int TransactionTypeID { get; set; }
    public int TransactionTypeCode { get; set; }
    public string TransactionTypeName { get; set; } = string.Empty;

    public bool TransactionTypeIsSystem { get; set; }
    public bool TransactionTypeIsActive { get; set; }

    public string ComponentCode { get; set; } = string.Empty;
    public string ComponentName { get; set; } = string.Empty;

    public bool ComponentIsRequired { get; set; }
    public bool ComponentIsActive { get; set; }

    public string EntrySide { get; set; } = string.Empty;

    public int MainHeadID { get; set; }
    public int MainHeadCode { get; set; }
    public string MainHeadName { get; set; } = string.Empty;
    public string AccountingType { get; set; } = string.Empty;
    public string NormalBalance { get; set; } = string.Empty;

    public int? SubheadID { get; set; }
    public int? SubheadCode { get; set; }
    public string? SubheadName { get; set; }

    public long? COAID { get; set; }
    public string? COACode { get; set; }
    public string? COAName { get; set; }

    public bool IsRequired { get; set; }
    public int SequenceNo { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}