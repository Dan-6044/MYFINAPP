import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/account_repository.dart';

class AccountController extends GetxController {
  final AccountRepository _repository = AccountRepository();

  RxList<dynamic> accounts = <dynamic>[].obs;
  RxBool isLoading = false.obs;
  Rx<String?> errorMessage = Rxn<String>();

  List<dynamic> get postableAccounts =>
      accounts.where((a) => (a as dynamic).isActive == true && (a as dynamic).allowDirectPosting == true).toList();

  @override
  void onInit() {
    super.onInit();
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final data = await _repository.getAll();
      accounts.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createAccount(Map<String, dynamic> payload) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final created = await _repository.create(payload);
      accounts.add(created);
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateAccount(int coaId, Map<String, dynamic> payload) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final updated = await _repository.update(coaId, payload);
      final index = accounts.indexWhere((a) => a.coaID == coaId);
      if (index != -1) {
        accounts[index] = updated;
      }
      await loadAccounts();
      Get.snackbar(
        'Success',
        'Account updated successfully.',
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

  Future<void> setActiveStatus(int coaId, bool isActive) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _repository.setActiveStatus(coaId, isActive);
      await loadAccounts();
      Get.snackbar(
        'Success',
        isActive ? 'Account activated successfully.' : 'Account deactivated successfully.',
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
