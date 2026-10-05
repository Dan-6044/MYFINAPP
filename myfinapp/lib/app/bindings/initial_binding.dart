import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import '../../core/database/database_service.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/utils/connectivity_service.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../../features/currencies/data/repositories/currency_repository_impl.dart';
import '../../features/currencies/domain/repositories/currency_repository.dart';
import '../../core/sync/repositories/sqlite_sync_repository.dart';
import '../../core/sync/repositories/sync_repository.dart';
import '../../core/sync/services/sync_state_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SecureStorageService>(SecureStorageService.instance, permanent: true);
    Get.put<DatabaseService>(DatabaseService.instance, permanent: true);
    Get.put<ConnectivityService>(ConnectivityService.instance, permanent: true);
    Get.putAsync<ApiClient>(() async {
      final client = ApiClient.instance;
      await client.initialize();
      return client;
    }, permanent: true);
    Get.lazyPut<CurrencyRepository>(() => CurrencyRepositoryImpl());
    Get.lazyPut<SyncRepository>(() => SqliteSyncRepository());
    Get.put<SyncStateService>(SyncStateService.instance, permanent: true);
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
