import '../../data/models/currency_model.dart';
import '../../data/models/create_currency_command.dart';
import '../../data/models/update_currency_command.dart';

abstract class CurrencyRepository {
  Future<List<CurrencyModel>> getAll();
  Future<CurrencyModel?> getById(int currencyId);
  Future<CurrencyModel?> getByCode(String currencyCode);
  Future<List<CurrencyModel>> getActive();
  Future<CurrencyModel?> getBaseCurrency();

  Future<CurrencyModel> create(CreateCurrencyCommand command);
  Future<CurrencyModel> update(int currencyId, UpdateCurrencyCommand command);
  Future<CurrencyModel> activate(int currencyId);
  Future<CurrencyModel> deactivate(int currencyId);
}
