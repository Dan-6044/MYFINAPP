using MYFIN.API.DTOs.Masters;

namespace MYFIN.API.Services;

public interface IMasterDataService
{
    Task<IReadOnlyList<AccountResponse>> GetAccountsAsync(
        bool? isActive = null);

    Task<AccountResponse?> GetAccountAsync(
        long coaId);

    Task<AccountResponse> CreateAccountAsync(
        CreateAccountRequest request);

    Task<AccountResponse> UpdateAccountAsync(
        long coaId,
        UpdateAccountRequest request);

    Task<AccountResponse> SetAccountActiveStatusAsync(
        long coaId,
        bool isActive);

    Task<IReadOnlyList<MainHeadResponse>> GetMainHeadsAsync(bool? isActive = null);

    Task<MainHeadResponse?> GetMainHeadAsync(int mainHeadId);

    Task<MainHeadResponse> CreateMainHeadAsync(
        CreateMainHeadRequest request);

    Task<MainHeadResponse> UpdateMainHeadAsync(
        int mainHeadId,
        UpdateMainHeadRequest request);

    Task<MainHeadResponse> SetMainHeadActiveStatusAsync(
        int mainHeadId,
        bool isActive);

    Task<IReadOnlyList<SubheadResponse>> GetSubheadsAsync(
        bool? isActive = null,
        int? mainHeadId = null);

    Task<SubheadResponse?> GetSubheadAsync(int subheadId);

    Task<SubheadResponse> CreateSubheadAsync(
        CreateSubheadRequest request);

    Task<SubheadResponse> UpdateSubheadAsync(
        int subheadId,
        UpdateSubheadRequest request);

    Task<SubheadResponse> SetSubheadActiveStatusAsync(
        int subheadId,
        bool isActive);

    Task<IReadOnlyList<CurrencyResponse>> GetCurrenciesAsync(
        bool? isActive = null);

    Task<CurrencyResponse?> GetCurrencyAsync(
        int currencyId);

    Task<CurrencyResponse> CreateCurrencyAsync(
        CreateCurrencyRequest request);

    Task<CurrencyResponse> UpdateCurrencyAsync(
        int currencyId,
        UpdateCurrencyRequest request);

    Task<CurrencyResponse> SetCurrencyActiveStatusAsync(
        int currencyId,
        bool isActive);

    Task<IReadOnlyList<TransactionTypeResponse>> GetTransactionTypesAsync(
        bool? isActive = null);

    Task<TransactionTypeResponse?> GetTransactionTypeAsync(
        int transactionTypeId);

    Task<TransactionTypeResponse> CreateTransactionTypeAsync(
        CreateTransactionTypeRequest request);

    Task<TransactionTypeResponse> UpdateTransactionTypeAsync(
        int transactionTypeId,
        UpdateTransactionTypeRequest request);

    Task<TransactionTypeResponse> SetTransactionTypeActiveStatusAsync(
        int transactionTypeId,
        bool isActive);

    Task<IReadOnlyList<TransactionComponentResponse>> GetTransactionComponentsAsync(
        bool? isActive = null,
        int? transactionTypeId = null);

    Task<TransactionComponentResponse?> GetTransactionComponentAsync(
        int transactionComponentId);

    Task<TransactionComponentResponse> CreateTransactionComponentAsync(
        CreateTransactionComponentRequest request);

    Task<TransactionComponentResponse> UpdateTransactionComponentAsync(
        int transactionComponentId,
        UpdateTransactionComponentRequest request);

    Task<TransactionComponentResponse> SetTransactionComponentActiveStatusAsync(
        int transactionComponentId,
        bool isActive);
}
