import 'package:get/get.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../models/login_request.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus {
  unknown,
  unauthenticated,
  authenticating,
  authenticated,
  authenticationFailed,
}

class AuthController extends GetxController {
  final AuthRepository _repository = AuthRepository();
  final SecureStorageService _storage = SecureStorageService.instance;

  var status = AuthStatus.unknown.obs;
  var errorMessage = ''.obs;
  var username = ''.obs;
  var password = ''.obs;
  var firstName = ''.obs;
  var lastName = ''.obs;
  var userID = 0.obs;
  var expiresAt = Rxn<DateTime>();
  var passwordVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  void togglePasswordVisibility() {
    passwordVisible.value = !passwordVisible.value;
  }

  Future<void> _checkAuthStatus() async {
    status.value = AuthStatus.unknown;

    try {
      final token = await _storage.read(key: 'access_token');
      final expiresAtStr = await _storage.read(key: 'expires_at');
      final storedUsername = await _storage.read(key: 'username');
      final storedFirstName = await _storage.read(key: 'first_name');
      final storedLastName = await _storage.read(key: 'last_name');
      final userIdStr = await _storage.read(key: 'user_id');

      if (token == null || token.isEmpty || expiresAtStr == null) {
        status.value = AuthStatus.unauthenticated;
        return;
      }

      final expiresAt = DateTime.tryParse(expiresAtStr);
      if (expiresAt == null || expiresAt.isBefore(DateTime.now().toUtc())) {
        await logout();
        return;
      }

      username.value = storedUsername ?? '';
      firstName.value = storedFirstName ?? '';
      lastName.value = storedLastName ?? '';
      userID.value = int.tryParse(userIdStr ?? '0') ?? 0;
      this.expiresAt.value = expiresAt;
      status.value = AuthStatus.authenticated;
    } catch (e) {
      status.value = AuthStatus.unauthenticated;
    }
  }

  Future<void> login(LoginRequest request) async {
    if (status.value == AuthStatus.authenticating) {
      return;
    }

    status.value = AuthStatus.authenticating;
    errorMessage.value = '';

    try {
      final response = await _repository.login(request);

      if (response.accessToken.isEmpty) {
        throw Exception('Invalid response from server');
      }

      await _storage.write(key: 'access_token', value: response.accessToken);
      await _storage.write(key: 'expires_at', value: response.expiresAt.toIso8601String());
      await _storage.write(key: 'username', value: response.username);
      await _storage.write(key: 'first_name', value: response.firstName);
      await _storage.write(key: 'last_name', value: response.lastName ?? '');
      await _storage.write(key: 'user_id', value: response.userID.toString());

      username.value = response.username;
      firstName.value = response.firstName;
      lastName.value = response.lastName ?? '';
      userID.value = response.userID;
      expiresAt.value = response.expiresAt.toUtc();
      status.value = AuthStatus.authenticated;
    } catch (e) {
      status.value = AuthStatus.authenticationFailed;
      errorMessage.value = e.toString();
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'expires_at');
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'first_name');
    await _storage.delete(key: 'last_name');
    await _storage.delete(key: 'user_id');

    username.value = '';
    firstName.value = '';
    lastName.value = '';
    userID.value = 0;
    expiresAt.value = null;
    errorMessage.value = '';
    status.value = AuthStatus.unauthenticated;
  }
}
