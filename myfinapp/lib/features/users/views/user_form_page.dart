import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../core/widgets/myfin_footer.dart';
import '../../users/controllers/user_controller.dart';
import '../../users/models/user.dart';

class UserFormPage extends StatefulWidget {
  const UserFormPage({super.key, this.user});

  final User? user;

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _statusController = TextEditingController();
  final _isSaving = false.obs;

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final u = widget.user!;
      _usernameController.text = u.username;
      _firstNameController.text = u.firstName;
      _middleNameController.text = u.middleName ?? '';
      _lastNameController.text = u.lastName ?? '';
      _phoneNumberController.text = u.phoneNumber ?? '';
      _emailController.text = u.email ?? '';
      _statusController.text = u.status;
    } else {
      _statusController.text = 'A';
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final firstName = _firstNameController.text.trim();
    final middleName = _middleNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final status = _statusController.text.trim().toUpperCase();

    if (username.isEmpty || firstName.isEmpty) {
      Get.snackbar(
        'Validation',
        'Username and First Name are required.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    if (!_isEditing && password.isEmpty) {
      Get.snackbar(
        'Validation',
        'Password is required for new users.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    if (!_isEditing && password.isNotEmpty && password.length < 8) {
      Get.snackbar(
        'Validation',
        'Password must be at least 8 characters.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    if (!_isEditing && password.isNotEmpty && password.length > 128) {
      Get.snackbar(
        'Validation',
        'Password must not exceed 128 characters.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    if (status.isNotEmpty && !RegExp(r'^[AaIi]$').hasMatch(status)) {
      Get.snackbar(
        'Validation',
        'Status must be A or I.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE04057),
        colorText: Colors.white,
      );
      return;
    }

    _isSaving.value = true;

    try {
      final controller = Get.find<UserController>();
      final payload = <String, dynamic>{
        'username': username,
        'firstName': firstName,
        'middleName': middleName.isEmpty ? null : middleName,
        'lastName': lastName.isEmpty ? null : lastName,
        'phoneNumber': phoneNumber.isEmpty ? null : phoneNumber,
        'email': email.isEmpty ? null : email,
        if (!_isEditing) 'password': password,
        if (status.isNotEmpty) 'status': status,
      };

      if (_isEditing) {
        await controller.updateUser(widget.user!.userID, payload);
      } else {
        await controller.createUser(payload);
      }

      if (mounted) {
        Get.snackbar(
          'Success',
          _isEditing
              ? 'User updated successfully.'
              : 'User created successfully.',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = _isEditing ? 'Edit User' : 'Add User';

    return FormPageScaffold(
      title: title,
      subtitle: _isEditing
          ? 'Update the user details below.'
          : 'Create a new user account.',
      isSaving: _isSaving.value,
      onSave: _submit,
      onCancel: () => Get.back(),
      saveLabel: _isEditing ? 'Save Changes' : 'Create',
      footer: const MyfinFooter(),
      children: [
        Text(
          'User Information',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF3D2C2C),
          ),
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: _usernameController,
          label: 'Username',
          hint: 'e.g. johndoe',
          required: true,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: _firstNameController,
          label: 'First Name',
          hint: 'e.g. John',
          required: true,
          maxLength: 100,
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: _middleNameController,
          label: 'Middle Name',
          hint: 'Optional',
          required: false,
          maxLength: 100,
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: _lastNameController,
          label: 'Last Name',
          hint: 'e.g. Doe',
          required: false,
          maxLength: 100,
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: _phoneNumberController,
          label: 'Phone Number',
          hint: 'e.g. +254700000000',
          required: false,
          maxLength: 30,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'e.g. john@example.com',
          required: false,
          maxLength: 150,
          keyboardType: TextInputType.emailAddress,
        ),
        if (!_isEditing) ...[
          const SizedBox(height: 12),
          FormTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Min 8 characters',
            required: true,
            obscureText: true,
          ),
        ],
        const SizedBox(height: 12),
        FormDropdownField<String>(
          initialValue: _statusController.text.isEmpty ? null : _statusController.text,
          items: const [
            DropdownMenuItem(value: 'A', child: Text('Active (A)')),
            DropdownMenuItem(value: 'I', child: Text('Inactive (I)')),
          ],
          label: 'Status',
          required: false,
          hint: 'Select status',
          onChanged: (value) {
            if (value != null) {
              _statusController.text = value;
            }
          },
        ),
      ],
    );
  }
}
