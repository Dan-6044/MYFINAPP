import 'package:get/get.dart';
import '../../accounts/controllers/account_controller.dart';
import '../../transaction_types/controllers/transaction_type_controller.dart';
import '../../financial_periods/controllers/financial_period_controller.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/journal_controller.dart';
import '../controllers/credit_loans_controller.dart';

class AccountingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionController>(() => TransactionController());
    Get.lazyPut<TransactionTypeController>(() => TransactionTypeController());
    Get.lazyPut<FinancialPeriodController>(() => FinancialPeriodController());
    Get.lazyPut<AccountController>(() => AccountController());
    Get.lazyPut<JournalController>(() => JournalController());
    Get.lazyPut<CreditLoansController>(() => CreditLoansController());
  }
}
