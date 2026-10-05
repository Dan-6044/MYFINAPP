import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../core/widgets/myfin_footer.dart';
import '../../transaction_types/controllers/transaction_type_controller.dart';
import '../../transaction_types/models/transaction_type.dart';

class TransactionTypeFormPage extends StatefulWidget {
  const TransactionTypeFormPage({super.key, this.transactionType});

  final TransactionType? transactionType;

  @override
  State<TransactionTypeFormPage> createState() => _TransactionTypeFormPageState();
}

class _TransactionTypeFormPageState extends State<TransactionTypeFormPage> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _isSaving = false.obs;

  bool get _isEditing => widget.transactionType != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.transactionType!;
      _codeController.text = t.transactionTypeCode.toString();
      _nameController.text = t.transactionTypeName;
      _descriptionController.text = t.description ?? '';
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final codeText = _codeController.text.trim();
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (codeText.isEmpty || name.isEmpty) {
      Get.snackbar(
        'Validation',
        'Please fill all required fields.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    final code = int.tryParse(codeText);
    if (code == null || code <= 0) {
      Get.snackbar(
        'Validation',
        'Transaction Type Code must be a positive number.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    _isSaving.value = true;

    try {
      final controller = Get.find<TransactionTypeController>();
      final payload = <String, dynamic>{
        'transactionTypeCode': code,
        'transactionTypeName': name,
        'description': description.isEmpty ? null : description,
      };

      if (_isEditing) {
        await controller.updateTransactionType(widget.transactionType!.transactionTypeID, payload);
      } else {
        await controller.createTransactionType(payload);
      }

      if (mounted) {
        Get.snackbar(
          'Success',
          _isEditing
              ? 'Transaction type updated successfully.'
              : 'Transaction type created successfully.',
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
    final title = _isEditing ? 'Edit Transaction Type' : 'Add Transaction Type';

    return FormPageScaffold(
      title: title,
      subtitle: _isEditing
          ? 'Update the transaction type details below.'
          : 'Create a new transaction type.',
      isSaving: _isSaving.value,
      onSave: _submit,
      onCancel: () => Get.back(),
      saveLabel: _isEditing ? 'Save Changes' : 'Create',
      footer: const MyfinFooter(),
      children: [
        Text(
          'Transaction Type Information',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF3D2C2C),
          ),
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: _codeController,
          label: 'Transaction Type Code',
          hint: 'e.g. 1001',
          required: true,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: _nameController,
          label: 'Transaction Type Name',
          hint: 'e.g. Payment',
          required: true,
          maxLength: 100,
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: _descriptionController,
          label: 'Description',
          hint: 'Optional description',
          required: false,
          maxLength: 500,
          maxLines: 2,
        ),
      ],
    );
  }
}
