namespace MYFIN.API.DTOs.Transactions;

public class ValidateTransactionResponse
{
    public long TransactionID { get; set; }

    public string TransactionNumber { get; set; } = string.Empty;

    public int TransactionTypeID { get; set; }

    public string TransactionTypeCode { get; set; } = string.Empty;

    public string TransactionTypeName { get; set; } = string.Empty;

    public int FinancialPeriodID { get; set; }

    public DateTime TransactionDate { get; set; }

    public string Status { get; set; } = string.Empty;

    public decimal TotalDebit { get; set; }

    public decimal TotalCredit { get; set; }

    public string Message { get; set; } = string.Empty;
}