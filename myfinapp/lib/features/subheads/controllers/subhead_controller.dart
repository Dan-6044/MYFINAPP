import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/subhead_repository.dart';

class SubheadController extends GetxController {
  final SubheadRepository _repository = SubheadRepository();

  RxList<dynamic> subheads = <dynamic>[].obs;
  RxBool isLoading = false.obs;
  Rx<String?> errorMessage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    loadSubheads();
  }

  Future<void> loadSubheads() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final data = await _repository.getAll();
      subheads.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createSubhead(Map<String, dynamic> payload) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final created = await _repository.create(payload);
      subheads.add(created);
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSubhead(int subheadID, Map<String, dynamic> payload) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final updated = await _repository.update(subheadID, payload);
      final index = subheads.indexWhere((s) => s.subheadID == subheadID);
      if (index != -1) {
        subheads[index] = updated;
      }
      await loadSubheads();
      Get.snackbar(
        'Success',
        'Subhead updated successfully.',
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

  Future<void> setActiveStatus(int subheadID, bool isActive) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _repository.setActiveStatus(subheadID, isActive);
      await loadSubheads();
      Get.snackbar(
        'Success',
        isActive ? 'Subhead activated successfully.' : 'Subhead deactivated successfully.',
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
