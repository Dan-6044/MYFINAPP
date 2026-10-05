import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

class HealthRepository {
  final ApiClient _apiClient = ApiClient.instance;

  Future<Map<String, dynamic>> checkApiHealth() async {
    try {
      final response = await _apiClient.dio.get('/api/health');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw Exception('Invalid response from API');
    }
  }

  Future<Map<String, dynamic>> checkDatabaseHealth() async {
    try {
      final response = await _apiClient.dio.get('/api/health/database');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw Exception('Invalid response from API');
    }
  }

  String _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timed out';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Connection refused';
    }
    if (e.type == DioExceptionType.badResponse) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 404) {
        return 'HTTP 404: endpoint not found';
      }
      if (statusCode == 500) {
        return 'HTTP 500: server error';
      }
      return 'HTTP $statusCode';
    }
    if (e.type == DioExceptionType.unknown) {
      return 'Host unreachable';
    }
    return 'Connection failed';
  }
}
