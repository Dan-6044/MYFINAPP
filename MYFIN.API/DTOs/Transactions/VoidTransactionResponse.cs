namespace MYFIN.API.DTOs.Transactions;

public class VoidTransactionResponse
{
    public long TransactionID { get; set; }

    public string TransactionNumber { get; set; } = string.Empty;

    public string Status { get; set; } = string.Empty;

    public DateTime VoidedAt { get; set; }

    public int VoidedByUserID { get; set; }

    public string VoidReason { get; set; } = string.Empty;

    public long? OriginalJournalID { get; set; }

    public long? ReversalJournalID { get; set; }

    public string? ReversalJournalNumber { get; set; }

    public string Message { get; set; } = string.Empty;
}