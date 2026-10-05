using MYFIN.API.DTOs.FinancialPeriods;

namespace MYFIN.API.Services;

public interface IFinancialPeriodService
{
    Task<IReadOnlyList<FinancialPeriodResponse>> GetFinancialPeriodsAsync(
        int? userId = null);

    Task<FinancialPeriodResponse?> GetFinancialPeriodAsync(
        int financialPeriodId);

    Task<FinancialPeriodResponse?> GetCurrentFinancialPeriodAsync(
        int userId);

    Task<FinancialPeriodResponse> CreateFinancialPeriodAsync(
        CreateFinancialPeriodRequest request);

    Task<FinancialPeriodResponse> UpdateFinancialPeriodAsync(
        int financialPeriodId,
        UpdateFinancialPeriodRequest request);

    Task<FinancialPeriodResponse> CloseFinancialPeriodAsync(
        int financialPeriodId,
        int closedByUserId);
}