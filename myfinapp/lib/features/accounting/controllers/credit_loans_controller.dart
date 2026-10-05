import 'package:get/get.dart';
import '../repositories/credit_loans_repository.dart';
import '../models/transaction_model.dart';

class CreditLoansController extends GetxController {
  final CreditLoansRepository _repository = CreditLoansRepository();

  RxList<TransactionListItemModel> creditLoans = <TransactionListItemModel>[].obs;
  RxBool isLoading = false.obs;
  Rx<String?> errorMessage = Rxn<String?>();
  RxInt totalRecords = 0.obs;
  RxInt currentPage = 1.obs;
  RxInt totalPages = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadCreditLoans();
  }

  Future<void> loadCreditLoans({
    int? financialPeriodId,
    String? status,
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
        startDate: startDate,
        endDate: endDate,
        page: page,
        pageSize: 20,
      );
      creditLoans.assignAll(list);
      totalRecords.value = 0;
      totalPages.value = 0;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<TransactionDetailModel> getCreditLoansDetails(int transactionId) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      return await _repository.getDetails(transactionId);
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
