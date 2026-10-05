import 'package:dio/dio.dart';
import 'package:myfinapp/core/network/api_client.dart';
import 'package:myfinapp/core/storage/secure_storage_service.dart';
import 'package:myfinapp/features/accounting/models/transaction_model.dart';

class JournalRepository {
  final ApiClient _apiClient = ApiClient.instance;
  final SecureStorageService _storage = SecureStorageService.instance;

  Future<List<JournalListItemModel>> getList({
    int? financialPeriodId,
    String? status,
    int? transactionTypeId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No access token available');
    }

    try {
      final response = await _apiClient.dio.get(
        '/api/journals',
        queryParameters: {
          if (financialPeriodId != null) 'financialPeriodId': financialPeriodId,
          if (status != null) 'status': status,
          if (transactionTypeId != null) 'transactionTypeId': transactionTypeId,
          if (startDate != null) 'startDate': startDate.toIso8601String().split('T')[0],
          if (endDate != null) 'endDate': endDate.toIso8601String().split('T')[0],
          'page': page,
          'pageSize': pageSize,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = response.data as Map<String, dynamic>;
      final list = JournalListModel.fromJson(data);
      return list.journals;
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

        if (message != null &&
            (message.contains('open DataReader') ||
                message.contains('SqlDataReader') ||
                message.contains('Microsoft.Data.SqlClient') ||
                message.contains('System.InvalidOperationException'))) {
          message = 'We could not load journals at this time.';
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

  Future<JournalDetailModel> getDetails(int journalId) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No access token available');
    }

    try {
      final response = await _apiClient.dio.get(
        '/api/journals/$journalId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return JournalDetailModel.fromJson(response.data as Map<String, dynamic>);
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

        if (message != null &&
            (message.contains('open DataReader') ||
                message.contains('SqlDataReader') ||
                message.contains('Microsoft.Data.SqlClient') ||
                message.contains('System.InvalidOperationException'))) {
          message = 'We could not load journal details at this time.';
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
