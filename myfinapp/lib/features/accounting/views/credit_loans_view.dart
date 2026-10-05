import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/form_fields.dart';
import '../../financial_periods/controllers/financial_period_controller.dart';
import '../controllers/credit_loans_controller.dart';
import '../models/transaction_model.dart';
import 'transaction_detail_page.dart';

class CreditLoansView extends GetView<CreditLoansController> {
  const CreditLoansView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FilterBar(
          onApply: (filters) async {
            await controller.loadCreditLoans(
              financialPeriodId: filters.financialPeriodId,
              status: filters.status,
              startDate: filters.startDate,
              endDate: filters.endDate,
            );
          },
          onClear: () async {
            await controller.loadCreditLoans();
          },
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.creditLoans.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final error = controller.errorMessage.value;
            if (error != null && error.isNotEmpty && controller.creditLoans.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 40, color: Color(0xFFD6C8C0)),
                      const SizedBox(height: 12),
                      Text(
                        'Unable to load credit/loans',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF3D2C2C),
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Please check your connection and try again.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF8C7B7B),
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => controller.loadCreditLoans(),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final creditLoans = controller.creditLoans;
            if (creditLoans.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.credit_card_rounded, size: 40, color: Color(0xFFD6C8C0)),
                      const SizedBox(height: 12),
                      Text(
                        'No Credit/Loans',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF3D2C2C),
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'No credit/loan transactions have been created yet.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF8C7B7B),
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final grouped = _groupByDate(creditLoans);

            return RefreshIndicator(
              onRefresh: () => controller.loadCreditLoans(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: grouped.keys.length,
                itemBuilder: (context, index) {
                  final date = grouped.keys.elementAt(index);
                  final items = grouped[date]!;
                  return _DateGroup(
                    date: date,
                    creditLoans: items,
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Map<DateTime, List<TransactionListItemModel>> _groupByDate(List<TransactionListItemModel> creditLoans) {
    final sorted = List<TransactionListItemModel>.from(creditLoans);
    sorted.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    final grouped = <DateTime, List<TransactionListItemModel>>{};
    for (final t in sorted) {
      final date = DateTime(t.transactionDate.year, t.transactionDate.month, t.transactionDate.day);
      grouped.putIfAbsent(date, () => []).add(t);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final result = <DateTime, List<TransactionListItemModel>>{};
    for (final key in sortedKeys) {
      result[key] = grouped[key]!;
    }
    return result;
  }
}

class _FilterBar extends StatefulWidget {
  final Future<void> Function(CreditLoansFilters filters) onApply;
  final Future<void> Function() onClear;

  const _FilterBar({
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<_FilterBar> {
  final Rxn<int> _selectedFinancialPeriodId = Rxn<int>();
  final Rx<DateTime?> _startDate = Rxn<DateTime?>();
  final Rx<DateTime?> _endDate = Rxn<DateTime?>();
  final RxBool _isApplying = false.obs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF7EF),
        border: Border(bottom: BorderSide(color: Color(0xFFF0E6DC), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Filters',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3D2C2C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  final periods = Get.find<FinancialPeriodController>().periods;
                  return FormDropdownField<int>(
                    initialValue: _selectedFinancialPeriodId.value,
                    items: periods
                        .map((p) {
                          final period = p as dynamic;
                          return DropdownMenuItem<int>(
                            value: period.financialPeriodID,
                            child: Text('${period.periodCode} - ${period.periodName}'),
                          );
                        })
                        .toList(),
                    label: 'Financial Period',
                    required: false,
                    hint: 'All',
                    onChanged: (value) => _selectedFinancialPeriodId.value = value,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  return InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate.value ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        _startDate.value = picked;
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5EBE0),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFFF4793A)),
                          const SizedBox(width: 6),
                          Text(
                            _startDate.value == null
                                ? 'From Date'
                                : DateFormat('dd/MM/yyyy').format(_startDate.value!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _startDate.value == null ? const Color(0xFFF4793A) : const Color(0xFF222222),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() {
                  return InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate.value ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        _endDate.value = picked;
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5EBE0),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFFF4793A)),
                          const SizedBox(width: 6),
                          Text(
                            _endDate.value == null
                                ? 'To Date'
                                : DateFormat('dd/MM/yyyy').format(_endDate.value!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _endDate.value == null ? const Color(0xFFF4793A) : const Color(0xFF222222),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  return ElevatedButton(
                    onPressed: _isApplying.value
                        ? null
                        : () async {
                            _isApplying.value = true;
                            try {
                              await widget.onApply(CreditLoansFilters(
                                financialPeriodId: _selectedFinancialPeriodId.value,
                                startDate: _startDate.value,
                                endDate: _endDate.value,
                                status: null,
                              ));
                            } finally {
                              _isApplying.value = false;
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF4793A),
                      foregroundColor: Colors.white,
                    ),
                    child: _isApplying.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Apply Filters'),
                  );
                }),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () async {
                  _selectedFinancialPeriodId.value = null;
                  _startDate.value = null;
                  _endDate.value = null;
                  await widget.onClear();
                },
                child: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CreditLoansFilters {
  final int? financialPeriodId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;

  const CreditLoansFilters({
    this.financialPeriodId,
    this.startDate,
    this.endDate,
    this.status,
  });
}

class _DateGroup extends StatelessWidget {
  const _DateGroup({
    required this.date,
    required this.creditLoans,
  });

  final DateTime date;
  final List<TransactionListItemModel> creditLoans;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('d MMMM yyyy').format(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Text(
            formattedDate,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF3D2C2C),
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFF0E6DC), width: 1)),
          ),
          child: Column(
            children: creditLoans.map((creditLoan) => _CreditLoanListItem(creditLoan: creditLoan)).toList(),
          ),
        ),
      ],
    );
  }
}

class _CreditLoanListItem extends StatelessWidget {
  const _CreditLoanListItem({required this.creditLoan});

