using MYFIN.API.DTOs.Accounts;
using MYFIN.API.DTOs.Reports;
using MYFIN.API.DTOs.Transactions;

namespace MYFIN.API.Services;

public interface ITransactionService
{
    Task<CreateTransactionResponse> CreateAsync(
        CreateTransactionRequest request);

    Task<TransactionDetailsResponse> GetDetailsAsync(
        long transactionId);

    Task<ValidateTransactionResponse> ValidateAsync(
        long transactionId);

    Task<PostTransactionResponse> PostAsync(
        long transactionId,
        int postedByUserId);
    
    Task<TransactionListResponse> GetListAsync(
    int? financialPeriodId,
    string? status,
    int? transactionTypeId,
    DateTime? startDate,
    DateTime? endDate,
    int page,
    int pageSize);
 
 Task<AccountStatementResponse?> GetAccountStatementAsync(
    long coaId,
    int? financialPeriodId,
    DateTime? startDate,
    DateTime? endDate);

Task<TrialBalanceResponse> GetTrialBalanceAsync(
    int? financialPeriodId,
    DateTime? startDate,
    DateTime? endDate);
Task<IncomeStatementResponse> GetIncomeStatementAsync(
    int? financialPeriodId,
    DateTime? startDate,
    DateTime? endDate);

    Task<BalanceSheetResponse> GetBalanceSheetAsync(
        int? financialPeriodId,
        DateTime? startDate,
        DateTime? endDate);

    Task<CashFlowStatementResponse> GetCashFlowStatementAsync(
        int? financialPeriodId,
        DateTime? startDate,
        DateTime? endDate);

    Task<VoidTransactionResponse> VoidAsync(
        long transactionId,
        int voidedByUserId,
        string voidReason);
}