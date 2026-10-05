namespace MYFIN.API.DTOs.Transactions;

public class TransactionLineRequest
{
    public string ComponentCode { get; set; } = string.Empty;

    public string EntrySide { get; set; } = string.Empty;

    public long COAID { get; set; }

    public decimal Amount { get; set; }

    public string? Description { get; set; }
}