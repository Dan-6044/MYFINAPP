import 'package:get/get.dart';

import '../controllers/health_controller.dart';

class ConnectivityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HealthController>(() => HealthController());
  }
}
