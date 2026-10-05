using MYFIN.API.DTOs.Masters;

namespace MYFIN.API.Services;

public interface ITransactionTypeRuleService
{
    Task<IReadOnlyList<TransactionTypeRuleResponse>>
        GetTransactionTypeRulesAsync(
            int? transactionTypeId = null,
            string? entrySide = null);

    Task<TransactionTypeRuleResponse?>
        GetTransactionTypeRuleAsync(
            int transactionTypeRuleId);

    Task<TransactionTypeRuleResponse>
        CreateTransactionTypeRuleAsync(
            CreateTransactionTypeRuleRequest request);

    Task<TransactionTypeRuleResponse>
        UpdateTransactionTypeRuleAsync(
            int transactionTypeRuleId,
            UpdateTransactionTypeRuleRequest request);
}