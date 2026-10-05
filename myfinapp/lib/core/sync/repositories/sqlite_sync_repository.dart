import 'package:sqflite/sqflite.dart';

import '../../database/app_database.dart';
import '../models/sync_outbox_item.dart';
import '../models/local_sync_state.dart';
import '../models/sync_status.dart';
import 'sync_repository.dart';

class SqliteSyncRepository implements SyncRepository {
  Future<Database> get _database async => AppDatabase.instance.database;

  Future<DateTime> _now() async => DateTime.now().toUtc();

  @override
  Future<SyncOutboxItem> enqueue({
    required String entityName,
    required int entityId,
    required String operation,
    required String payloadJson,
    String? createdAt,
  }) async {
    final database = await _database;
    final now = await _now();
    final normalizedCreatedAt = createdAt ?? now.toIso8601String();

    final outboxId = await database.insert('sync_outbox', {
      'entity_name': entityName,
      'entity_id': entityId,
      'operation': operation,
      'payload_json': payloadJson,
      'created_at': normalizedCreatedAt,
      'attempt_count': 0,
      'status': OutboxStatus.pending.value,
    });

    final rows = await database.query(
      'sync_outbox',
      columns: const [
        'outbox_id',
        'entity_name',
        'entity_id',
        'operation',
        'payload_json',
        'created_at',
        'attempt_count',
        'last_attempt_at',
        'last_error',
        'status',
      ],
      where: 'outbox_id = ?',
      whereArgs: [outboxId],
    );

    return SyncOutboxItem.fromMap(rows.first);
  }

  @override
  Future<List<SyncOutboxItem>> getPendingItems() async {
    final database = await _database;
    final rows = await database.query(
      'sync_outbox',
      columns: const [
        'outbox_id',
        'entity_name',
        'entity_id',
        'operation',
        'payload_json',
        'created_at',
        'attempt_count',
        'last_attempt_at',
        'last_error',
        'status',
      ],
      where: 'status = ?',
      whereArgs: [OutboxStatus.pending.value],
      orderBy: 'created_at ASC',
    );
    return rows.map(SyncOutboxItem.fromMap).toList();
  }

  @override
  Future<List<SyncOutboxItem>> getRetryableItems({int maxAttempts = 3}) async {
    final database = await _database;
    final rows = await database.query(
      'sync_outbox',
      columns: const [
        'outbox_id',
        'entity_name',
        'entity_id',
        'operation',
        'payload_json',
        'created_at',
        'attempt_count',
        'last_attempt_at',
        'last_error',
        'status',
      ],
      where: 'status = ? AND attempt_count < ?',
      whereArgs: [OutboxStatus.failed.value, maxAttempts],
      orderBy: 'created_at ASC',
    );
    return rows.map(SyncOutboxItem.fromMap).toList();
  }

  @override
  Future<SyncOutboxItem?> getItem(int outboxId) async {
    final database = await _database;
    final rows = await database.query(
      'sync_outbox',
      columns: const [
        'outbox_id',
        'entity_name',
        'entity_id',
        'operation',
        'payload_json',
        'created_at',
        'attempt_count',
        'last_attempt_at',
        'last_error',
        'status',
      ],
      where: 'outbox_id = ?',
      whereArgs: [outboxId],
    );
    if (rows.isEmpty) return null;
    return SyncOutboxItem.fromMap(rows.first);
  }

  @override
  Future<SyncOutboxItem> markProcessing(int outboxId, {String? lastError}) async {
    final database = await _database;
    final now = await _now();

    await database.rawUpdate(
      '''
      UPDATE sync_outbox
      SET status = ?,
          attempt_count = attempt_count + 1,
          last_attempt_at = ?
          ${lastError != null ? ', last_error = ?' : ''}
      WHERE outbox_id = ?
      ''',
      [
        OutboxStatus.processing.value,
        now.toIso8601String(),
        if (lastError != null) lastError,
        outboxId,
      ],
    );

    final rows = await database.query(
      'sync_outbox',
      columns: const [
        'outbox_id',
        'entity_name',
        'entity_id',
        'operation',
        'payload_json',
        'created_at',
        'attempt_count',
        'last_attempt_at',
        'last_error',
        'status',
      ],
      where: 'outbox_id = ?',
      whereArgs: [outboxId],
    );

    return SyncOutboxItem.fromMap(rows.first);
  }

  @override
  Future<SyncOutboxItem> markSynced(int outboxId) async {
    final database = await _database;

    await database.update(
      'sync_outbox',
      {
        'status': OutboxStatus.synced.value,
      },
      where: 'outbox_id = ?',
      whereArgs: [outboxId],
    );

    final rows = await database.query(
      'sync_outbox',
      columns: const [
        'outbox_id',
        'entity_name',
        'entity_id',
        'operation',
        'payload_json',
        'created_at',
        'attempt_count',
        'last_attempt_at',
        'last_error',
        'status',
      ],
      where: 'outbox_id = ?',
      whereArgs: [outboxId],
    );

    return SyncOutboxItem.fromMap(rows.first);
  }

  @override
  Future<SyncOutboxItem> markFailed(int outboxId, {String? lastError}) async {
    final database = await _database;
    final now = await _now();

    await database.update(
      'sync_outbox',
      {
        'status': OutboxStatus.failed.value,
        'last_attempt_at': now.toIso8601String(),
        if (lastError != null) 'last_error': lastError,
      },
      where: 'outbox_id = ?',
      whereArgs: [outboxId],
    );

    final rows = await database.query(
      'sync_outbox',
      columns: const [
        'outbox_id',
        'entity_name',
        'entity_id',
        'operation',
        'payload_json',
        'created_at',
        'attempt_count',
        'last_attempt_at',
        'last_error',
        'status',
      ],
      where: 'outbox_id = ?',
      whereArgs: [outboxId],
    );

    return SyncOutboxItem.fromMap(rows.first);
  }

  @override
  Future<LocalSyncState?> getSyncState(String entityName) async {
    final database = await _database;
    final rows = await database.query(
      'local_sync_state',
      columns: const [
        'sync_state_id',
        'entity_name',
        'last_server_version',
        'last_sync_at',
        'sync_status',
        'last_error',
        'updated_at',
      ],
      where: 'entity_name = ?',
      whereArgs: [entityName],
    );
    if (rows.isEmpty) return null;
    return LocalSyncState.fromMap(rows.first);
  }

  @override
  Future<LocalSyncState> updateSyncState(LocalSyncState state) async {
    final database = await _database;
    final now = await _now();

    await database.insert(
      'local_sync_state',
      {
        'sync_state_id': state.syncStateId,
        'entity_name': state.entityName,
        'last_server_version': state.lastServerVersion,
        'last_sync_at': state.lastSyncAt,
        'sync_status': state.syncStatus.value,
        'last_error': state.lastError,
        'updated_at': now.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final rows = await database.query(
      'local_sync_state',
      columns: const [
        'sync_state_id',
        'entity_name',
        'last_server_version',
        'last_sync_at',
        'sync_status',
        'last_error',
        'updated_at',
      ],
      where: 'entity_name = ?',
      whereArgs: [state.entityName],
    );

    return LocalSyncState.fromMap(rows.first);
  }
}
