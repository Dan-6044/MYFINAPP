import 'package:dio/dio.dart';
import 'package:myfinapp/core/network/api_client.dart';
import 'package:myfinapp/core/storage/secure_storage_service.dart';
import 'package:myfinapp/features/financial_periods/models/financial_period.dart';

class FinancialPeriodRepository {
  final ApiClient _apiClient = ApiClient.instance;
  final SecureStorageService _storage = SecureStorageService.instance;

  Future<List<FinancialPeriod>> getAll({int? userId}) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No access token available');
    }

    try {
      final response = await _apiClient.dio.get(
        '/api/financial-periods',
        queryParameters: userId != null && userId > 0 ? {'userId': userId} : null,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data as List<dynamic>;
      final periods = data
          .map((item) => FinancialPeriod.fromJson(item as Map<String, dynamic>))
          .toList();

      periods.sort((a, b) => b.startDate.compareTo(a.startDate));
      return periods;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timed out');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Connection refused');
      }
      if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          throw Exception('HTTP 404: endpoint not found');
        }
        if (statusCode == 500) {
          throw Exception('HTTP 500: server error');
        }
        throw Exception('HTTP $statusCode');
      }
      if (e.type == DioExceptionType.unknown) {
        throw Exception('Host unreachable');
      }
      throw Exception('Connection failed');
    } catch (e) {
      throw Exception('Invalid response from server');
    }
  }

  Future<FinancialPeriod> create(Map<String, dynamic> payload) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No access token available');
    }

    try {
      final response = await _apiClient.dio.post(
        '/api/financial-periods',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return FinancialPeriod.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timed out');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Connection refused');
      }
      if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 400) {
          final message = e.response?.data is Map
              ? (e.response?.data as Map)['message']?.toString()
              : null;
          throw Exception(message ?? 'HTTP 400: invalid request');
        }
        if (statusCode == 409) {
          final message = e.response?.data is Map
              ? (e.response?.data as Map)['message']?.toString()
              : null;
          throw Exception(message ?? 'HTTP 409: conflict');
        }
        if (statusCode == 500) {
          throw Exception('HTTP 500: server error');
        }
        throw Exception('HTTP $statusCode');
      }
      if (e.type == DioExceptionType.unknown) {
        throw Exception('Host unreachable');
      }
      throw Exception('Connection failed');
    } catch (e) {
      throw Exception('Invalid response from server');
    }
  }

  Future<FinancialPeriod> update(int financialPeriodID, Map<String, dynamic> payload) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No access token available');
    }

    try {
      final response = await _apiClient.dio.put(
        '/api/financial-periods/$financialPeriodID',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return FinancialPeriod.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timed out');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Connection refused');
      }
      if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 400) {
          final message = e.response?.data is Map
              ? (e.response?.data as Map)['message']?.toString()
              : null;
          throw Exception(message ?? 'HTTP 400: invalid request');
        }
        if (statusCode == 404) {
          throw Exception('HTTP 404: financial period not found');
        }
        if (statusCode == 405) {
          final responseBody = e.response?.data;
          String detail;
          if (responseBody is Map) {
            detail = responseBody.values.map((e) => e.toString()).join(' | ');
          } else if (responseBody is List) {
            detail = responseBody.map((e) => e.toString()).join(' | ');
          } else {
            detail = responseBody?.toString() ?? 'no response body';
          }
          throw Exception('HTTP 405: update endpoint not allowed | $detail');
        }
        if (statusCode == 409) {
          final message = e.response?.data is Map
              ? (e.response?.data as Map)['message']?.toString()
              : null;
          throw Exception(message ?? 'HTTP 409: conflict');
        }
        if (statusCode == 500) {
          throw Exception('HTTP 500: server error');
        }
        throw Exception('HTTP $statusCode');
      }
      if (e.type == DioExceptionType.unknown) {
        throw Exception('Host unreachable');
      }
      throw Exception('Connection failed');
    } catch (e) {
      throw Exception('Invalid response from server');
    }
  }

  Future<FinancialPeriod> close(FinancialPeriod period) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No access token available');
    }

    try {
      final response = await _apiClient.dio.patch(
        '/api/financial-periods/${period.financialPeriodID}',
        data: const <String, dynamic>{},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return FinancialPeriod.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timed out');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Connection refused');
      }
      if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 400) {
          final message = e.response?.data is Map
              ? (e.response?.data as Map)['message']?.toString()
              : null;
          throw Exception(message ?? 'HTTP 400: invalid request');
        }
        if (statusCode == 404) {
          throw Exception('HTTP 404: financial period not found');
        }
        if (statusCode == 405) {
          final responseBody = e.response?.data;
          String detail;
          if (responseBody is Map) {
            detail = responseBody.values.map((e) => e.toString()).join(' | ');
          } else if (responseBody is List) {
            detail = responseBody.map((e) => e.toString()).join(' | ');
          } else {
            detail = responseBody?.toString() ?? 'no response body';
          }
          throw Exception('HTTP 405: update endpoint not allowed | $detail');
        }
        if (statusCode == 409) {
          final message = e.response?.data is Map
              ? (e.response?.data as Map)['message']?.toString()
              : null;
          throw Exception(message ?? 'HTTP 409: conflict');
        }
        if (statusCode == 500) {
          throw Exception('HTTP 500: server error');
        }
        throw Exception('HTTP $statusCode');
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
