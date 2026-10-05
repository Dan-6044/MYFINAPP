import 'package:get/get.dart';

import 'package:myfinapp/features/currencies/controllers/currency_controller.dart';
import 'package:myfinapp/features/financial_periods/controllers/financial_period_controller.dart';
import 'package:myfinapp/features/main_heads/controllers/main_head_controller.dart';
import 'package:myfinapp/features/subheads/controllers/subhead_controller.dart';
import 'package:myfinapp/features/accounts/controllers/account_controller.dart';
import 'package:myfinapp/features/transaction_types/controllers/transaction_type_controller.dart';
import 'package:myfinapp/features/users/controllers/user_controller.dart';

class ConfigurationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CurrencyController>(() => CurrencyController());
    Get.lazyPut<FinancialPeriodController>(() => FinancialPeriodController());
    Get.lazyPut<MainHeadController>(() => MainHeadController());
    Get.lazyPut<SubheadController>(() => SubheadController());
    Get.lazyPut<AccountController>(() => AccountController());
    Get.lazyPut<TransactionTypeController>(() => TransactionTypeController());
    Get.lazyPut<UserController>(() => UserController());
  }
}
