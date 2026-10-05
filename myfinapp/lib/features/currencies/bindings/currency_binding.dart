import 'package:get/get.dart';

import 'package:myfinapp/features/currencies/controllers/currency_controller.dart';

class CurrencyBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CurrencyController>(() => CurrencyController());
  }
}
