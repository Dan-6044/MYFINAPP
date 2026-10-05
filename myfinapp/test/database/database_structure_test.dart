import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:myfinapp/core/database/app_database.dart';
import 'package:myfinapp/core/database/database_schema.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DatabaseStructureTest', () {
    late Database database;

    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'getApplicationDocumentsDirectory') {
            return p.join('.dart_tool', 'test_documents', 'structure');
          }
          return null;
        },
      );
    });

    tearDownAll(() async {
      await AppDatabase.instance.close();
    });

    test('opens database and verifies structure', () async {
      database = await AppDatabase.instance.database;

      expect(database.isOpen, isTrue,
          reason: 'Database should be open');

      expect(await database.getVersion(), equals(1),
          reason: 'Database version should be 1');

      final foreignKeyResult = await database.rawQuery('PRAGMA foreign_keys');
      final foreignKeysEnabled = foreignKeyResult.first.values.first as int;
      expect(foreignKeysEnabled, equals(1),
          reason: 'Foreign keys should be enabled');

      final tableRows = await database.query(
        'sqlite_master',
        columns: ['name'],
        where: "type = 'table' AND name NOT LIKE 'sqlite_%'",
        orderBy: 'name',
      );

      final actualTableNames =
          tableRows.map((row) => row['name'] as String).toList();

      final expectedTables = <String>[
        'budget_lines',
        'budgets',
        'chart_of_accounts',
        'credit_payments',
        'credits',
        'currencies',
        'financial_periods',
        'journal_lines',
        'journals',
        'local_sync_state',
        'main_heads',
        'savings_contributions',
        'savings_goals',
        'subheads',
        'sync_outbox',
        'transaction_components',
        'transaction_lines',
        'transaction_types',
        'transactions',
        'users',
      ];

      expect(actualTableNames.length, equals(expectedTables.length),
          reason: 'Table count should match expected');

      expect(actualTableNames, equals(expectedTables),
          reason: 'Table names should match expected');

      final indexRows = await database.query(
        'sqlite_master',
        columns: ['name', 'sql'],
        where: "type = 'index' AND name NOT LIKE 'sqlite_%'",
        orderBy: 'name',
      );

      final actualIndexNames =
          indexRows.map((row) => row['name'] as String).toList();

      final expectedIndexNames = DatabaseSchema.createIndexStatements
          .map((sql) {
            final match =
                RegExp(r'CREATE\s+(?:UNIQUE\s+)?INDEX\s+(\w+)').firstMatch(sql);
            return match?.group(1) ?? '';
          })
          .where((name) => name.isNotEmpty)
          .toList();

      for (final expectedIndex in expectedIndexNames) {
        expect(actualIndexNames, contains(expectedIndex),
            reason: 'Index $expectedIndex should exist');
      }
    });
  });
}
