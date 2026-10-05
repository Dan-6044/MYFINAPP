import 'package:sqflite/sqflite.dart';

import '../../database/app_database.dart';
import '../models/sync_status.dart';

class SyncTransactionHelper {
  Future<Database> get _database async => AppDatabase.instance.database;

  Future<T> withSyncTransaction<T>({
    required String entityName,
    int? entityId,
    required String operation,
    required String payloadJson,
    required Future<T> Function(Transaction txn) businessOperation,
    String? createdAt,
  }) async {
    final database = await _database;
    final now = DateTime.now().toUtc().toIso8601String();
    final normalizedCreatedAt = createdAt ?? now;

    final result = await database.transaction((txn) async {
      final businessResult = await businessOperation(txn);

      final outboxEntityId = entityId ??
          (businessResult is int ? businessResult : throw ArgumentError(
              'entityId must be provided when businessOperation does not return an int'));

      await txn.insert('sync_outbox', {
        'entity_name': entityName,
        'entity_id': outboxEntityId,
        'operation': operation,
        'payload_json': payloadJson,
        'created_at': normalizedCreatedAt,
        'attempt_count': 0,
        'status': OutboxStatus.pending.value,
      });

      return businessResult;
    });

    return result;
  }
}
