using MYFIN.API.DTOs.Masters;

namespace MYFIN.API.Services;

public interface ITransactionComponentRuleService
{
    Task<IReadOnlyList<TransactionComponentRuleResponse>>
        GetTransactionComponentRulesAsync(
            int? transactionComponentId = null,
            string? entrySide = null);

    Task<TransactionComponentRuleResponse?>
        GetTransactionComponentRuleAsync(
            int transactionComponentRuleId);

    Task<TransactionComponentRuleResponse>
        CreateTransactionComponentRuleAsync(
            CreateTransactionComponentRuleRequest request);

    Task<TransactionComponentRuleResponse>
        UpdateTransactionComponentRuleAsync(
            int transactionComponentRuleId,
            UpdateTransactionComponentRuleRequest request);
}