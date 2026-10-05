namespace MYFIN.API.DTOs.Transactions;

public class PostTransactionResponse
{
    public long TransactionID { get; set; }

    public string TransactionNumber { get; set; } = string.Empty;

    public string TransactionStatus { get; set; } = string.Empty;

    public long JournalID { get; set; }

    public string JournalNumber { get; set; } = string.Empty;

    public string JournalStatus { get; set; } = string.Empty;

    public int FinancialPeriodID { get; set; }

    public DateTime JournalDate { get; set; }

    public DateTime PostedAt { get; set; }

    public decimal TotalDebit { get; set; }

    public decimal TotalCredit { get; set; }

    public string Message { get; set; } = string.Empty;
}