
namespace MYFIN.API.DTOs.Masters;

public class MainHeadResponse
{
    public int MainHeadID { get; set; }
    public int MainHeadCode { get; set; }
    public string MainHeadName { get; set; } = string.Empty;
    public string AccountingType { get; set; } = string.Empty;
    public string NormalBalance { get; set; } = string.Empty;
    public string NormalBalanceName { get; set; } = string.Empty;
    public bool IsActive { get; set; }

    public int SubheadCount { get; set; }
    public int TransactionTypeRuleCount { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

