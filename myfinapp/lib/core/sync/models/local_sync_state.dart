import 'sync_status.dart';

class LocalSyncState {
  final int syncStateId;
  final String entityName;
  final int? lastServerVersion;
  final String? lastSyncAt;
  final LocalSyncStatus syncStatus;
  final String? lastError;
  final String updatedAt;

  const LocalSyncState({
    required this.syncStateId,
    required this.entityName,
    this.lastServerVersion,
    this.lastSyncAt,
    required this.syncStatus,
    this.lastError,
    required this.updatedAt,
  });

  factory LocalSyncState.fromMap(Map<String, dynamic> map) {
    return LocalSyncState(
      syncStateId: map['sync_state_id'] as int,
      entityName: map['entity_name'] as String,
      lastServerVersion: map['last_server_version'] as int?,
      lastSyncAt: map['last_sync_at'] as String?,
      syncStatus: LocalSyncStatus.fromValue(map['sync_status'] as String),
      lastError: map['last_error'] as String?,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sync_state_id': syncStateId,
      'entity_name': entityName,
      'last_server_version': lastServerVersion,
      'last_sync_at': lastSyncAt,
      'sync_status': syncStatus.value,
      'last_error': lastError,
      'updated_at': updatedAt,
    };
  }
}
