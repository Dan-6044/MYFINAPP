import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/user_repository.dart';
import '../models/user.dart';

class UserController extends GetxController {
  final UserRepository _repository = UserRepository();

  RxList<User> users = <User>[].obs;
  RxBool isLoading = false.obs;
  Rx<String?> errorMessage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers({String? status}) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      if (status != null) {
        final data = await _repository.getAll(status: status);
        users.assignAll(data);
      } else {
        final activeUsers = await _repository.getAll(status: 'A');
        final inactiveUsers = await _repository.getAll(status: 'I');
        users.assignAll([...activeUsers, ...inactiveUsers]);
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createUser(Map<String, dynamic> payload) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final created = await _repository.create(payload);
      users.add(created);
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUser(int userId, Map<String, dynamic> payload) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final updated = await _repository.update(userId, payload);
      final index = users.indexWhere((u) => u.userID == userId);
      if (index != -1) {
        users[index] = updated;
      }
      await loadUsers();
      Get.snackbar(
        'Success',
        'User updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setActiveStatus(int userId, bool isActive) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _repository.setActiveStatus(userId, isActive);
      await loadUsers();
      Get.snackbar(
        'Success',
        isActive ? 'User activated successfully.' : 'User deactivated successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
