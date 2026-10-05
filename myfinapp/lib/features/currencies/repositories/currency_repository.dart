import 'package:dio/dio.dart';
import 'package:myfinapp/core/network/api_client.dart';
import 'package:myfinapp/core/storage/secure_storage_service.dart';
import 'package:myfinapp/features/currencies/models/currency.dart';

class CurrencyRepository {
  final ApiClient _apiClient = ApiClient.instance;
  final SecureStorageService _storage = SecureStorageService.instance;

  Future<List<Currency>> getAll({bool? isActive}) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No access token available');
    }

    try {
      final response = await _apiClient.dio.get(
        '/api/currencies',
        queryParameters: isActive != null ? {'isActive': isActive} : null,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((item) => Currency.fromJson(item as Map<String, dynamic>))
          .toList();
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
        if (statusCode == 404) {
          throw Exception(message ?? 'HTTP 404: endpoint not found');
        }
        if (statusCode == 500) {
          throw Exception(message ?? 'HTTP 500: server error');
        }
        throw Exception(message ?? 'HTTP $statusCode');
      }
      if (e.type == DioExceptionType.unknown) {
        throw Exception('Host unreachable');
      }
      throw Exception('Connection failed');
    } catch (e) {
      throw Exception('Invalid response from server: $e');
    }
  }

  Future<Currency> create(Map<String, dynamic> payload) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No access token available');
    }

    try {
      final response = await _apiClient.dio.post(
        '/api/currencies',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Currency.fromJson(response.data as Map<String, dynamic>);
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
        if (statusCode == 400) {
          throw Exception(message ?? 'HTTP 400: invalid request');
        }
        if (statusCode == 404) {
          throw Exception(message ?? 'HTTP 404: not found');
        }
        if (statusCode == 409) {
          throw Exception(message ?? 'HTTP 409: conflict');
        }
        if (statusCode == 500) {
          throw Exception(message ?? 'HTTP 500: server error');
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

  Future<Currency> update(int currencyId, Map<String, dynamic> payload) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No access token available');
    }

    try {
      final response = await _apiClient.dio.put(
        '/api/currencies/$currencyId',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Currency.fromJson(response.data as Map<String, dynamic>);
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
        if (statusCode == 400) {
          throw Exception(message ?? 'HTTP 400: invalid request');
        }
        if (statusCode == 404) {
          throw Exception(message ?? 'HTTP 404: currency not found');
        }
        if (statusCode == 409) {
          throw Exception(message ?? 'HTTP 409: conflict');
        }
        if (statusCode == 500) {
          throw Exception(message ?? 'HTTP 500: server error');
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

  Future<Currency> setActiveStatus(int currencyId, bool isActive) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No access token available');
    }

    final endpoint = isActive ? 'activate' : 'deactivate';

    try {
      final response = await _apiClient.dio.patch(
        '/api/currencies/$currencyId/$endpoint',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Currency.fromJson(response.data as Map<String, dynamic>);
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
        if (statusCode == 404) {
          throw Exception(message ?? 'HTTP 404: currency not found');
        }
        if (statusCode == 409) {
          throw Exception(message ?? 'HTTP 409: base currency cannot be deactivated');
        }
        if (statusCode == 500) {
          throw Exception(message ?? 'HTTP 500: server error');
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
