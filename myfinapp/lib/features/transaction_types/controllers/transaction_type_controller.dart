import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/transaction_type_repository.dart';
import '../models/transaction_type.dart';

class TransactionTypeController extends GetxController {
  final TransactionTypeRepository _repository = TransactionTypeRepository();

  RxList<TransactionType> transactionTypes = <TransactionType>[].obs;
  RxBool isLoading = false.obs;
  Rx<String?> errorMessage = Rxn<String>();

  List<TransactionType> get activeTransactionTypes =>
      transactionTypes.where((t) => t.isActive).toList();

  @override
  void onInit() {
    super.onInit();
    loadTransactionTypes();
  }

  Future<void> loadTransactionTypes() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final data = await _repository.getAll();
      transactionTypes.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createTransactionType(Map<String, dynamic> payload) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final created = await _repository.create(payload);
      transactionTypes.add(created);
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTransactionType(int transactionTypeId, Map<String, dynamic> payload) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final updated = await _repository.update(transactionTypeId, payload);
      final index = transactionTypes.indexWhere((t) => t.transactionTypeID == transactionTypeId);
      if (index != -1) {
        transactionTypes[index] = updated;
      }
      await loadTransactionTypes();
      Get.snackbar(
        'Success',
        'Transaction type updated successfully.',
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

  Future<void> setActiveStatus(int transactionTypeId, bool isActive) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _repository.setActiveStatus(transactionTypeId, isActive);
      await loadTransactionTypes();
      Get.snackbar(
        'Success',
        isActive ? 'Transaction type activated successfully.' : 'Transaction type deactivated successfully.',
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
