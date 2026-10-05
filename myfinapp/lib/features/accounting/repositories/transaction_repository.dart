import 'package:dio/dio.dart';
import 'package:myfinapp/core/network/api_client.dart';
import 'package:myfinapp/core/storage/secure_storage_service.dart';
import 'package:myfinapp/features/accounting/models/transaction_model.dart';

class TransactionRepository {
  final ApiClient _apiClient = ApiClient.instance;
  final SecureStorageService _storage = SecureStorageService.instance;

  Future<List<TransactionListItemModel>> getList({
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
        '/api/transactions',
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
      final list = TransactionListModel.fromJson(data);
      return list.transactions;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        String? message;
        if (responseData is Map) {
          message = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              responseData.toString();
        } else if (responseData is String) {
          message = responseData;
        } else {
          message = e.toString();
        }
        throw Exception(message ?? 'HTTP $statusCode');
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timed out');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Connection refused');
      }
      if (e.type == DioExceptionType.unknown) {
        throw Exception('Host unreachable: ${e.error}');
      }
      throw Exception('Connection failed: ${e.type}');
    } catch (e) {
      throw Exception('Invalid response from server: $e');
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
      if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        String? message;
        if (responseData is Map) {
          message = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              responseData.toString();
        } else if (responseData is String) {
          message = responseData;
        } else {
          message = e.toString();
        }
        throw Exception(message ?? 'HTTP $statusCode');
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timed out');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Connection refused');
      }
      if (e.type == DioExceptionType.unknown) {
        throw Exception('Host unreachable: ${e.error}');
      }
      throw Exception('Connection failed: ${e.type}');
    } catch (e) {
      throw Exception('Invalid response from server: $e');
    }
  }

  Future<CreateTransactionResponseModel> create(CreateTransactionRequestModel request) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No access token available');
    }

    try {
      final response = await _apiClient.dio.post(
        '/api/transactions',
        data: request.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return CreateTransactionResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        String? message;
        if (responseData is Map) {
          message = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              responseData.toString();
        } else if (responseData is String) {
          message = responseData;
        } else {
          message = e.toString();
        }
        throw Exception(message ?? 'HTTP $statusCode');
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timed out');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Connection refused');
      }
      if (e.type == DioExceptionType.unknown) {
        throw Exception('Host unreachable: ${e.error}');
      }
      throw Exception('Connection failed: ${e.type}');
    } catch (e) {
      throw Exception('Invalid response from server: $e');
    }
  }

  Future<PostTransactionResponseModel> post(int transactionId, int postedByUserId) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No access token available');
    }

    try {
      final response = await _apiClient.dio.post(
        '/api/transactions/$transactionId/post',
        queryParameters: {'postedByUserId': postedByUserId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return PostTransactionResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        String? message;
        if (responseData is Map) {
          message = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              responseData.toString();
        } else if (responseData is String) {
          message = responseData;
        } else {
          message = e.toString();
        }
        throw Exception(message ?? 'HTTP $statusCode');
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timed out');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Connection refused');
      }
      if (e.type == DioExceptionType.unknown) {
        throw Exception('Host unreachable: ${e.error}');
      }
      throw Exception('Connection failed: ${e.type}');
    } catch (e) {
      throw Exception('Invalid response from server: $e');
    }
  }

  Future<VoidTransactionResponseModel> voidTransaction(int transactionId, int voidedByUserId, String voidReason) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No access token available');
    }

    try {
      final response = await _apiClient.dio.post(
        '/api/transactions/$transactionId/void',
        queryParameters: {
          'voidedByUserId': voidedByUserId,
          'voidReason': voidReason,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return VoidTransactionResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        String? message;
        if (responseData is Map) {
          message = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              responseData.toString();
        } else if (responseData is String) {
          message = responseData;
        } else {
          message = e.toString();
        }
        throw Exception(message ?? 'HTTP $statusCode');
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timed out');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Connection refused');
      }
      if (e.type == DioExceptionType.unknown) {
        throw Exception('Host unreachable: ${e.error}');
      }
      throw Exception('Connection failed: ${e.type}');
    } catch (e) {
      throw Exception('Invalid response from server: $e');
    }
  }

  Future<ValidateTransactionResponseModel> validate(int transactionId) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No access token available');
    }

    try {
      final response = await _apiClient.dio.post(
        '/api/transactions/$transactionId/validate',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return ValidateTransactionResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        String? message;
        if (responseData is Map) {
          message = responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              responseData.toString();
        } else if (responseData is String) {
          message = responseData;
        } else {
          message = e.toString();
        }
        throw Exception(message ?? 'HTTP $statusCode');
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timed out');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Connection refused');
      }
      if (e.type == DioExceptionType.unknown) {
        throw Exception('Host unreachable: ${e.error}');
      }
      throw Exception('Connection failed: ${e.type}');
    } catch (e) {
      throw Exception('Invalid response from server: $e');
    }
  }
}
