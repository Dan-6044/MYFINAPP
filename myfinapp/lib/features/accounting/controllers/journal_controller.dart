import 'package:get/get.dart';
import '../repositories/journal_repository.dart';
import '../models/transaction_model.dart';

class JournalController extends GetxController {
  final JournalRepository _repository = JournalRepository();

  RxList<JournalListItemModel> journals = <JournalListItemModel>[].obs;
  RxBool isLoading = false.obs;
  Rx<String?> errorMessage = Rxn<String>();
  RxInt totalRecords = 0.obs;
  RxInt currentPage = 1.obs;
  RxInt totalPages = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadJournals();
  }

  Future<void> loadJournals({
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
      journals.assignAll(list);
      totalRecords.value = 0;
      totalPages.value = 0;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<JournalDetailModel> getJournalDetails(int journalId) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      return await _repository.getDetails(journalId);
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
