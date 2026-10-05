import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:myfinapp/core/database/app_database.dart';
import 'package:myfinapp/core/sync/models/sync_status.dart';
import 'package:myfinapp/core/sync/models/local_sync_state.dart';
import 'package:myfinapp/core/sync/repositories/sqlite_sync_repository.dart';
import 'package:myfinapp/core/sync/repositories/sync_repository.dart';
import 'package:myfinapp/core/sync/helpers/sync_transaction_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SyncRepositoryTest', () {
    late SyncRepository repository;
    late Database database;

    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'getApplicationDocumentsDirectory') {
            return p.join('.dart_tool', 'test_documents', 'sync');
          }
          return null;
        },
      );
    });

    setUp(() async {
      database = await AppDatabase.instance.database;
      repository = SqliteSyncRepository();
    });

    tearDown(() async {
      await database.delete('sync_outbox', where: 'entity_name = ?', whereArgs: ['currencies']);
      await database.delete('local_sync_state', where: 'entity_name = ?', whereArgs: ['currencies']);
    });

    tearDownAll(() async {
      await AppDatabase.instance.close();
    });

    test('enqueue creates outbox item with pending status', () async {
      final item = await repository.enqueue(
        entityName: 'currencies',
        entityId: 1,
        operation: 'CREATE',
        payloadJson: '{"currency_code":"KES"}',
      );

      expect(item.status, equals(OutboxStatus.pending));
      expect(item.entityName, equals('currencies'));
      expect(item.entityId, equals(1));
      expect(item.operation, equals('CREATE'));
      expect(item.attemptCount, equals(0));
    });

    test('getPendingItems returns only pending items', () async {
      await repository.enqueue(
        entityName: 'currencies',
        entityId: 1,
        operation: 'CREATE',
        payloadJson: '{"currency_code":"KES"}',
      );

      await repository.enqueue(
        entityName: 'currencies',
        entityId: 2,
        operation: 'UPDATE',
        payloadJson: '{"currency_code":"USD"}',
      );

      final items = await repository.getPendingItems();

      expect(items.length, equals(2));
      expect(items.every((item) => item.status == OutboxStatus.pending), isTrue);
      expect(items.map((item) => item.entityId), equals([1, 2]));
    });

    test('getRetryableItems returns failed items below max attempts', () async {
      final item = await repository.enqueue(
        entityName: 'currencies',
        entityId: 1,
        operation: 'CREATE',
        payloadJson: '{"currency_code":"KES"}',
      );

      await repository.markFailed(item.outboxId, lastError: 'Network error');

      final retryable = await repository.getRetryableItems(maxAttempts: 3);

      expect(retryable.length, equals(1));
      expect(retryable.first.outboxId, equals(item.outboxId));
    });

    test('markProcessing increments attempt count and sets processing status', () async {
      final item = await repository.enqueue(
        entityName: 'currencies',
        entityId: 1,
        operation: 'CREATE',
        payloadJson: '{"currency_code":"KES"}',
      );

      final processing = await repository.markProcessing(item.outboxId, lastError: 'Retry 1');

      expect(processing.status, equals(OutboxStatus.processing));
      expect(processing.attemptCount, equals(1));
      expect(processing.lastError, equals('Retry 1'));
    });

    test('markSynced changes status to synced', () async {
      final item = await repository.enqueue(
        entityName: 'currencies',
        entityId: 1,
        operation: 'CREATE',
        payloadJson: '{"currency_code":"KES"}',
      );

      final synced = await repository.markSynced(item.outboxId);

      expect(synced.status, equals(OutboxStatus.synced));
    });

    test('markFailed changes status to failed and preserves error', () async {
      final item = await repository.enqueue(
        entityName: 'currencies',
        entityId: 1,
        operation: 'CREATE',
        payloadJson: '{"currency_code":"KES"}',
      );

      final failed = await repository.markFailed(item.outboxId, lastError: 'Connection refused');

      expect(failed.status, equals(OutboxStatus.failed));
      expect(failed.lastError, equals('Connection refused'));
    });

    test('getSyncState returns null when state does not exist', () async {
      final state = await repository.getSyncState('nonexistent_entity');
      expect(state, isNull);
    });

    test('updateSyncState creates or updates sync state', () async {
      final state = LocalSyncState(
        syncStateId: 1,
        entityName: 'currencies',
        lastServerVersion: 5,
        lastSyncAt: '2026-09-15T10:00:00.000Z',
        syncStatus: LocalSyncStatus.success,
        lastError: null,
        updatedAt: '2026-09-15T10:00:00.000Z',
      );

      final updated = await repository.updateSyncState(state);

      expect(updated.entityName, equals('currencies'));
      expect(updated.lastServerVersion, equals(5));
      expect(updated.syncStatus, equals(LocalSyncStatus.success));

      final retrieved = await repository.getSyncState('currencies');
      expect(retrieved, isNotNull);
      expect(retrieved!.lastServerVersion, equals(5));
    });

    test('atomic write plus outbox rolls back on failure', () async {
      final helper = SyncTransactionHelper();

      expect(
        () async => await helper.withSyncTransaction(
          entityName: 'currencies',
          entityId: 999,
          operation: 'CREATE',
          payloadJson: '{"currency_code":"FAIL"}',
          businessOperation: (txn) async {
            await txn.insert('currencies', {
              'currency_id': 999,
              'currency_code': 'FAIL',
              'currency_name': 'Fail Currency',
              'decimal_places': 2,
              'is_base_currency': 0,
              'is_active': 1,
              'created_at': '2026-09-15T00:00:00.000Z',
            });
            throw Exception('Simulated business write failure');
          },
        ),
        throwsA(isA<Exception>()),
      );

      final outboxItems = await repository.getPendingItems();
      final businessRecords = await database.query(
        'currencies',
        where: 'currency_id = ?',
        whereArgs: [999],
      );

      expect(outboxItems.any((item) => item.entityId == 999), isFalse,
          reason: 'Outbox item should not persist after rollback');
      expect(businessRecords, isEmpty,
          reason: 'Business record should not persist after rollback');
    });
  });
}
