namespace MYFIN.API.DTOs.Transactions;

public class CreateTransactionRequest
{
    public int TransactionTypeID { get; set; }

    public int FinancialPeriodID { get; set; }

    public DateTime TransactionDate { get; set; }

    public string Description { get; set; } = string.Empty;

    public string? ReferenceNumber { get; set; }

    public int CreatedByUserID { get; set; }

    public List<TransactionLineRequest> Lines { get; set; } = new();
}