import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/currency_repository.dart';
import '../models/currency.dart';

class CurrencyController extends GetxController {
  final CurrencyRepository _repository = CurrencyRepository();

  RxList<Currency> currencies = <Currency>[].obs;
  RxBool isLoading = false.obs;
  Rx<String?> errorMessage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    loadCurrencies();
  }

  Future<void> loadCurrencies() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final data = await _repository.getAll();
      currencies.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createCurrency(Map<String, dynamic> payload) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final created = await _repository.create(payload);
      currencies.add(created);
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCurrency(int currencyId, Map<String, dynamic> payload) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final updated = await _repository.update(currencyId, payload);
      final index = currencies.indexWhere((c) => c.currencyID == currencyId);
      if (index != -1) {
        currencies[index] = updated;
      }
      await loadCurrencies();
      Get.snackbar(
        'Success',
        'Currency updated successfully.',
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

  Future<void> setActiveStatus(int currencyId, bool isActive) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _repository.setActiveStatus(currencyId, isActive);
      await loadCurrencies();
      Get.snackbar(
        'Success',
        isActive ? 'Currency activated successfully.' : 'Currency deactivated successfully.',
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
