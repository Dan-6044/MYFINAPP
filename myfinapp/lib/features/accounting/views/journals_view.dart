import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/form_fields.dart';
import '../../financial_periods/controllers/financial_period_controller.dart';
import '../controllers/journal_controller.dart';
import '../models/transaction_model.dart';
import 'journal_detail_page.dart';

class JournalsView extends GetView<JournalController> {
  const JournalsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FilterBar(
          onApply: (filters) async {
            await controller.loadJournals(
              financialPeriodId: filters.financialPeriodId,
              startDate: filters.startDate,
              endDate: filters.endDate,
            );
          },
          onClear: () async {
            await controller.loadJournals();
          },
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.journals.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final error = controller.errorMessage.value;
            if (error != null && error.isNotEmpty && controller.journals.isEmpty) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 40, color: Color(0xFFD6C8C0)),
                      const SizedBox(height: 12),
                      Text(
                        'Unable to load journals',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF3D2C2C),
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        error,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF8C7B7B),
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                            onPressed: () => controller.loadJournals(),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Retry'),
                          ),
                    ],
                  ),
                ),
              );
            }

            final journals = controller.journals;
            if (journals.isEmpty) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.book_rounded, size: 40, color: Color(0xFFD6C8C0)),
                      const SizedBox(height: 12),
                      Text(
                        'No Journals',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF3D2C2C),
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'No journals have been posted yet.',
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

            final grouped = _groupByDate(journals);

            return RefreshIndicator(
              onRefresh: () => controller.loadJournals(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: grouped.keys.length,
                itemBuilder: (context, index) {
                  final date = grouped.keys.elementAt(index);
                  final items = grouped[date]!;
                  return _DateGroup(
                    date: date,
                    journals: items,
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Map<DateTime, List<JournalListItemModel>> _groupByDate(List<JournalListItemModel> journals) {
    final sorted = List<JournalListItemModel>.from(journals);
    sorted.sort((a, b) => b.journalDate.compareTo(a.journalDate));

    final grouped = <DateTime, List<JournalListItemModel>>{};
    for (final j in sorted) {
      final date = DateTime(j.journalDate.year, j.journalDate.month, j.journalDate.day);
      grouped.putIfAbsent(date, () => []).add(j);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final result = <DateTime, List<JournalListItemModel>>{};
    for (final key in sortedKeys) {
      result[key] = grouped[key]!;
    }
    return result;
  }
}

class _FilterBar extends StatefulWidget {
  final Future<void> Function(JournalFilters filters) onApply;
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
                              await widget.onApply(JournalFilters(
                                financialPeriodId: _selectedFinancialPeriodId.value,
                                startDate: _startDate.value,
                                endDate: _endDate.value,
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

class JournalFilters {
  final int? financialPeriodId;
  final DateTime? startDate;
  final DateTime? endDate;

  const JournalFilters({
    this.financialPeriodId,
    this.startDate,
    this.endDate,
  });
}

class _DateGroup extends StatelessWidget {
  const _DateGroup({
    required this.date,
    required this.journals,
  });

  final DateTime date;
  final List<JournalListItemModel> journals;

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
            children: journals.map((journal) => _JournalTile(journal: journal)).toList(),
          ),
        ),
      ],
    );
  }
}

class _JournalTile extends StatelessWidget {
  const _JournalTile({required this.journal});

  final JournalListItemModel journal;

  Color _statusBackground(String status) {
    switch (status.toUpperCase()) {
      case 'POSTED':
        return const Color(0xFFE8F5E9);
      case 'VOID':
        return const Color(0xFFFFEBEE);
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
      default:
        return const Color(0xFFF4793A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () async {
        final result = await Get.to(
          () => JournalDetailPage(journalId: journal.journalId),
        );
        if (result == true && context.mounted) {
          final journalController = Get.find<JournalController>();
          await journalController.loadJournals();
        }
      },
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        backgroundColor: const Color(0xFFFFF7EF),
        collapsedBackgroundColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: Color(0xFFF0E6DC), width: 1)),
        collapsedShape: const Border(bottom: BorderSide(color: Color(0xFFF0E6DC), width: 1)),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    journal.journalNumber,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3D2C2C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    journal.transactionNumber,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8C7B7B),
                    ),
                  ),
                  if (journal.lines.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Debit: ${journal.totalDebit.toStringAsFixed(2)}  |  Credit: ${journal.totalCredit.toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8C7B7B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusBackground(journal.status),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _statusBorder(journal.status), width: 1),
              ),
              child: Text(
                journal.status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _statusText(journal.status),
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
        children: [
          if (journal.lines.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No journal lines found.',
                style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF8C7B7B)),
              ),
            )
          else
            ...journal.lines.map((line) {
              final isDebit = line.debitAmount > 0;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                            '${line.coaCode} - ${line.coaName}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF3D2C2C),
                            ),
                          ),
                          if (line.description != null && line.description!.isNotEmpty)
                            Text(
                              line.description!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF8C7B7B),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isDebit ? 'Dr' : 'Cr',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8C7B7B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      (isDebit ? line.debitAmount : line.creditAmount).toStringAsFixed(2),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3D2C2C),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
