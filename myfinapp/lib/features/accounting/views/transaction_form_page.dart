import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../core/widgets/myfin_footer.dart';
import '../../../modules/auth/controllers/auth_controller.dart';
import '../../accounts/controllers/account_controller.dart';
import '../../accounts/models/account.dart';
import '../../transaction_types/controllers/transaction_type_controller.dart';
import '../../transaction_types/models/transaction_type.dart';
import '../../transaction_rules/models/transaction_component.dart';
import '../../transaction_rules/repositories/transaction_component_repository.dart';
import '../../transaction_rules/repositories/transaction_component_rule_repository.dart';
import '../../financial_periods/controllers/financial_period_controller.dart';
import '../controllers/transaction_controller.dart';
import '../models/transaction_model.dart';

class TransactionFormPage extends StatefulWidget {
  const TransactionFormPage({
    super.key,
    this.prefill,
    this.title,
    this.allowedTransactionTypeNames,
  });

  final CreateTransactionRequestModel? prefill;
  final String? title;
  final List<String>? allowedTransactionTypeNames;

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final _transactionDateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _referenceNumberController = TextEditingController();
  final RxList<TransactionLineRequestModel> _lines = <TransactionLineRequestModel>[].obs;
  final RxBool _isSaving = false.obs;
  final RxInt _selectedTransactionTypeId = 0.obs;
  final RxInt _selectedFinancialPeriodId = 0.obs;
  final RxBool _isLoadingTypes = false.obs;
  final RxBool _isLoadingPeriods = false.obs;
  final RxBool _isLoadingAccounts = false.obs;
  final RxList<Account> _accounts = <Account>[].obs;
  final RxString _transactionDate = ''.obs;
  final RxString _description = ''.obs;
  final RxString _referenceNumber = ''.obs;
  final RxList<TransactionComponent> _components = <TransactionComponent>[].obs;
  final RxBool _isLoadingComponents = false.obs;

  @override
  void initState() {
    super.initState();
    if (widget.prefill != null) {
      final prefill = widget.prefill!;
      _selectedTransactionTypeId.value = prefill.transactionTypeId;
      _selectedFinancialPeriodId.value = prefill.financialPeriodId;
      _transactionDateController.text = _formatDate(prefill.transactionDate);
      _descriptionController.text = prefill.description;
      _referenceNumberController.text = prefill.referenceNumber ?? '';
      _transactionDate.value = _formatDate(prefill.transactionDate);
      _description.value = prefill.description;
      _referenceNumber.value = prefill.referenceNumber ?? '';
      _lines.assignAll(prefill.lines);
    } else {
      _transactionDateController.text = _formatDate(DateTime.now());
      _transactionDate.value = _formatDate(DateTime.now());
    }
    _loadTransactionTypes();
    _loadFinancialPeriods();
    _loadAccounts();
  }

