import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/main_head_repository.dart';

class MainHeadController extends GetxController {
  final MainHeadRepository _repository = MainHeadRepository();

  RxList<dynamic> mainHeads = <dynamic>[].obs;
  RxBool isLoading = false.obs;
  Rx<String?> errorMessage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    loadMainHeads();
  }

  Future<void> loadMainHeads() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final data = await _repository.getAll();
      mainHeads.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createMainHead(Map<String, dynamic> payload) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final created = await _repository.create(payload);
      mainHeads.add(created);
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateMainHead(int mainHeadID, Map<String, dynamic> payload) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final updated = await _repository.update(mainHeadID, payload);
      final index = mainHeads.indexWhere((m) => m.mainHeadID == mainHeadID);
      if (index != -1) {
        mainHeads[index] = updated;
      }
      await loadMainHeads();
      Get.snackbar(
        'Success',
        'Main Head updated successfully.',
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
