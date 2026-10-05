import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../core/widgets/myfin_footer.dart';
import '../../transaction_rules/controllers/transaction_type_rule_controller.dart';
import '../../transaction_rules/models/transaction_type_rule.dart';

class TransactionTypeRuleFormPage extends StatefulWidget {
  const TransactionTypeRuleFormPage({super.key, this.transactionTypeRule});

  final TransactionTypeRule? transactionTypeRule;

  @override
  State<TransactionTypeRuleFormPage> createState() => _TransactionTypeRuleFormPageState();
}

class _TransactionTypeRuleFormPageState extends State<TransactionTypeRuleFormPage> {
  final _entrySideController = TextEditingController();
  final _mainHeadIdController = TextEditingController();
  final _sequenceNoController = TextEditingController(text: '1');
  final _isRequired = true.obs;
  final _isSaving = false.obs;

  bool get _isEditing => widget.transactionTypeRule != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final r = widget.transactionTypeRule!;
      _entrySideController.text = r.entrySide;
      _mainHeadIdController.text = r.mainHeadID.toString();
      _sequenceNoController.text = r.sequenceNo.toString();
      _isRequired.value = r.isRequired;
    }
  }

  @override
  void dispose() {
    _entrySideController.dispose();
    _mainHeadIdController.dispose();
    _sequenceNoController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final entrySide = _entrySideController.text.trim().toUpperCase();
    final mainHeadIdText = _mainHeadIdController.text.trim();
    final sequenceNoText = _sequenceNoController.text.trim();

    if (entrySide.isEmpty || mainHeadIdText.isEmpty || sequenceNoText.isEmpty) {
      Get.snackbar(
        'Validation',
        'Please fill all required fields.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    if (!['D', 'C'].contains(entrySide)) {
      Get.snackbar(
        'Validation',
        'Entry Side must be D or C.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    final mainHeadId = int.tryParse(mainHeadIdText);
    if (mainHeadId == null || mainHeadId <= 0) {
      Get.snackbar(
        'Validation',
        'Main Head ID must be a positive number.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    final sequenceNo = int.tryParse(sequenceNoText);
    if (sequenceNo == null || sequenceNo <= 0) {
      Get.snackbar(
        'Validation',
        'Sequence No must be a positive number.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    _isSaving.value = true;

    try {
      final controller = Get.find<TransactionTypeRuleController>();
      final payload = <String, dynamic>{
        'entrySide': entrySide,
        'mainHeadID': mainHeadId,
        'sequenceNo': sequenceNo,
        'isRequired': _isRequired.value,
      };

      if (_isEditing) {
        await controller.updateTransactionTypeRule(widget.transactionTypeRule!.transactionTypeRuleID, payload);
      } else {
        await controller.createTransactionTypeRule(payload);
      }

      if (mounted) {
        Get.snackbar(
          'Success',
          _isEditing
              ? 'Transaction type rule updated successfully.'
              : 'Transaction type rule created successfully.',
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
          backgroundColor: const Color(0xFFE04057),
          colorText: Colors.white,
        );
      }
    } finally {
      _isSaving.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = _isEditing ? 'Edit Transaction Type Rule' : 'Add Transaction Type Rule';

    return FormPageScaffold(
      title: title,
      subtitle: _isEditing
          ? 'Update the transaction type rule details below.'
          : 'Create a new transaction type rule.',
      isSaving: _isSaving.value,
      onSave: _submit,
      onCancel: () => Get.back(),
      saveLabel: _isEditing ? 'Save Changes' : 'Create',
      footer: const MyfinFooter(),
      children: [
        Text(
          'Rule Information',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF3D2C2C),
          ),
        ),
        const SizedBox(height: 12),
        FormDropdownField<String>(
          initialValue: _entrySideController.text.isEmpty ? null : _entrySideController.text,
          items: const [
            DropdownMenuItem(value: 'D', child: Text('Debit (D)')),
            DropdownMenuItem(value: 'C', child: Text('Credit (C)')),
          ],
          label: 'Entry Side',
          required: true,
          hint: 'Select entry side',
          onChanged: (value) {
            if (value != null) {
              _entrySideController.text = value;
            }
          },
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: _mainHeadIdController,
          label: 'Main Head ID',
          hint: 'e.g. 1000',
          required: true,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: _sequenceNoController,
          label: 'Sequence No',
          hint: 'e.g. 1',
          required: true,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        FormSwitchField(
          value: _isRequired.value,
          onChanged: (value) => _isRequired.value = value,
          label: 'Required',
        ),
      ],
    );
  }
}
