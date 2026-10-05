import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../core/widgets/myfin_footer.dart';
import '../../currencies/controllers/currency_controller.dart';
import '../../currencies/models/currency.dart';

class CurrencyFormPage extends StatefulWidget {
  const CurrencyFormPage({super.key, this.currency});

  final Currency? currency;

  @override
  State<CurrencyFormPage> createState() => _CurrencyFormPageState();
}

class _CurrencyFormPageState extends State<CurrencyFormPage> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _symbolController = TextEditingController();
  final _decimalPlacesController = TextEditingController(text: '2');
  final _isBaseCurrency = false.obs;
  final _isSaving = false.obs;

  bool get _isEditing => widget.currency != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final c = widget.currency!;
      _codeController.text = c.currencyCode;
      _nameController.text = c.currencyName;
      _symbolController.text = c.currencySymbol ?? '';
      _decimalPlacesController.text = c.decimalPlaces.toString();
      _isBaseCurrency.value = c.isBaseCurrency;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _symbolController.dispose();
    _decimalPlacesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim().toUpperCase();
    final name = _nameController.text.trim();
    final symbol = _symbolController.text.trim();
    final decimalPlacesText = _decimalPlacesController.text.trim();

    if (code.isEmpty || name.isEmpty) {
      Get.snackbar(
        'Validation',
        'Please fill all required fields.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    if (code.length != 3) {
      Get.snackbar(
        'Validation',
        'Currency Code must be exactly 3 characters.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    final decimalPlaces = int.tryParse(decimalPlacesText) ?? 2;
    if (decimalPlaces < 0 || decimalPlaces > 6) {
      Get.snackbar(
        'Validation',
        'Decimal Places must be between 0 and 6.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    _isSaving.value = true;

    try {
      final controller = Get.find<CurrencyController>();
      final payload = <String, dynamic>{
        'currencyCode': code,
        'currencyName': name,
        'currencySymbol': symbol.isEmpty ? null : symbol,
        'decimalPlaces': decimalPlaces,
        'isBaseCurrency': _isBaseCurrency.value,
      };

      if (_isEditing) {
        await controller.updateCurrency(widget.currency!.currencyID, payload);
      } else {
        await controller.createCurrency(payload);
      }

      if (mounted) {
        Get.snackbar(
          'Success',
          _isEditing
              ? 'Currency updated successfully.'
              : 'Currency created successfully.',
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
    final title = _isEditing ? 'Edit Currency' : 'Add Currency';

    return FormPageScaffold(
      title: title,
      subtitle: _isEditing
          ? 'Update the currency details below.'
          : 'Create a new currency for the system.',
      isSaving: _isSaving.value,
      onSave: _submit,
      onCancel: () => Get.back(),
      saveLabel: _isEditing ? 'Save Changes' : 'Create',
      footer: const MyfinFooter(),
      children: [
        Text(
          'Currency Information',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF3D2C2C),
          ),
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: _codeController,
          label: 'Currency Code',
          hint: 'e.g. KES',
          required: true,
          maxLength: 3,
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: _nameController,
          label: 'Currency Name',
          hint: 'e.g. Kenyan Shilling',
          required: true,
          maxLength: 100,
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: _symbolController,
          label: 'Symbol (optional)',
          hint: 'e.g. KSh',
          required: false,
          maxLength: 10,
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: _decimalPlacesController,
          label: 'Decimal Places',
          hint: 'e.g. 2',
          required: false,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        FormSwitchField(
          value: _isBaseCurrency.value,
          onChanged: (value) => _isBaseCurrency.value = value,
          label: 'Base Currency',
        ),
      ],
    );
  }
}
