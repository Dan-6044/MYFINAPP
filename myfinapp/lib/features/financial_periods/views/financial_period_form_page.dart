import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../core/widgets/myfin_footer.dart';
import '../../../modules/auth/controllers/auth_controller.dart';
import '../../financial_periods/controllers/financial_period_controller.dart';
import '../../financial_periods/models/financial_period.dart';

class FinancialPeriodFormPage extends StatefulWidget {
  const FinancialPeriodFormPage({super.key, this.period});

  final FinancialPeriod? period;

  @override
  State<FinancialPeriodFormPage> createState() => _FinancialPeriodFormPageState();
}

class _FinancialPeriodFormPageState extends State<FinancialPeriodFormPage> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final _isSaving = false.obs;

  bool get _isEditing => widget.period != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final p = widget.period!;
      _codeController.text = p.periodCode;
      _nameController.text = p.periodName;
      _startController.text = p.startDate;
      _endController.text = p.endDate;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  DateTime? _tryParse(String value) {
    try {
      return DateTime.parse(value);
    } on FormatException {
      return null;
    }
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    final name = _nameController.text.trim();
    final startText = _startController.text.trim();
    final endText = _endController.text.trim();

    if (code.isEmpty || name.isEmpty || startText.isEmpty || endText.isEmpty) {
      Get.snackbar(
        'Validation',
        'Please fill all required fields.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    final startDate = _tryParse(startText);
    final endDate = _tryParse(endText);
    if (startDate == null || endDate == null) {
      Get.snackbar(
        'Validation',
        'Invalid date format.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }
    if (endDate.isBefore(startDate)) {
      Get.snackbar(
        'Validation',
        'End date cannot be earlier than start date.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    final authController = Get.find<AuthController>();
    final userId = authController.userID.value;
    if (userId <= 0) {
      Get.snackbar(
        'Validation',
        'Unable to determine logged-in user.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    _isSaving.value = true;

    try {
      final controller = Get.find<FinancialPeriodController>();
      final payload = <String, dynamic>{
        'periodCode': code,
        'periodName': name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        if (_isEditing) ...{
          'userID': widget.period!.userID,
          'isCurrent': widget.period!.isCurrent,
        } else ...{
          'userID': userId,
          'isCurrent': true,
        },
      };

      if (_isEditing) {
        await controller.updatePeriod(widget.period!.financialPeriodID, payload);
      } else {
        await controller.createPeriod(payload);
      }

      if (mounted) {
        Get.snackbar(
          'Success',
          _isEditing
              ? 'Financial period updated successfully.'
              : 'Financial period created successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
        );
        Get.back();
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
    final title = _isEditing ? 'Edit Financial Period' : 'Add Financial Period';

    return FormPageScaffold(
      title: title,
      subtitle: _isEditing
          ? 'Update the financial period details below.'
          : 'Create a new financial period for the accounting system.',
      isSaving: _isSaving.value,
      onSave: _submit,
      onCancel: () => Get.back(),
      saveLabel: _isEditing ? 'Save Changes' : 'Create',
      footer: const MyfinFooter(),
      children: [
        Text(
          'Period Information',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF3D2C2C),
          ),
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: _codeController,
          label: 'Period Code',
          hint: 'e.g. 2026-09',
          required: true,
          maxLength: 20,
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: _nameController,
          label: 'Period Name',
          hint: 'e.g. September 2026',
          required: true,
          maxLength: 100,
        ),
        const SizedBox(height: 12),
        FormDateField(
          controller: _startController,
          label: 'Start Date',
          required: true,
        ),
        const SizedBox(height: 12),
        FormDateField(
          controller: _endController,
          label: 'End Date',
          required: true,
          firstDate: _tryParse(_startController.text),
        ),
      ],
    );
  }
}
