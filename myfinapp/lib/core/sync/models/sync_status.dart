enum OutboxStatus {
  pending,
  processing,
  synced,
  failed;

  String get value {
    switch (this) {
      case OutboxStatus.pending:
        return 'PENDING';
      case OutboxStatus.processing:
        return 'PROCESSING';
      case OutboxStatus.synced:
        return 'SUCCESS';
      case OutboxStatus.failed:
        return 'FAILED';
    }
  }

  static OutboxStatus fromValue(String value) {
    switch (value) {
      case 'PENDING':
        return OutboxStatus.pending;
      case 'PROCESSING':
        return OutboxStatus.processing;
      case 'SUCCESS':
        return OutboxStatus.synced;
      case 'FAILED':
        return OutboxStatus.failed;
      default:
        throw FormatException('Unknown outbox status: $value');
    }
  }
}

enum LocalSyncStatus {
  idle,
  syncing,
  success,
  failed;

  String get value {
    switch (this) {
      case LocalSyncStatus.idle:
        return 'IDLE';
      case LocalSyncStatus.syncing:
        return 'SYNCING';
      case LocalSyncStatus.success:
        return 'SUCCESS';
      case LocalSyncStatus.failed:
        return 'FAILED';
    }
  }

  static LocalSyncStatus fromValue(String value) {
    switch (value) {
      case 'IDLE':
        return LocalSyncStatus.idle;
      case 'SYNCING':
        return LocalSyncStatus.syncing;
      case 'SUCCESS':
        return LocalSyncStatus.success;
      case 'FAILED':
        return LocalSyncStatus.failed;
      default:
        throw FormatException('Unknown local sync status: $value');
    }
  }
}
