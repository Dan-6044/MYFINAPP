import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../core/widgets/myfin_footer.dart';
import '../../main_heads/controllers/main_head_controller.dart';
import '../../main_heads/models/main_head.dart';

class MainHeadFormPage extends StatefulWidget {
  const MainHeadFormPage({super.key, this.mainHead});

  final MainHead? mainHead;

  @override
  State<MainHeadFormPage> createState() => _MainHeadFormPageState();
}

class _MainHeadFormPageState extends State<MainHeadFormPage> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _accountingTypeController = TextEditingController();
  final _normalBalanceController = TextEditingController();
  final _isSaving = false.obs;

  bool get _isEditing => widget.mainHead != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final mh = widget.mainHead!;
      _codeController.text = mh.mainHeadCode.toString();
      _nameController.text = mh.mainHeadName;
      _accountingTypeController.text = mh.accountingType;
      _normalBalanceController.text = mh.normalBalance;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _accountingTypeController.dispose();
    _normalBalanceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final codeText = _codeController.text.trim();
    final name = _nameController.text.trim();
    final accountingType = _accountingTypeController.text.trim().toUpperCase();
    final normalBalance = _normalBalanceController.text.trim().toUpperCase();

    if (codeText.isEmpty || name.isEmpty || accountingType.isEmpty || normalBalance.isEmpty) {
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
        'Main Head Code must be a positive number.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    if (!['ASSET', 'LIABILITY', 'INCOME', 'EXPENSE', 'EQUITY'].contains(accountingType)) {
      Get.snackbar(
        'Validation',
        'Accounting Type must be one of: ASSET, LIABILITY, INCOME, EXPENSE, EQUITY.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    if (normalBalance != 'D' && normalBalance != 'C') {
      Get.snackbar(
        'Validation',
        'Normal Balance must be D (Debit) or C (Credit).',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    _isSaving.value = true;

    try {
      final controller = Get.find<MainHeadController>();
      final payload = <String, dynamic>{
        'mainHeadCode': code,
        'mainHeadName': name,
        'accountingType': accountingType,
        'normalBalance': normalBalance,
      };

      if (_isEditing) {
        await controller.updateMainHead(widget.mainHead!.mainHeadID, payload);
      } else {
        await controller.createMainHead(payload);
      }

      if (mounted) {
        Get.snackbar(
          'Success',
          _isEditing
              ? 'Main Head updated successfully.'
              : 'Main Head created successfully.',
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
    final title = _isEditing ? 'Edit Main Head' : 'Add Main Head';

    return FormPageScaffold(
      title: title,
      subtitle: _isEditing
          ? 'Update the main head details below.'
          : 'Create a new main head for the chart of accounts.',
      isSaving: _isSaving.value,
      onSave: _submit,
      onCancel: () => Get.back(),
      saveLabel: _isEditing ? 'Save Changes' : 'Create',
      footer: const MyfinFooter(),
      children: [
        Text(
          'Main Head Information',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF3D2C2C),
          ),
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: _codeController,
          label: 'Main Head Code',
          hint: 'e.g. 1000',
          required: true,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: _nameController,
          label: 'Main Head Name',
          hint: 'e.g. Assets',
          required: true,
          maxLength: 100,
        ),
        const SizedBox(height: 12),
        FormDropdownField<String>(
          initialValue: _accountingTypeController.text.isEmpty ? null : _accountingTypeController.text,
          items: const [
            DropdownMenuItem(value: 'ASSET', child: Text('ASSET')),
            DropdownMenuItem(value: 'LIABILITY', child: Text('LIABILITY')),
            DropdownMenuItem(value: 'INCOME', child: Text('INCOME')),
            DropdownMenuItem(value: 'EXPENSE', child: Text('EXPENSE')),
            DropdownMenuItem(value: 'EQUITY', child: Text('EQUITY')),
          ],
          label: 'Accounting Type',
          required: true,
          onChanged: (value) {
            if (value != null) {
              _accountingTypeController.text = value;
            }
          },
        ),
        const SizedBox(height: 12),
        FormDropdownField<String>(
          initialValue: _normalBalanceController.text.isEmpty ? null : _normalBalanceController.text,
          items: const [
            DropdownMenuItem(value: 'D', child: Text('Debit (D)')),
            DropdownMenuItem(value: 'C', child: Text('Credit (C)')),
          ],
          label: 'Normal Balance',
          required: true,
          onChanged: (value) {
            if (value != null) {
              _normalBalanceController.text = value;
            }
          },
        ),
      ],
    );
  }
}
