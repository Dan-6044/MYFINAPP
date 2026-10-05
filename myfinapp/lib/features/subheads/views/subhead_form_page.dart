import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../core/widgets/myfin_footer.dart';
import '../../main_heads/controllers/main_head_controller.dart';
import '../../main_heads/models/main_head.dart';
import '../../subheads/controllers/subhead_controller.dart';
import '../../subheads/models/subhead.dart';

class SubheadFormPage extends StatefulWidget {
  const SubheadFormPage({super.key, this.subhead});

  final Subhead? subhead;

  @override
  State<SubheadFormPage> createState() => _SubheadFormPageState();
}

class _SubheadFormPageState extends State<SubheadFormPage> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _selectedMainHeadId = 0.obs;
  final _isSaving = false.obs;
  final _mainHeads = <MainHead>[].obs;

  bool get _isEditing => widget.subhead != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final s = widget.subhead!;
      _codeController.text = s.subheadCode.toString();
      _nameController.text = s.subheadName;
      _selectedMainHeadId.value = s.mainHead.mainHeadID;
    }
    _loadMainHeads();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadMainHeads() async {
    try {
      final controller = Get.find<MainHeadController>();
      await controller.loadMainHeads();
      _mainHeads.assignAll(controller.mainHeads.map((e) => e as MainHead).toList());
    } catch (_) {
      // ignore
    }
  }

  Future<void> _submit() async {
    final codeText = _codeController.text.trim();
    final name = _nameController.text.trim();

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
        'Subhead Code must be a positive number.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    if (_selectedMainHeadId.value <= 0) {
      Get.snackbar(
        'Validation',
        'Please select a valid Main Head.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    _isSaving.value = true;

    try {
      final controller = Get.find<SubheadController>();
      final payload = <String, dynamic>{
        'subheadCode': code,
        'subheadName': name,
        'mainHeadID': _selectedMainHeadId.value,
      };

      if (_isEditing) {
        await controller.updateSubhead(widget.subhead!.subheadID, payload);
      } else {
        await controller.createSubhead(payload);
      }

      if (mounted) {
        Get.snackbar(
          'Success',
          _isEditing
              ? 'Subhead updated successfully.'
              : 'Subhead created successfully.',
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
    final title = _isEditing ? 'Edit Subhead' : 'Add Subhead';

    return FormPageScaffold(
      title: title,
      subtitle: _isEditing
          ? 'Update the subhead details below.'
          : 'Create a new subhead under a main head.',
      isSaving: _isSaving.value,
      onSave: _submit,
      onCancel: () => Get.back(),
      saveLabel: _isEditing ? 'Save Changes' : 'Create',
      footer: const MyfinFooter(),
      children: [
        Text(
          'Subhead Information',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF3D2C2C),
          ),
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: _codeController,
          label: 'Subhead Code',
          hint: 'e.g. 1001',
          required: true,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: _nameController,
          label: 'Subhead Name',
          hint: 'e.g. Cash',
          required: true,
          maxLength: 100,
        ),
        const SizedBox(height: 12),
        Obx(
          () {
            final selectedMainHeadId = _selectedMainHeadId.value;
            final hasMainHead = selectedMainHeadId > 0 && _mainHeads.any((mh) => mh.mainHeadID == selectedMainHeadId);
            final effectiveMainHeadValue = hasMainHead ? selectedMainHeadId : null;

            return FormDropdownField<int>(
              initialValue: effectiveMainHeadValue,
              items: _mainHeads
                  .map(
                    (mh) => DropdownMenuItem<int>(
                      value: mh.mainHeadID,
                      child: Text('${mh.mainHeadCode} - ${mh.mainHeadName}'),
                    ),
                  )
                  .toList(),
              label: 'Main Head',
              required: true,
              hint: 'Select a main head',
              onChanged: (value) {
                if (value != null) {
                  _selectedMainHeadId.value = value;
                }
              },
            );
          },
        ),
      ],
    );
  }
}
