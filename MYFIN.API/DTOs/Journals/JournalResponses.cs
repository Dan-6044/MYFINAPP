namespace MYFIN.API.DTOs.Journals;

public class JournalListResponse
{
    public int Page { get; set; }
    public int PageSize { get; set; }
    public int TotalRecords { get; set; }
    public int TotalPages { get; set; }

    public List<JournalListItemResponse> Journals { get; set; } = new();
}

public class JournalListItemResponse
{
    public long JournalID { get; set; }
    public string JournalNumber { get; set; } = string.Empty;

    public long TransactionID { get; set; }
    public string TransactionNumber { get; set; } = string.Empty;

    public int TransactionTypeID { get; set; }
    public string TransactionTypeCode { get; set; } = string.Empty;
    public string TransactionTypeName { get; set; } = string.Empty;

    public int FinancialPeriodID { get; set; }

    public DateTime JournalDate { get; set; }

    public string? Description { get; set; }

    public string Status { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; }
    public DateTime? PostedAt { get; set; }

    public decimal TotalDebit { get; set; }
    public decimal TotalCredit { get; set; }

    public List<JournalLineResponse> Lines { get; set; } = new();
}

public class JournalDetailsResponse
{
    public long JournalID { get; set; }
    public string JournalNumber { get; set; } = string.Empty;

    public long TransactionID { get; set; }
    public string TransactionNumber { get; set; } = string.Empty;

    public int TransactionTypeID { get; set; }
    public string TransactionTypeCode { get; set; } = string.Empty;
    public string TransactionTypeName { get; set; } = string.Empty;

    public int FinancialPeriodID { get; set; }

    public DateTime JournalDate { get; set; }

    public string? Description { get; set; }

    public string Status { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; }
    public DateTime? PostedAt { get; set; }

    public decimal TotalDebit { get; set; }
    public decimal TotalCredit { get; set; }

    public List<JournalLineResponse> Lines { get; set; } = new();
}

public class JournalLineResponse
{
    public long JournalLineID { get; set; }
    public int LineSequence { get; set; }

    public long COAID { get; set; }
    public string COACode { get; set; } = string.Empty;
    public string COAName { get; set; } = string.Empty;

    public decimal DebitAmount { get; set; }
    public decimal CreditAmount { get; set; }

    public string? Description { get; set; }
}
