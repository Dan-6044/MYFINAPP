import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient.instance;

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/login',
        data: request.toJson(),
      );

      return LoginResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timed out');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Connection refused');
      }
      if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          throw Exception('Invalid username or password.');
        }
        if (statusCode == 404) {
          throw Exception('Login endpoint not found');
        }
        if (statusCode == 500) {
          throw Exception('Server error');
        }
        throw Exception('HTTP $statusCode');
      }
      if (e.type == DioExceptionType.unknown) {
        throw Exception('Unable to connect to MYFIN server. Check your network connection.');
      }
      throw Exception('Connection failed');
    } catch (e) {
      throw Exception('Invalid response from server');
    }
  }
}
