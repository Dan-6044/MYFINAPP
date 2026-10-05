import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:myfinapp/core/database/app_database.dart';
import 'package:myfinapp/features/currencies/domain/repositories/currency_repository.dart';
import 'package:myfinapp/features/currencies/data/repositories/currency_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CurrencyRepositoryTest', () {
    late CurrencyRepository repository;
    late Database database;

    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'getApplicationDocumentsDirectory') {
            return p.join('.dart_tool', 'test_documents', 'currency');
          }
          return null;
        },
      );
    });

    setUp(() async {
      database = await AppDatabase.instance.database;
      repository = CurrencyRepositoryImpl();
    });

    tearDownAll(() async {
      await AppDatabase.instance.close();
    });

    Future<void> insertTestCurrencies() async {
      await database.insert('currencies', {
        'currency_id': 101,
        'currency_code': 'KES',
        'currency_name': 'Kenyan Shilling',
        'currency_symbol': 'KSh',
        'decimal_places': 2,
        'is_base_currency': 1,
        'is_active': 1,
        'created_at': '2026-09-15T00:00:00.000Z',
      });
      await database.insert('currencies', {
        'currency_id': 102,
        'currency_code': 'USD',
        'currency_name': 'US Dollar',
        'currency_symbol': '\$',
        'decimal_places': 2,
        'is_base_currency': 0,
        'is_active': 1,
        'created_at': '2026-09-15T00:00:00.000Z',
      });
      await database.insert('currencies', {
        'currency_id': 103,
        'currency_code': 'TEST',
        'currency_name': 'Inactive Currency',
        'currency_symbol': 'TST',
        'decimal_places': 2,
        'is_base_currency': 0,
        'is_active': 0,
        'created_at': '2026-09-15T00:00:00.000Z',
      });
    }

    Future<void> deleteTestCurrencies() async {
      await database.delete('currencies', where: 'currency_id IN (?, ?, ?)', whereArgs: [101, 102, 103]);
    }

    test('getAll returns all currencies ordered by currency_code', () async {
      await insertTestCurrencies();
      addTearDown(deleteTestCurrencies);

      final result = await repository.getAll();

      expect(result.length, equals(3));
      expect(result.map((c) => c.currencyCode), equals(['KES', 'TEST', 'USD']));
    });

    test('getById returns correct currency', () async {
      await insertTestCurrencies();
      addTearDown(deleteTestCurrencies);

      final result = await repository.getById(102);

      expect(result, isNotNull);
      expect(result!.currencyCode, equals('USD'));
      expect(result.currencyName, equals('US Dollar'));
    });

    test('getByCode returns correct currency', () async {
      await insertTestCurrencies();
      addTearDown(deleteTestCurrencies);

      final result = await repository.getByCode('KES');

      expect(result, isNotNull);
      expect(result!.currencyName, equals('Kenyan Shilling'));
      expect(result.currencySymbol, equals('KSh'));
    });

    test('getByCode trims whitespace', () async {
      await insertTestCurrencies();
      addTearDown(deleteTestCurrencies);

      final result = await repository.getByCode('  KES  ');

      expect(result, isNotNull);
      expect(result!.currencyCode, equals('KES'));
    });

    test('getActive returns only active currencies', () async {
      await insertTestCurrencies();
      addTearDown(deleteTestCurrencies);

      final result = await repository.getActive();

      expect(result.length, equals(2));
      expect(result.every((c) => c.isActive), isTrue);
      expect(result.map((c) => c.currencyCode), equals(['KES', 'USD']));
    });

    test('getBaseCurrency returns the base currency', () async {
      await insertTestCurrencies();
      addTearDown(deleteTestCurrencies);

      final result = await repository.getBaseCurrency();

      expect(result, isNotNull);
      expect(result!.currencyCode, equals('KES'));
      expect(result.isBaseCurrency, isTrue);
    });

    test('bool fields convert correctly', () async {
      await insertTestCurrencies();
      addTearDown(deleteTestCurrencies);

      final result = await repository.getById(101);

      expect(result, isNotNull);
      expect(result!.isBaseCurrency, isTrue);
      expect(result.isActive, isTrue);
      expect(result.decimalPlaces, equals(2));
    });
  });
}
