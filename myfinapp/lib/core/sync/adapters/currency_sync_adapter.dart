import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:myfinapp/core/network/api_client.dart';
import 'package:myfinapp/core/storage/secure_storage_service.dart';
import 'package:myfinapp/core/sync/models/sync_outbox_item.dart';
import 'package:myfinapp/core/sync/repositories/sync_repository.dart';
import 'package:myfinapp/features/currencies/domain/repositories/currency_repository.dart';
import 'package:myfinapp/features/currencies/data/models/update_currency_command.dart';

class CurrencySyncAdapter {
  final ApiClient _apiClient = ApiClient.instance;
  final SecureStorageService _storage = SecureStorageService.instance;
  final CurrencyRepository _currencyRepository;
  final SyncRepository _syncRepository;

  CurrencySyncAdapter({
    required CurrencyRepository currencyRepository,
    required SyncRepository syncRepository,
  })  : _currencyRepository = currencyRepository,
        _syncRepository = syncRepository;

  Future<void> processOutbox() async {
    final pendingItems = await _syncRepository.getPendingItems();
    final currencyItems = pendingItems
        .where((item) => item.entityName == 'currencies')
        .toList();

    for (final item in currencyItems) {
      await _processItem(item);
    }
  }

  Future<void> _processItem(SyncOutboxItem item) async {
    try {
      await _syncRepository.markProcessing(item.outboxId);

      final payload = jsonDecode(item.payloadJson) as Map<String, dynamic>;

      switch (item.operation) {
        case 'CREATE':
          await _syncCreate(item, payload);
          break;
        case 'UPDATE':
          await _syncUpdate(item, payload);
          break;
        case 'DELETE':
          await _syncDelete(item, payload);
          break;
        default:
          await _syncRepository.markFailed(
            item.outboxId,
            lastError: 'Unsupported operation: ${item.operation}',
          );
      }
    } catch (e) {
      await _syncRepository.markFailed(
        item.outboxId,
        lastError: e.toString(),
      );
    }
  }

  Future<void> _syncCreate(SyncOutboxItem item, Map<String, dynamic> payload) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No access token available');
    }

    final response = await _apiClient.dio.post(
      '/api/currencies',
      data: payload,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final serverCurrency = CurrencyResponse.fromJson(response.data as Map<String, dynamic>);
    final localCurrency = await _currencyRepository.getById(item.entityId);

    if (localCurrency != null && localCurrency.currencyId != serverCurrency.currencyId) {
      await _currencyRepository.update(localCurrency.currencyId, UpdateCurrencyCommand(
        currencyCode: serverCurrency.currencyCode,
        currencyName: serverCurrency.currencyName,
        currencySymbol: serverCurrency.currencySymbol,
        decimalPlaces: serverCurrency.decimalPlaces,
        isBaseCurrency: serverCurrency.isBaseCurrency,
      ));
    }

    await _syncRepository.markSynced(item.outboxId);
  }

  Future<void> _syncUpdate(SyncOutboxItem item, Map<String, dynamic> payload) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No access token available');
    }

    final currencyId = item.entityId;
    final action = payload['action'] as String?;

    if (action == 'activate') {
      await _apiClient.dio.patch(
        '/api/currencies/$currencyId/activate',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } else if (action == 'deactivate') {
      await _apiClient.dio.patch(
        '/api/currencies/$currencyId/deactivate',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } else {
      await _apiClient.dio.put(
        '/api/currencies/$currencyId',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    }

    await _syncRepository.markSynced(item.outboxId);
  }

  Future<void> _syncDelete(SyncOutboxItem item, Map<String, dynamic> payload) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No access token available');
    }

    await _apiClient.dio.delete(
      '/api/currencies/${item.entityId}',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    await _syncRepository.markSynced(item.outboxId);
  }
}

class CurrencyResponse {
  final int currencyId;
  final String currencyCode;
  final String currencyName;
  final String? currencySymbol;
  final int decimalPlaces;
  final bool isBaseCurrency;
  final bool isActive;
  final int accountCount;
  final DateTime createdAt;

  CurrencyResponse({
    required this.currencyId,
    required this.currencyCode,
    required this.currencyName,
    this.currencySymbol,
    required this.decimalPlaces,
    required this.isBaseCurrency,
    required this.isActive,
    required this.accountCount,
    required this.createdAt,
  });

  factory CurrencyResponse.fromJson(Map<String, dynamic> json) {
    return CurrencyResponse(
      currencyId: json['currencyID'] as int,
      currencyCode: json['currencyCode'] as String,
      currencyName: json['currencyName'] as String,
      currencySymbol: json['currencySymbol'] as String?,
      decimalPlaces: json['decimalPlaces'] as int,
      isBaseCurrency: json['isBaseCurrency'] as bool,
      isActive: json['isActive'] as bool,
      accountCount: json['accountCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currencyID': currencyId,
      'currencyCode': currencyCode,
      'currencyName': currencyName,
      'currencySymbol': currencySymbol,
      'decimalPlaces': decimalPlaces,
      'isBaseCurrency': isBaseCurrency,
      'isActive': isActive,
      'accountCount': accountCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
