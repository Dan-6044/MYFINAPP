import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:myfinapp/core/network/api_client.dart';
import 'package:myfinapp/core/storage/secure_storage_service.dart';
import 'package:myfinapp/features/accounting/models/transaction_model.dart';
import 'package:myfinapp/features/transaction_types/controllers/transaction_type_controller.dart';

class CreditLoansRepository {
  final ApiClient _apiClient = ApiClient.instance;
  final SecureStorageService _storage = SecureStorageService.instance;

  Future<List<TransactionListItemModel>> getList({
    int? financialPeriodId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No access token available');
    }

    final transactionTypeController = Get.find<TransactionTypeController>();
    await transactionTypeController.loadTransactionTypes();

    final creditLoansTypeNames = <String>[
      'Credit Received',
      'Money Received',
    ];

    final matchedTypes = transactionTypeController.transactionTypes.where((t) {
      final normalized = t.transactionTypeName.toLowerCase();
      return creditLoansTypeNames.any((name) => normalized == name.toLowerCase());
    }).toList();

    if (matchedTypes.isEmpty) {
      return <TransactionListItemModel>[];
    }

    final typeIds = matchedTypes.map((t) => t.transactionTypeID).toList();

    try {
      final allResults = <TransactionListItemModel>[];

      for (final typeId in typeIds) {
        final response = await _apiClient.dio.get(
          '/api/transactions',
          queryParameters: {
            if (financialPeriodId != null) 'financialPeriodId': financialPeriodId,
            if (status != null) 'status': status,
            'transactionTypeId': typeId,
            if (startDate != null) 'startDate': startDate.toIso8601String().split('T')[0],
            if (endDate != null) 'endDate': endDate.toIso8601String().split('T')[0],
            'page': page,
            'pageSize': pageSize,
          },
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );

        final data = response.data as Map<String, dynamic>;
        final list = TransactionListModel.fromJson(data);
        allResults.addAll(list.transactions);
      }

      allResults.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

      final start = (page - 1) * pageSize;
      final end = start + pageSize;
      return allResults.length <= start
          ? <TransactionListItemModel>[]
          : allResults.sublist(start, end > allResults.length ? allResults.length : end);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timed out');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Connection refused');
      }
      if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        String? message;
        if (responseData is Map) {
          message = responseData['message']?.toString();
        } else if (responseData is String) {
          message = responseData;
        }
        throw Exception(message ?? 'HTTP $statusCode');
      }
      if (e.type == DioExceptionType.unknown) {
        throw Exception('Host unreachable');
      }
      throw Exception('Connection failed');
    } catch (e) {
      throw Exception('Invalid response from server');
    }
  }

  Future<TransactionDetailModel> getDetails(int transactionId) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No access token available');
    }

    try {
      final response = await _apiClient.dio.get(
        '/api/transactions/$transactionId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return TransactionDetailModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timed out');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Connection refused');
      }
      if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        String? message;
        if (responseData is Map) {
          message = responseData['message']?.toString();
        } else if (responseData is String) {
          message = responseData;
        }
        throw Exception(message ?? 'HTTP $statusCode');
      }
      if (e.type == DioExceptionType.unknown) {
        throw Exception('Host unreachable');
      }
      throw Exception('Connection failed');
    } catch (e) {
      throw Exception('Invalid response from server');
    }
  }
}