  @override
  void dispose() {
    _transactionDateController.dispose();
    _descriptionController.dispose();
    _referenceNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactionTypes() async {
    _isLoadingTypes.value = true;
    try {
      final transactionTypeController = Get.find<TransactionTypeController>();
      await transactionTypeController.loadTransactionTypes();
    } catch (e) {
      // ignore
    } finally {
      _isLoadingTypes.value = false;
    }
  }

  Future<void> _loadFinancialPeriods() async {
    _isLoadingPeriods.value = true;
    try {
      final financialPeriodController = Get.find<FinancialPeriodController>();
      await financialPeriodController.loadPeriods();
    } catch (e) {
      // ignore
    } finally {
      _isLoadingPeriods.value = false;
    }
  }

  Future<void> _loadAccounts() async {
    _isLoadingAccounts.value = true;
    try {
      final accountController = Get.find<AccountController>();
      await accountController.loadAccounts();
      _accounts.assignAll(
        accountController.accounts
            .where((a) => (a as dynamic).isActive == true && (a as dynamic).allowDirectPosting == true)
            .map((a) => a as Account)
            .toList(),
      );
    } catch (e) {
      // ignore
    } finally {
      _isLoadingAccounts.value = false;
    }
  }

  Future<void> _loadComponents(int transactionTypeId) async {
    _isLoadingComponents.value = true;
    try {
      final repo = TransactionComponentRepository();
      final results = await repo.getList(transactionTypeId: transactionTypeId, isActive: true);
      _components.assignAll(results);
    } catch (e) {
      _components.clear();
    } finally {
      _isLoadingComponents.value = false;
    }
  }

  List<TransactionType> get _activeTransactionTypes {
    final controller = Get.find<TransactionTypeController>();
    final seen = <int>{};
    return controller.transactionTypes.where((t) {
      if (!t.isActive) return false;
      if (!seen.add(t.transactionTypeID)) return false;
      return true;
    }).toList();
  }

  List<dynamic> get _openFinancialPeriods {
    final controller = Get.find<FinancialPeriodController>();
    final seen = <int>{};
    return controller.periods.where((p) {
      final status = (p as dynamic).status as String?;
      if (status != 'OPEN') return false;
      final id = (p as dynamic).financialPeriodID as int;
      if (!seen.add(id)) return false;
      return true;
    }).toList();
  }

  double get _totalDebit =>
      _lines.fold<double>(0, (sum, line) => line.entrySide == 'D' ? sum + line.amount : sum);

  double get _totalCredit =>
      _lines.fold<double>(0, (sum, line) => line.entrySide == 'C' ? sum + line.amount : sum);

  double get _difference => _totalDebit - _totalCredit;

  bool get _isBalanced => _lines.isNotEmpty && _difference.abs() < 0.01;

  bool get _canSave {
    if (_selectedTransactionTypeId.value <= 0) return false;
    if (_selectedFinancialPeriodId.value <= 0) return false;
    if (_transactionDate.value.trim().isEmpty) return false;
    if (_description.value.trim().isEmpty) return false;
    if (_lines.isEmpty) return false;
    for (final line in _lines) {
      if (line.componentCode.trim().isEmpty) return false;
      if (line.coaId <= 0) return false;
      if (line.amount <= 0) return false;
      if (line.entrySide != 'D' && line.entrySide != 'C') return false;
    }
    return _isBalanced;
  }

  Future<void> _submit() async {
    final transactionTypeId = _selectedTransactionTypeId.value;
    final financialPeriodId = _selectedFinancialPeriodId.value;
    final transactionDateText = _transactionDateController.text.trim();
    final description = _descriptionController.text.trim();
    final referenceNumber = _referenceNumberController.text.trim();

    if (transactionTypeId <= 0) {
      Get.snackbar(
        'Validation',
        'Please select a transaction type.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    if (financialPeriodId <= 0) {
      Get.snackbar(
        'Validation',
        'Please select a financial period.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    DateTime? transactionDate;
    try {
      transactionDate = DateTime.parse(transactionDateText);
    } catch (e) {
      Get.snackbar(
        'Validation',
        'Please enter a valid transaction date.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    final selectedPeriod = _openFinancialPeriods.firstWhereOrNull(
      (p) => (p as dynamic).financialPeriodID == financialPeriodId,
    );

    if (selectedPeriod != null) {
      final period = selectedPeriod as dynamic;
      final startDate = DateTime.parse(period.startDate as String);
      final endDate = DateTime.parse(period.endDate as String);
      final txnDate = DateTime(transactionDate.year, transactionDate.month, transactionDate.day);
      if (txnDate.isBefore(startDate) || txnDate.isAfter(endDate)) {
        Get.snackbar(
          'Validation',
          'Transaction date must be within the selected financial period.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE04057),
          colorText: Colors.white,
        );
        return;
      }
    }

    if (description.isEmpty) {
      Get.snackbar(
        'Validation',
        'Please enter a description.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    if (_lines.isEmpty) {
      Get.snackbar(
        'Validation',
        'Please add at least one transaction line.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    for (var i = 0; i < _lines.length; i++) {
      final line = _lines[i];
      if (line.coaId <= 0) {
        Get.snackbar(
          'Validation',
          'Please select an account for line ${i + 1}.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE04057),
          colorText: Colors.white,
        );
        return;
      }
      if (line.amount <= 0) {
        Get.snackbar(
          'Validation',
          'Amount must be greater than zero for line ${i + 1}.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE04057),
          colorText: Colors.white,
        );
        return;
      }
      if (line.entrySide != 'D' && line.entrySide != 'C') {
        Get.snackbar(
          'Validation',
          'Please select a valid entry side for line ${i + 1}.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE04057),
          colorText: Colors.white,
        );
        return;
      }
    }

    final authController = Get.find<AuthController>();
    final createdByUserId = authController.userID.value;

    final request = CreateTransactionRequestModel(
      transactionTypeId: transactionTypeId,
      financialPeriodId: financialPeriodId,
      transactionDate: transactionDate,
      description: description,
      referenceNumber: referenceNumber.isEmpty ? null : referenceNumber,
      createdByUserId: createdByUserId,
      lines: _lines.map((l) {
        return TransactionLineRequestModel(
          componentCode: l.componentCode,
          entrySide: l.entrySide,
          coaId: l.coaId,
          amount: l.amount,
          description: l.description,
        );
      }).toList(),
    );

    _isSaving.value = true;

    try {
      final transactionController = Get.find<TransactionController>();
      await transactionController.createTransaction(request);

      if (mounted) {
        Get.snackbar(
          'Success',
          'Transaction created successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
        );
        Get.back(result: true);
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          e.toString().replaceFirst('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white,
        );
      }
    } finally {
      _isSaving.value = false;
    }
  }

  void _addLine() {
    _lines.add(TransactionLineRequestModel(
      componentCode: '',
      entrySide: 'D',
      coaId: 0,
      amount: 0,
      description: '',
    ));
  }

  void _removeLine(int index) {
    _lines.removeAt(index);
  }

  void _updateLine(int index, TransactionLineRequestModel line) {
    _lines[index] = line;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final canSave = _canSave;
      final isSaving = _isSaving.value;

      return FormPageScaffold(
        title: widget.title ?? 'Add Transaction',
        subtitle: widget.title != null ? 'Review and save the duplicated transaction.' : 'Create a new financial transaction.',
        isSaving: isSaving,
        onSave: canSave ? _submit : null,
        onCancel: () => Get.back(),
        saveLabel: 'Create',
        cancelTextStyle: const TextStyle(color: Color(0xFFF4793A)),
        footer: const MyfinFooter(),
        children: [
        Text(
          'Transaction Information',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF3D2C2C),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final allowedNames = widget.allowedTransactionTypeNames;
          var transactionTypes = _activeTransactionTypes;
          if (allowedNames != null && allowedNames.isNotEmpty) {
            transactionTypes = transactionTypes
                .where((t) => allowedNames.any((name) => name.toLowerCase() == t.transactionTypeName.toLowerCase()))
                .toList();
          }
          return FormDropdownField<int>(
            initialValue: _selectedTransactionTypeId.value > 0 ? _selectedTransactionTypeId.value : null,
            items: transactionTypes
                .map((t) => DropdownMenuItem<int>(
                      value: t.transactionTypeID,
                      child: Text('${t.transactionTypeCode} - ${t.transactionTypeName}'),
                    ))
                .toList(),
            label: 'Transaction Type',
            required: true,
            hint: _isLoadingTypes.value ? 'Loading...' : 'Select transaction type',
            onChanged: (value) {
              if (value != null) {
                _selectedTransactionTypeId.value = value;
                _components.clear();
                _lines.value = _lines.map((line) {
                  return line.copyWith(componentCode: '');
                }).toList();
                _loadComponents(value);
              }
            },
          );
        }),
        const SizedBox(height: 12),
        Obx(() {
          final periods = _openFinancialPeriods;
          return FormDropdownField<int>(
            initialValue: _selectedFinancialPeriodId.value > 0 ? _selectedFinancialPeriodId.value : null,
            items: periods
                .map((p) {
                  final period = p as dynamic;
                  return DropdownMenuItem<int>(
                      value: period.financialPeriodID as int,
                      child: Text('${period.periodCode} - ${period.periodName}'));
                })
                .toList(),
            label: 'Financial Period',
            required: true,
            hint: _isLoadingPeriods.value ? 'Loading...' : 'Select financial period',
            onChanged: (value) {
              if (value != null) {
                _selectedFinancialPeriodId.value = value;
              }
            },
          );
        }),
        const SizedBox(height: 12),
        FormDateField(
          controller: _transactionDateController,
          label: 'Transaction Date',
          required: true,
          onChanged: (value) => _transactionDate.value = value,
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: _descriptionController,
          label: 'Description',
          hint: 'Enter transaction description',
          required: true,
          maxLines: 3,
          onChanged: (value) => _description.value = value ?? '',
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: _referenceNumberController,
          label: 'Reference Number',
          hint: 'Optional reference number',
          required: false,
          onChanged: (value) => _referenceNumber.value = value ?? '',
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              'Transaction Lines',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF3D2C2C),
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addLine,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Line'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (_lines.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Text(
                'No transaction lines added yet.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF8C7B7B),
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          return Column(
            children: [
              ..._lines.asMap().entries.map((entry) {
                final index = entry.key;
                final line = entry.value;
              return _TransactionLineForm(
                line: line,
                index: index,
                accounts: _accounts,
                components: _components,
                onUpdate: (updated) => _updateLine(index, updated),
                onRemove: () => _removeLine(index),
                onComponentChanged: (componentId) {
                  // Component changed for this line.
                },
              );
              }),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7EF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFF0E6DC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Total Debit',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF3D2C2C),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Total Credit',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF3D2C2C),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Difference',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF3D2C2C),
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatCurrency(_totalDebit),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF3D2C2C),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _formatCurrency(_totalCredit),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF3D2C2C),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _formatCurrency(_difference.abs()),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _difference == 0
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFE04057),
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isBalanced
                          ? 'Transaction is balanced.'
                          : 'Transaction is not balanced.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _isBalanced ? const Color(0xFF2E7D32) : const Color(0xFFE04057),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
    });
  }

  String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(2);
    final parts = formatted.split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];
    final buffer = StringBuffer();
    final length = integerPart.length;
    for (int i = 0; i < length; i++) {
      buffer.write(integerPart[i]);
      final remaining = length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(',');
      }
    }
    return 'KSh ${buffer.toString()}.$decimalPart';
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = _monthShort(dateTime.month);
    final year = dateTime.year;
    return '$day $month $year';
  }

