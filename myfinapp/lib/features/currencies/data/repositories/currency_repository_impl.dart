import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/sync/helpers/sync_transaction_helper.dart';
import '../../domain/repositories/currency_repository.dart';
import '../models/currency_model.dart';
import '../models/create_currency_command.dart';
import '../models/update_currency_command.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  Future<Database> get _databaseFuture => AppDatabase.instance.database;

  @override
  Future<List<CurrencyModel>> getAll() async {
    final database = await _databaseFuture;
    final rows = await database.query(
      'currencies',
      columns: const [
        'currency_id',
        'currency_code',
        'currency_name',
        'currency_symbol',
        'decimal_places',
        'is_base_currency',
        'is_active',
        'created_at',
      ],
      orderBy: 'currency_code',
    );
    return rows.map(CurrencyModel.fromMap).toList();
  }

  @override
  Future<CurrencyModel?> getById(int currencyId) async {
    final database = await _databaseFuture;
    final rows = await database.query(
      'currencies',
      columns: const [
        'currency_id',
        'currency_code',
        'currency_name',
        'currency_symbol',
        'decimal_places',
        'is_base_currency',
        'is_active',
        'created_at',
      ],
      where: 'currency_id = ?',
      whereArgs: [currencyId],
    );
    if (rows.isEmpty) return null;
    return CurrencyModel.fromMap(rows.first);
  }

  @override
  Future<CurrencyModel?> getByCode(String currencyCode) async {
    final normalizedCode = currencyCode.trim();
    final database = await _databaseFuture;
    final rows = await database.query(
      'currencies',
      columns: const [
        'currency_id',
        'currency_code',
        'currency_name',
        'currency_symbol',
        'decimal_places',
        'is_base_currency',
        'is_active',
        'created_at',
      ],
      where: 'currency_code = ?',
      whereArgs: [normalizedCode],
    );
    if (rows.isEmpty) return null;
    return CurrencyModel.fromMap(rows.first);
  }

  @override
  Future<List<CurrencyModel>> getActive() async {
    final database = await _databaseFuture;
    final rows = await database.query(
      'currencies',
      columns: const [
        'currency_id',
        'currency_code',
        'currency_name',
        'currency_symbol',
        'decimal_places',
        'is_base_currency',
        'is_active',
        'created_at',
      ],
      where: 'is_active = 1',
      orderBy: 'currency_code',
    );
    return rows.map(CurrencyModel.fromMap).toList();
  }

  @override
  Future<CurrencyModel?> getBaseCurrency() async {
    final database = await _databaseFuture;
    final rows = await database.query(
      'currencies',
      columns: const [
        'currency_id',
        'currency_code',
        'currency_name',
        'currency_symbol',
        'decimal_places',
        'is_base_currency',
        'is_active',
        'created_at',
      ],
      where: 'is_base_currency = 1',
    );
    if (rows.isEmpty) return null;
    if (rows.length > 1) {
      throw Exception('Multiple base currencies found');
    }
    return CurrencyModel.fromMap(rows.first);
  }

  @override
  Future<CurrencyModel> create(CreateCurrencyCommand command) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final database = await _databaseFuture;

    return await database.transaction((txn) async {
      final generatedId = await txn.insert(
        'currencies',
        {
          'currency_code': command.currencyCode,
          'currency_name': command.currencyName,
          'currency_symbol': command.currencySymbol,
          'decimal_places': command.decimalPlaces,
          'is_base_currency': command.isBaseCurrency ? 1 : 0,
          'is_active': 1,
          'created_at': now,
        },
      );

      final rows = await txn.query(
        'currencies',
        columns: const [
          'currency_id',
          'currency_code',
          'currency_name',
          'currency_symbol',
          'decimal_places',
          'is_base_currency',
          'is_active',
          'created_at',
        ],
        where: 'currency_id = ?',
        whereArgs: [generatedId],
      );

      if (rows.isEmpty) {
        throw Exception('Failed to read created currency');
      }

      final currency = CurrencyModel.fromMap(rows.first);

      await txn.insert('sync_outbox', {
        'entity_name': 'currencies',
        'entity_id': generatedId,
        'operation': 'CREATE',
        'payload_json': jsonEncode(command.toJson()),
        'created_at': now,
        'attempt_count': 0,
        'status': 'PENDING',
      });

      return currency;
    });
  }

  @override
  Future<CurrencyModel> update(int currencyId, UpdateCurrencyCommand command) async {
    final payload = {
      'currencyId': currencyId,
      'currencyCode': command.currencyCode,
      'currencyName': command.currencyName,
      if (command.currencySymbol != null) 'currencySymbol': command.currencySymbol,
      'decimalPlaces': command.decimalPlaces,
      'isBaseCurrency': command.isBaseCurrency,
    };

    return await SyncTransactionHelper().withSyncTransaction(
      entityName: 'currencies',
      entityId: currencyId,
      operation: 'UPDATE',
      payloadJson: jsonEncode(payload),
      businessOperation: (txn) async {
        await txn.update(
          'currencies',
          {
            'currency_code': command.currencyCode,
            'currency_name': command.currencyName,
            'currency_symbol': command.currencySymbol,
            'decimal_places': command.decimalPlaces,
            'is_base_currency': command.isBaseCurrency ? 1 : 0,
          },
          where: 'currency_id = ?',
          whereArgs: [currencyId],
        );

        final rows = await txn.query(
          'currencies',
          columns: const [
            'currency_id',
            'currency_code',
            'currency_name',
            'currency_symbol',
            'decimal_places',
            'is_base_currency',
            'is_active',
            'created_at',
          ],
          where: 'currency_id = ?',
          whereArgs: [currencyId],
        );

        if (rows.isEmpty) {
          throw Exception('Failed to read updated currency');
        }

        return CurrencyModel.fromMap(rows.first);
      },
    );
  }

  @override
  Future<CurrencyModel> activate(int currencyId) async {
    final existing = await getById(currencyId);
    if (existing == null) {
      throw Exception('Currency not found');
    }

    final payload = {'currencyId': currencyId, 'action': 'activate'};

    return await SyncTransactionHelper().withSyncTransaction(
      entityName: 'currencies',
      entityId: currencyId,
      operation: 'UPDATE',
      payloadJson: jsonEncode(payload),
      businessOperation: (txn) async {
        await txn.update(
          'currencies',
          {'is_active': 1},
          where: 'currency_id = ?',
          whereArgs: [currencyId],
        );

        final rows = await txn.query(
          'currencies',
          columns: const [
            'currency_id',
            'currency_code',
            'currency_name',
            'currency_symbol',
            'decimal_places',
            'is_base_currency',
            'is_active',
            'created_at',
          ],
          where: 'currency_id = ?',
          whereArgs: [currencyId],
        );

        if (rows.isEmpty) {
          throw Exception('Failed to read activated currency');
        }

        return CurrencyModel.fromMap(rows.first);
      },
    );
  }

  @override
  Future<CurrencyModel> deactivate(int currencyId) async {
    final existing = await getById(currencyId);
    if (existing == null) {
      throw Exception('Currency not found');
    }

    if (existing.isBaseCurrency) {
      throw Exception('Base currency cannot be deactivated');
    }

    final payload = {'currencyId': currencyId, 'action': 'deactivate'};

    return await SyncTransactionHelper().withSyncTransaction(
      entityName: 'currencies',
      entityId: currencyId,
      operation: 'UPDATE',
      payloadJson: jsonEncode(payload),
      businessOperation: (txn) async {
        await txn.update(
          'currencies',
          {'is_active': 0},
          where: 'currency_id = ?',
          whereArgs: [currencyId],
        );

        final rows = await txn.query(
          'currencies',
          columns: const [
            'currency_id',
            'currency_code',
            'currency_name',
            'currency_symbol',
            'decimal_places',
            'is_base_currency',
            'is_active',
            'created_at',
          ],
          where: 'currency_id = ?',
          whereArgs: [currencyId],
        );

        if (rows.isEmpty) {
          throw Exception('Failed to read deactivated currency');
        }

        return CurrencyModel.fromMap(rows.first);
      },
    );
  }
}
