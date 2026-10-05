using MYFIN.API.DTOs.Journals;

namespace MYFIN.API.Services;

public interface IJournalService
{
    Task<JournalListResponse> GetListAsync(
        int? financialPeriodId,
        string? status,
        int? transactionTypeId,
        DateTime? startDate,
        DateTime? endDate,
        int page,
        int pageSize);

    Task<JournalDetailsResponse?> GetDetailsAsync(long journalId);
}
