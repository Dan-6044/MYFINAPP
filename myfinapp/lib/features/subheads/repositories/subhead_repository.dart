import 'package:dio/dio.dart';
import 'package:myfinapp/core/network/api_client.dart';
import 'package:myfinapp/core/storage/secure_storage_service.dart';
import 'package:myfinapp/features/subheads/models/subhead.dart';

class SubheadRepository {
  final ApiClient _apiClient = ApiClient.instance;
  final SecureStorageService _storage = SecureStorageService.instance;

  Future<List<Subhead>> getAll() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No access token available');
    }

    try {
      final response = await _apiClient.dio.get(
        '/api/subheads',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((item) => Subhead.fromJson(item as Map<String, dynamic>))
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

  Future<Subhead> create(Map<String, dynamic> payload) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No access token available');
    }

    try {
      final response = await _apiClient.dio.post(
        '/api/subheads',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Subhead.fromJson(response.data as Map<String, dynamic>);
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

  Future<Subhead> update(int subheadID, Map<String, dynamic> payload) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No access token available');
    }

    try {
      final response = await _apiClient.dio.put(
        '/api/subheads/$subheadID',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Subhead.fromJson(response.data as Map<String, dynamic>);
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
          throw Exception('HTTP 404: subhead not found');
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

  Future<Subhead> setActiveStatus(int subheadID, bool isActive) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No access token available');
    }

    final endpoint = isActive ? 'activate' : 'deactivate';

    try {
      final response = await _apiClient.dio.patch(
        '/api/subheads/$subheadID/$endpoint',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Subhead.fromJson(response.data as Map<String, dynamic>);
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
          throw Exception('HTTP 404: subhead not found');
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
