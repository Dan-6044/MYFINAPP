import 'sync_status.dart';

class SyncOutboxItem {
  final int outboxId;
  final String entityName;
  final int entityId;
  final String operation;
  final String payloadJson;
  final String createdAt;
  final int attemptCount;
  final String? lastAttemptAt;
  final String? lastError;
  final OutboxStatus status;

  const SyncOutboxItem({
    required this.outboxId,
    required this.entityName,
    required this.entityId,
    required this.operation,
    required this.payloadJson,
    required this.createdAt,
    required this.attemptCount,
    this.lastAttemptAt,
    this.lastError,
    required this.status,
  });

  factory SyncOutboxItem.fromMap(Map<String, dynamic> map) {
    return SyncOutboxItem(
      outboxId: map['outbox_id'] as int,
      entityName: map['entity_name'] as String,
      entityId: map['entity_id'] as int,
      operation: map['operation'] as String,
      payloadJson: map['payload_json'] as String,
      createdAt: map['created_at'] as String,
      attemptCount: map['attempt_count'] as int,
      lastAttemptAt: map['last_attempt_at'] as String?,
      lastError: map['last_error'] as String?,
      status: OutboxStatus.fromValue(map['status'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'outbox_id': outboxId,
      'entity_name': entityName,
      'entity_id': entityId,
      'operation': operation,
      'payload_json': payloadJson,
      'created_at': createdAt,
      'attempt_count': attemptCount,
      'last_attempt_at': lastAttemptAt,
      'last_error': lastError,
      'status': status.value,
    };
  }
}
