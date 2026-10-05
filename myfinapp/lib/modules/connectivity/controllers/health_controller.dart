import 'package:get/get.dart';

import '../../../data/repositories/health_repository.dart';

enum HealthStatus { idle, testing, success, failure }

class HealthController extends GetxController {
  final HealthRepository _repository = HealthRepository();

  var apiStatus = HealthStatus.idle.obs;
  var databaseStatus = HealthStatus.idle.obs;
  var apiMessage = ''.obs;
  var databaseMessage = ''.obs;

  Future<void> testApi() async {
    apiStatus.value = HealthStatus.testing;
    apiMessage.value = 'Testing...';

    try {
      final data = await _repository.checkApiHealth();
      apiStatus.value = HealthStatus.success;
      apiMessage.value = data['status']?.toString() ?? 'API connected';
    } catch (e) {
      apiStatus.value = HealthStatus.failure;
      apiMessage.value = e.toString();
    }
  }

  Future<void> testDatabase() async {
    databaseStatus.value = HealthStatus.testing;
    databaseMessage.value = 'Testing...';

    try {
      final data = await _repository.checkDatabaseHealth();
      databaseStatus.value = HealthStatus.success;
      databaseMessage.value = data['status']?.toString() ?? 'Database connected';
    } catch (e) {
      databaseStatus.value = HealthStatus.failure;
      databaseMessage.value = e.toString();
    }
  }
}
