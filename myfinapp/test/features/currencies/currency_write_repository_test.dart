import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:myfinapp/core/database/app_database.dart';
import 'package:myfinapp/core/sync/models/sync_status.dart';
import 'package:myfinapp/core/sync/repositories/sync_repository.dart';
import 'package:myfinapp/core/sync/repositories/sqlite_sync_repository.dart';
import 'package:myfinapp/core/sync/helpers/sync_transaction_helper.dart';
import 'package:myfinapp/core/sync/adapters/currency_sync_adapter.dart';
import 'package:myfinapp/features/currencies/domain/repositories/currency_repository.dart';
import 'package:myfinapp/features/currencies/data/repositories/currency_repository_impl.dart';
import 'package:myfinapp/features/currencies/data/models/create_currency_command.dart';
import 'package:myfinapp/features/currencies/data/models/update_currency_command.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CurrencyWriteRepositoryTest', () {
    late CurrencyRepository repository;
    late SyncRepository syncRepository;
    late Database database;

    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'getApplicationDocumentsDirectory') {
            return p.join('.dart_tool', 'test_documents', 'currency_write');
          }
          return null;
        },
      );
    });

    setUp(() async {
      database = await AppDatabase.instance.database;
      repository = CurrencyRepositoryImpl();
      syncRepository = SqliteSyncRepository();
    });

    tearDownAll(() async {
      await AppDatabase.instance.close();
    });

    Future<void> cleanupCurrencies(List<int> ids) async {
      for (final id in ids) {
        await database.delete('currencies', where: 'currency_id = ?', whereArgs: [id]);
      }
    }

    Future<void> cleanupOutbox() async {
      await database.delete('sync_outbox', where: 'entity_name = ?', whereArgs: ['currencies']);
    }

    test('create inserts currency and enqueues outbox CREATE', () async {
      final command = CreateCurrencyCommand(
        currencyCode: 'EUR',
        currencyName: 'Euro',
        currencySymbol: '€',
        decimalPlaces: 2,
        isBaseCurrency: false,
      );

      final currency = await repository.create(command);
      final createdId = currency.currencyId;

      addTearDown(() async {
        await cleanupCurrencies([createdId]);
        await cleanupOutbox();
      });

      expect(currency.currencyCode, equals('EUR'));
      expect(currency.currencyName, equals('Euro'));
      expect(currency.currencySymbol, equals('€'));
      expect(currency.isActive, isTrue);

      final outboxItems = await syncRepository.getPendingItems();
      final currencyOutbox = outboxItems.where((item) => item.entityId == createdId).toList();

      expect(currencyOutbox.length, equals(1));
      expect(currencyOutbox.first.operation, equals('CREATE'));
      expect(currencyOutbox.first.status, equals(OutboxStatus.pending));

      final payload = currencyOutbox.first.payloadJson;
      expect(payload, contains('EUR'));
      expect(payload, contains('Euro'));
    });

    test('update modifies currency and enqueues outbox UPDATE', () async {
      final created = await repository.create(const CreateCurrencyCommand(
        currencyCode: 'GBP',
        currencyName: 'British Pound',
        currencySymbol: '£',
        decimalPlaces: 2,
      ));
      final createdId = created.currencyId;

      addTearDown(() async {
        await cleanupCurrencies([createdId]);
        await cleanupOutbox();
      });

      final updated = await repository.update(createdId, const UpdateCurrencyCommand(
        currencyCode: 'GBP',
        currencyName: 'British Pound Updated',
        currencySymbol: '£',
        decimalPlaces: 2,
        isBaseCurrency: false,
      ));

      expect(updated.currencyName, equals('British Pound Updated'));

      final outboxItems = await syncRepository.getPendingItems();
      final updateOutbox = outboxItems.where((item) => item.entityId == createdId && item.operation == 'UPDATE').toList();

      expect(updateOutbox.length, equals(1));
      expect(updateOutbox.first.payloadJson, contains('British Pound Updated'));
    });

    test('activate updates is_active and enqueues outbox UPDATE with action activate', () async {
      final created = await repository.create(const CreateCurrencyCommand(
        currencyCode: 'JPY',
        currencyName: 'Japanese Yen',
        currencySymbol: '¥',
        decimalPlaces: 0,
      ));
      final createdId = created.currencyId;

      addTearDown(() async {
        await cleanupCurrencies([createdId]);
        await cleanupOutbox();
      });

      await repository.deactivate(createdId);
      final deactivated = await repository.getById(createdId);
      expect(deactivated!.isActive, isFalse);

      final activated = await repository.activate(createdId);
      expect(activated.isActive, isTrue);

      final outboxItems = await syncRepository.getPendingItems();
      final activateOutbox = outboxItems.where((item) => item.entityId == createdId && item.operation == 'UPDATE').toList();

      expect(activateOutbox.length, equals(2));
      final activatePayload = activateOutbox.last.payloadJson;
      expect(activatePayload, contains('activate'));
    });

    test('deactivate prevents deactivating base currency', () async {
      final created = await repository.create(const CreateCurrencyCommand(
        currencyCode: 'BFC',
        currencyName: 'Base Fake Currency',
        currencySymbol: 'BFC',
        decimalPlaces: 2,
        isBaseCurrency: true,
      ));
      final createdId = created.currencyId;

      addTearDown(() async {
        await cleanupCurrencies([createdId]);
        await cleanupOutbox();
      });

      expect(
        () => repository.deactivate(createdId),
        throwsA(isA<Exception>()),
      );
    });

    test('atomic rollback on outbox failure leaves no partial data', () async {
      await database.delete('sync_outbox', where: 'entity_name = ?', whereArgs: ['currencies']);

      final helper = SyncTransactionHelper();

      expect(
        () async => await helper.withSyncTransaction(
          entityName: 'currencies',
          operation: 'CREATE',
          payloadJson: '{"currency_code":"ROL"}',
          businessOperation: (txn) async {
            await txn.insert('currencies', {
              'currency_code': 'ROL',
              'currency_name': 'Rollback Currency',
              'decimal_places': 2,
              'is_base_currency': 0,
              'is_active': 1,
              'created_at': '2026-09-15T00:00:00.000Z',
            });
            throw Exception('Simulated outbox failure');
          },
        ),
        throwsA(isA<Exception>()),
      );

      final outboxItems = await syncRepository.getPendingItems();
      final businessRecords = await database.query('currencies', where: 'currency_code = ?', whereArgs: ['ROL']);

      expect(outboxItems.any((item) => item.entityId != null), isFalse);
      expect(businessRecords, isEmpty);
    });

    test('sync adapter processes pending currency outbox items', () async {
      final created = await repository.create(const CreateCurrencyCommand(
        currencyCode: 'CHF',
        currencyName: 'Swiss Franc',
        currencySymbol: 'Fr',
        decimalPlaces: 2,
      ));
      final createdId = created.currencyId;

      addTearDown(() async {
        await cleanupCurrencies([createdId]);
        await cleanupOutbox();
      });

      final outboxItemsBefore = await syncRepository.getPendingItems();
      final currencyOutbox = outboxItemsBefore.where((item) => item.entityId == createdId).toList();
      expect(currencyOutbox.length, equals(1));

      final adapter = CurrencySyncAdapter(
        currencyRepository: repository,
        syncRepository: syncRepository,
      );

      await adapter.processOutbox();

      final outboxItemsAfter = await syncRepository.getPendingItems();
      expect(outboxItemsAfter.any((item) => item.entityId == createdId), isFalse);
    });
  });
}
