import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../core/widgets/myfin_footer.dart';
import '../../subheads/controllers/subhead_controller.dart';
import '../../subheads/models/subhead.dart';
import '../../currencies/controllers/currency_controller.dart';
import '../../accounts/models/account.dart';
import '../../accounts/controllers/account_controller.dart';

class AccountFormPage extends StatefulWidget {
  const AccountFormPage({super.key, this.account});

  final Account? account;

  @override
  State<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _openingBalanceController = TextEditingController(text: '0');
  final _selectedSubheadId = 0.obs;
  final _selectedCurrencyId = 0.obs;
  final _isControlAccount = false.obs;
  final _allowDirectPosting = true.obs;
  final _isSaving = false.obs;
  final _subheads = <Subhead>[].obs;
  final _currencies = <AccountCurrency>[].obs;

  bool get _isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final a = widget.account!;
      _codeController.text = a.coaCode;
      _nameController.text = a.coaName;
      _descriptionController.text = a.description ?? '';
      _openingBalanceController.text = a.openingBalance.toString();
      _selectedSubheadId.value = a.subhead.subheadID;
      _selectedCurrencyId.value = a.currency?.currencyID ?? 0;
      _isControlAccount.value = a.isControlAccount;
      _allowDirectPosting.value = a.allowDirectPosting;
    }
    _loadReferenceData();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _openingBalanceController.dispose();
    super.dispose();
  }

  Future<void> _loadReferenceData() async {
    try {
      final subheadController = Get.find<SubheadController>();
      await subheadController.loadSubheads();
      _subheads.assignAll(subheadController.subheads.map((e) => e as Subhead).toList());
    } catch (_) {
      // ignore
    }
    try {
      final currencyController = Get.find<CurrencyController>();
      await currencyController.loadCurrencies();
      _currencies.assignAll(
        currencyController.currencies.map(
          (c) => AccountCurrency(
            currencyID: c.currencyID,
            currencyCode: c.currencyCode,
            currencyName: c.currencyName,
            currencySymbol: c.currencySymbol,
            decimalPlaces: c.decimalPlaces,
          ),
        ).toList(),
      );
    } catch (_) {
      // ignore
    }
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final openingBalanceText = _openingBalanceController.text.trim();

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

    if (_selectedSubheadId.value <= 0) {
      Get.snackbar(
        'Validation',
        'Please select a valid Subhead.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    final openingBalance = double.tryParse(openingBalanceText) ?? 0.0;

    _isSaving.value = true;

    try {
      final controller = Get.find<AccountController>();
      final payload = <String, dynamic>{
        'coaCode': code,
        'coaName': name,
        'subheadID': _selectedSubheadId.value,
        'currencyID': _selectedCurrencyId.value > 0 ? _selectedCurrencyId.value : null,
        'description': description.isEmpty ? null : description,
        'isControlAccount': _isControlAccount.value,
        'allowDirectPosting': _allowDirectPosting.value,
        'openingBalance': openingBalance,
      };

      if (_isEditing) {
        await controller.updateAccount(widget.account!.coaID, payload);
      } else {
        await controller.createAccount(payload);
      }

      if (mounted) {
        Get.snackbar(
          'Success',
          _isEditing
              ? 'Account updated successfully.'
              : 'Account created successfully.',
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
    final title = _isEditing ? 'Edit Account' : 'Add Account';

    return FormPageScaffold(
      title: title,
      subtitle: _isEditing
          ? 'Update the account details below.'
          : 'Create a new account in the chart of accounts.',
      isSaving: _isSaving.value,
      onSave: _submit,
      onCancel: () => Get.back(),
      saveLabel: _isEditing ? 'Save Changes' : 'Create',
      footer: const MyfinFooter(),
      children: [
        Text(
          'Account Information',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF3D2C2C),
          ),
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: _codeController,
          label: 'Account Code',
          hint: 'e.g. 1001001',
          required: true,
          maxLength: 30,
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: _nameController,
          label: 'Account Name',
          hint: 'e.g. Cash C/A',
          required: true,
          maxLength: 150,
        ),
        const SizedBox(height: 12),
        Obx(
          () {
            final selectedSubheadId = _selectedSubheadId.value;
            final effectiveSubheadValue = selectedSubheadId > 0 && _subheads.any((s) => s.subheadID == selectedSubheadId)
                ? selectedSubheadId
                : null;

            return FormDropdownField<int>(
              initialValue: effectiveSubheadValue,
              items: _subheads
                  .map(
                    (s) => DropdownMenuItem<int>(
                      value: s.subheadID,
                      child: Text('${s.subheadCode} - ${s.subheadName}'),
                    ),
                  )
                  .toList(),
              label: 'Subhead',
              required: true,
              hint: 'Select a subhead',
              onChanged: (value) {
                if (value != null) {
                  _selectedSubheadId.value = value;
                }
              },
            );
          },
        ),
        const SizedBox(height: 12),
        Obx(
          () {
            final selectedCurrencyId = _selectedCurrencyId.value;
            final hasCurrency = selectedCurrencyId > 0 && _currencies.any((c) => c.currencyID == selectedCurrencyId);
            final effectiveCurrencyValue = hasCurrency ? selectedCurrencyId : null;

            return FormDropdownField<int>(
              initialValue: effectiveCurrencyValue,
              items: [
                const DropdownMenuItem<int>(value: 0, child: Text('None')),
                ..._currencies.map(
                  (c) => DropdownMenuItem<int>(
                    value: c.currencyID,
                    child: Text('${c.currencyCode} - ${c.currencyName}'),
                  ),
                ),
              ],
              label: 'Currency',
              required: false,
              hint: 'Select currency',
              onChanged: (value) {
                if (value != null) {
                  _selectedCurrencyId.value = value;
                }
              },
            );
          },
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
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FormTextField(
                controller: _openingBalanceController,
                label: 'Opening Balance',
                required: false,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FormSwitchField(
                value: _isControlAccount.value,
                onChanged: (value) => _isControlAccount.value = value,
                label: 'Control Account',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FormSwitchField(
          value: _allowDirectPosting.value,
          onChanged: (value) => _allowDirectPosting.value = value,
          label: 'Allow Direct Posting',
        ),
      ],
    );
  }
}
