import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

class ApiClient {
  late final Dio dio;

  ApiClient._();

  static final ApiClient instance = ApiClient._();

  Future<void> initialize() async {
    dio = Dio(BaseOptions(
      baseUrl: ApiConstants.currentBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    dio.options.validateStatus = (status) {
      if (status == null) return false;
      return status >= 200 && status < 300 || status == 201;
    };
  }
}
