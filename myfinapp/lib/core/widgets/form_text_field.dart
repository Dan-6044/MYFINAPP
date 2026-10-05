import 'package:flutter/material.dart';

class FormTextField extends StatelessWidget {
  const FormTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onTap,
    this.suffixIcon,
    this.initialValue,
    this.obscureText = false,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final bool required;
  final bool enabled;
  final bool readOnly;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final String? initialValue;
  final bool obscureText;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final labelText = label != null && required ? '$label *' : label;

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      onTap: onTap,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFF4793A)),
        labelStyle: const TextStyle(color: Color(0xFF8C7B7B)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF5EBE0),
      ),
      style: const TextStyle(color: Color(0xFF222222)),
      validator: validator ??
          (value) {
            if (required && (value == null || value.trim().isEmpty)) {
              return '$label is required';
            }
            return null;
          },
    );
  }
}
