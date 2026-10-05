import '../models/sync_outbox_item.dart';
import '../models/local_sync_state.dart';

abstract class SyncRepository {
  Future<SyncOutboxItem> enqueue({
    required String entityName,
    required int entityId,
    required String operation,
    required String payloadJson,
    String? createdAt,
  });

  Future<List<SyncOutboxItem>> getPendingItems();
  Future<List<SyncOutboxItem>> getRetryableItems({int maxAttempts = 3});
  Future<SyncOutboxItem?> getItem(int outboxId);
  Future<SyncOutboxItem> markProcessing(int outboxId, {String? lastError});
  Future<SyncOutboxItem> markSynced(int outboxId);
  Future<SyncOutboxItem> markFailed(int outboxId, {String? lastError});

  Future<LocalSyncState?> getSyncState(String entityName);
  Future<LocalSyncState> updateSyncState(LocalSyncState state);
}