  String _monthShort(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

class _TransactionLineForm extends StatefulWidget {
  const _TransactionLineForm({
    required this.line,
    required this.index,
    required this.accounts,
    required this.components,
    required this.onUpdate,
    required this.onRemove,
    required this.onComponentChanged,
  });

  final TransactionLineRequestModel line;
  final int index;
  final List<Account> accounts;
  final List<TransactionComponent> components;
  final ValueChanged<TransactionLineRequestModel> onUpdate;
  final VoidCallback onRemove;
  final ValueChanged<int?> onComponentChanged;

  @override
  State<_TransactionLineForm> createState() => _TransactionLineFormState();
}

class _TransactionLineFormState extends State<_TransactionLineForm> {
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late RxString _entrySide;
  late Rx<TransactionComponent?> _selectedComponent;
  List<TransactionComponentRule> _componentRules = <TransactionComponentRule>[];
  bool _isLoadingRules = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.line.amount.toString());
    _descriptionController = TextEditingController(text: widget.line.description ?? '');
    _entrySide = widget.line.entrySide.obs;
    _selectedComponent = widget.line.componentCode.isEmpty
        ? Rxn<TransactionComponent>()
        : Rxn<TransactionComponent?>(widget.components.firstWhereOrNull(
              (c) => c.componentCode == widget.line.componentCode,
            ));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadRules(int? componentId) async {
    if (componentId == null) {
      _componentRules = <TransactionComponentRule>[];
      return;
    }
    _isLoadingRules = true;
    try {
      final repo = TransactionComponentRuleRepository();
      final rules = await repo.getList(transactionComponentId: componentId);
      _componentRules = rules;
    } catch (e) {
      _componentRules = <TransactionComponentRule>[];
    } finally {
      _isLoadingRules = false;
    }
  }

  TransactionComponentRule? _matchRule(String entrySide) {
    final rules = _componentRules;
    if (rules.isEmpty) return null;
    return rules.firstWhereOrNull(
      (r) => r.entrySide.toUpperCase() == entrySide.toUpperCase(),
    );
  }

  List<Account> _getFilteredAccounts() {
    if (widget.accounts.isEmpty) return widget.accounts;
    final rules = _componentRules;
    if (rules.isEmpty) return widget.accounts;

    final entrySide = _entrySide.value.trim().toUpperCase();
    final sideRules = rules.where((r) => r.entrySide.toUpperCase() == entrySide).toList();

    final matchedCoaIds = <int>{};
    final matchedMainHeadIds = <int>{};
    final matchedSubheadIds = <int>{};

    for (final rule in sideRules) {
      if (rule.coaID != null && rule.coaID! > 0) {
        matchedCoaIds.add(rule.coaID!);
      }
      if (rule.mainHeadID > 0) {
        matchedMainHeadIds.add(rule.mainHeadID);
      }
      if (rule.subheadID != null && rule.subheadID! > 0) {
        matchedSubheadIds.add(rule.subheadID!);
      }
    }

    if (matchedCoaIds.isEmpty && matchedMainHeadIds.isEmpty && matchedSubheadIds.isEmpty) {
      return widget.accounts;
    }

    return widget.accounts.where((a) {
      final coaMatch = matchedCoaIds.isEmpty || matchedCoaIds.contains(a.coaID);
      final mainHeadMatch = matchedMainHeadIds.isEmpty || matchedMainHeadIds.contains(a.mainHead.mainHeadID);
      final subheadMatch = matchedSubheadIds.isEmpty || matchedSubheadIds.contains(a.subhead.subheadID);
      return coaMatch && mainHeadMatch && subheadMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Line ${widget.index + 1}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3D2C2C),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: widget.onRemove,
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFE04057)),
                tooltip: 'Remove line',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final components = widget.components;
            if (components.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Text(
                  'Select a transaction type to load available components.',
                  style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF8C7B7B)),
                ),
              );
            }

            final selectedComponent = _selectedComponent.value;
            final uniqueComponents = components.toSet().toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormDropdownField<TransactionComponent>(
                  initialValue: selectedComponent,
                  items: uniqueComponents
                      .map((c) => DropdownMenuItem<TransactionComponent>(
                            value: c,
                            child: Text('${c.componentCode} - ${c.componentName}'),
                          ))
                      .toList(),
                  label: 'Component',
                  required: true,
                  hint: 'Select component',
                  displayText: (component) {
                    if (component == null) return null;
                    return '${component.componentCode} - ${component.componentName}';
                  },
                  onChanged: (value) async {
                    if (value == null) return;
                    _selectedComponent.value = value;
                    widget.onComponentChanged(value.transactionComponentID);
                    await _loadRules(value.transactionComponentID);
                    final matchedRule = _matchRule(_entrySide.value);
                    if (matchedRule != null && matchedRule.coaID != null && matchedRule.coaID! > 0) {
                      widget.onUpdate(widget.line.copyWith(
                        componentCode: value.componentCode,
                        coaId: matchedRule.coaID!,
                      ));
                    } else {
                      widget.onUpdate(widget.line.copyWith(
                        componentCode: value.componentCode,
                      ));
                    }
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
                if (_isLoadingRules)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF4793A)),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(height: 12),
          Obx(() {
            final filteredAccounts = _getFilteredAccounts();
            final selectedAccount = filteredAccounts.firstWhereOrNull(
              (a) => a.coaID == widget.line.coaId,
            );

            return FormDropdownField<Account>(
              initialValue: selectedAccount,
              items: filteredAccounts
                  .map((a) => DropdownMenuItem<Account>(
                        value: a,
                        child: Text('${a.coaCode} - ${a.coaName}'),
                      ))
                  .toList(),
              label: 'Account',
              required: true,
              hint: _selectedComponent.value == null
                  ? 'Select a component first'
                  : 'Select account',
              displayText: (account) {
                if (account == null) return null;
                return '${account.coaCode} - ${account.coaName}';
              },
              onChanged: (value) {
                if (value != null) {
                  widget.onUpdate(widget.line.copyWith(
                    coaId: value.coaID,
                  ));
                }
              },
            );
          }),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  return FormDropdownField<String>(
                    initialValue: _entrySide.value,
                    items: const [
                      DropdownMenuItem(value: 'D', child: Text('Debit')),
                      DropdownMenuItem(value: 'C', child: Text('Credit')),
                    ],
                    label: 'Entry Side',
                    required: true,
                    hint: 'Select side',
                    onChanged: (value) {
                      if (value != null) {
                        _entrySide.value = value;
                        widget.onUpdate(widget.line.copyWith(entrySide: value));
                        final matchedRule = _matchRule(value);
                        if (matchedRule != null && matchedRule.coaID != null && matchedRule.coaID! > 0) {
                          widget.onUpdate(widget.line.copyWith(coaId: matchedRule.coaID!));
                        }
                      }
                    },
                  );
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FormTextField(
                  controller: _amountController,
                  label: 'Amount',
                  hint: '0.00',
                  required: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    if (value != null) {
                      final parsed = double.tryParse(value);
                      if (parsed != null) {
                        widget.onUpdate(widget.line.copyWith(amount: parsed));
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FormTextField(
            controller: _descriptionController,
            label: 'Line Description',
            hint: 'Optional',
            required: false,
            onChanged: (value) {
              if (value != null) {
                widget.onUpdate(widget.line.copyWith(description: value.isEmpty ? null : value));
              }
            },
          ),
        ],
      ),
    );
  }
}
