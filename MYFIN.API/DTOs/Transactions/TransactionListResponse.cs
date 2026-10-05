namespace MYFIN.API.DTOs.Transactions;

public class TransactionListResponse
{
    public int Page { get; set; }
    public int PageSize { get; set; }
    public int TotalRecords { get; set; }
    public int TotalPages { get; set; }

    public List<TransactionListItemResponse> Transactions { get; set; } = new();
}

public class TransactionListItemResponse
{
    public long TransactionID { get; set; }
    public string TransactionNumber { get; set; } = string.Empty;

    public int TransactionTypeID { get; set; }
    public string TransactionTypeCode { get; set; } = string.Empty;
    public string TransactionTypeName { get; set; } = string.Empty;

    public int FinancialPeriodID { get; set; }

    public DateTime TransactionDate { get; set; }

    public string? Description { get; set; }
    public string? ReferenceNumber { get; set; }

    public string Status { get; set; } = string.Empty;

    public int CreatedByUserID { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public DateTime? PostedAt { get; set; }

    public int? PostedByUserID { get; set; }

    public DateTime? VoidedAt { get; set; }
    public int? VoidedByUserID { get; set; }

    public string? VoidReason { get; set; }

    public decimal TotalDebit { get; set; }
    public decimal TotalCredit { get; set; }
}