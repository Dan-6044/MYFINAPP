import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/transaction_repository.dart';
import '../models/transaction_model.dart';

class TransactionController extends GetxController {
  final TransactionRepository _repository = TransactionRepository();

  RxList<TransactionListItemModel> transactions = <TransactionListItemModel>[].obs;
  RxBool isLoading = false.obs;
  Rx<String?> errorMessage = Rxn<String>();
  RxInt totalRecords = 0.obs;
  RxInt currentPage = 1.obs;
  RxInt totalPages = 0.obs;
  Rxn<TransactionDetailModel> currentTransaction = Rxn<TransactionDetailModel>();

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  Future<void> loadTransactions({
    int? financialPeriodId,
    String? status,
    int? transactionTypeId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    currentPage.value = page;

    try {
      final list = await _repository.getList(
        financialPeriodId: financialPeriodId,
        status: status,
        transactionTypeId: transactionTypeId,
        startDate: startDate,
        endDate: endDate,
        page: page,
        pageSize: 20,
      );
      transactions.assignAll(list);
      totalRecords.value = 0;
      totalPages.value = 0;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDetails(int transactionId) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final detail = await _repository.getDetails(transactionId);
      currentTransaction.value = detail;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> postTransaction(int transactionId, int postedByUserId) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _repository.post(transactionId, postedByUserId);
      await loadTransactions();
      Get.snackbar(
        'Success',
        'Transaction posted successfully.',
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

  Future<void> voidTransaction(int transactionId, int voidedByUserId, String voidReason) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _repository.voidTransaction(transactionId, voidedByUserId, voidReason);
      await loadTransactions();
      Get.snackbar(
        'Success',
        'Transaction voided successfully.',
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

  Future<void> validateTransaction(int transactionId) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _repository.validate(transactionId);
      await loadTransactions();
      Get.snackbar(
        'Success',
        'Transaction validated successfully.',
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

  Future<TransactionDetailModel> getTransactionDetails(int transactionId) async {
    final detail = await _repository.getDetails(transactionId);
    currentTransaction.value = detail;
    return detail;
  }

  Future<CreateTransactionResponseModel> createTransaction(CreateTransactionRequestModel request) async {
    return await _repository.create(request);
  }
}
