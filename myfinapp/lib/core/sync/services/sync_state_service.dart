import 'package:sqflite/sqflite.dart';

import '../../database/app_database.dart';
import '../models/local_sync_state.dart';
import '../models/sync_status.dart';

class SyncStateService {
  static final SyncStateService instance = SyncStateService._();

  SyncStateService._();

  Future<Database> get _database async => AppDatabase.instance.database;

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

  Future<LocalSyncState> updateSyncStatus({
    required String entityName,
    required LocalSyncStatus status,
    String? lastError,
    int? lastServerVersion,
    String? lastSyncAt,
  }) async {
    final database = await _database;
    final now = DateTime.now().toUtc().toIso8601String();

    await database.insert(
      'local_sync_state',
      {
        'entity_name': entityName,
        'last_server_version': lastServerVersion,
        'last_sync_at': lastSyncAt ?? now,
        'sync_status': status.value,
        'last_error': lastError,
        'updated_at': now,
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
      whereArgs: [entityName],
    );

    return LocalSyncState.fromMap(rows.first);
  }
}
