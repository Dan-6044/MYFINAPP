import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/financial_period_repository.dart';
import '../models/financial_period.dart';
import '../../../../modules/auth/controllers/auth_controller.dart';

class FinancialPeriodController extends GetxController {
  final FinancialPeriodRepository _repository = FinancialPeriodRepository();
  final AuthController _authController = Get.find<AuthController>();

  RxList<dynamic> periods = <dynamic>[].obs;
  RxBool isLoading = false.obs;
  Rx<String?> errorMessage = Rxn<String>();

  List<dynamic> get openPeriods => periods.where((p) => (p as dynamic).status == 'OPEN').toList();

  @override
  void onInit() {
    super.onInit();
    loadPeriods(userId: _authController.userID.value);
  }

  Future<void> loadPeriods({int? userId}) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final data = await _repository.getAll(userId: userId);
      periods.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createPeriod(Map<String, dynamic> payload) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final created = await _repository.create(payload);
      periods.add(created);
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePeriod(int financialPeriodID, Map<String, dynamic> payload) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final updated = await _repository.update(financialPeriodID, payload);
      final index = periods.indexWhere((p) => p.financialPeriodID == financialPeriodID);
      if (index != -1) {
        periods[index] = updated;
      }
      await loadPeriods(userId: _authController.userID.value);
      Get.snackbar(
        'Success',
        'Financial period updated successfully.',
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

  Future<void> closePeriod(FinancialPeriod period) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _repository.close(period);
      await loadPeriods(userId: _authController.userID.value);
      Get.snackbar(
        'Success',
        'Financial period closed successfully.',
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
