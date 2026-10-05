import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/transaction_type_rule_repository.dart';

class TransactionTypeRuleController extends GetxController {
  final TransactionTypeRuleRepository _repository = TransactionTypeRuleRepository();

  RxList<dynamic> transactionTypeRules = <dynamic>[].obs;
  RxBool isLoading = false.obs;
  Rx<String?> errorMessage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    loadTransactionTypeRules();
  }

  Future<void> loadTransactionTypeRules({int? transactionTypeId, String? entrySide}) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final data = await _repository.getAll(transactionTypeId: transactionTypeId, entrySide: entrySide);
      transactionTypeRules.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createTransactionTypeRule(Map<String, dynamic> payload) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final created = await _repository.create(payload);
      transactionTypeRules.add(created);
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTransactionTypeRule(int transactionTypeRuleId, Map<String, dynamic> payload) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final updated = await _repository.update(transactionTypeRuleId, payload);
      final index = transactionTypeRules.indexWhere((r) => r.transactionTypeRuleID == transactionTypeRuleId);
      if (index != -1) {
        transactionTypeRules[index] = updated;
      }
      await loadTransactionTypeRules();
      Get.snackbar(
        'Success',
        'Transaction type rule updated successfully.',
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