  final TransactionListItemModel creditLoan;

  Color _statusBackground(String status) {
    switch (status.toUpperCase()) {
      case 'POSTED':
        return const Color(0xFFE8F5E9);
      case 'VOID':
        return const Color(0xFFFFEBEE);
      case 'VALIDATED':
        return const Color(0xFFE3F2FD);
      case 'DRAFT':
      default:
        return const Color(0xFFFFF7EF);
    }
  }

  Color _statusBorder(String status) {
    switch (status.toUpperCase()) {
      case 'POSTED':
        return const Color(0xFF4CAF50);
      case 'VOID':
        return const Color(0xFFE04057);
      case 'VALIDATED':
        return const Color(0xFF2196F3);
      case 'DRAFT':
      default:
        return const Color(0xFFF4793A);
    }
  }

  Color _statusText(String status) {
    switch (status.toUpperCase()) {
      case 'POSTED':
        return const Color(0xFF2E7D32);
      case 'VOID':
        return const Color(0xFFC62828);
      case 'VALIDATED':
        return const Color(0xFF1565C0);
      case 'DRAFT':
      default:
        return const Color(0xFFF4793A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trailing = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _statusBackground(creditLoan.status),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _statusBorder(creditLoan.status),
              width: 1,
            ),
          ),
          child: Text(
            creditLoan.status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _statusText(creditLoan.status),
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Theme(
          data: Theme.of(context).copyWith(
            popupMenuTheme: PopupMenuThemeData(
              color: const Color(0xFFF4793A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 18, color: Color(0xFFF4793A)),
            onSelected: (value) async {
              if (value == 'view') {
                final result = await Get.to(
                  () => TransactionDetailPage(transactionId: creditLoan.transactionId),
                );
                if (result == true && context.mounted) {
                  final creditLoansController = Get.find<CreditLoansController>();
                  await creditLoansController.loadCreditLoans();
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 12),
                    Text('View', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return InkWell(
      onTap: () async {
        final result = await Get.to(
          () => TransactionDetailPage(transactionId: creditLoan.transactionId),
        );
        if (result == true && context.mounted) {
          final creditLoansController = Get.find<CreditLoansController>();
          await creditLoansController.loadCreditLoans();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF0E6DC), width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${creditLoan.transactionTypeCode} - ${creditLoan.transactionTypeName}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3D2C2C),
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    creditLoan.description ?? '-',
                    style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF8C7B7B),
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${creditLoan.transactionNumber} • ${DateFormat('dd MMM yyyy').format(creditLoan.transactionDate)} • Debit: ${creditLoan.totalDebit.toStringAsFixed(2)} Credit: ${creditLoan.totalCredit.toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF8C7B7B),
                        ),
                  ),
                ],
              ),
            ),
            ...trailing.children,
          ],
        ),
      ),
    );
  }
}
