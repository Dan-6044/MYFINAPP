
namespace MYFIN.API.DTOs.Masters;

public class SubheadResponse
{
    public int SubheadID { get; set; }
    public int SubheadCode { get; set; }
    public string SubheadName { get; set; } = string.Empty;

    public MainHeadInfo MainHead { get; set; } = new();

    public bool IsActive { get; set; }

    public int AccountCount { get; set; }
    public int ComponentRuleCount { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

