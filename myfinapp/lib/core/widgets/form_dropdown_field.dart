import 'package:flutter/material.dart';

class FormDropdownField<T> extends StatelessWidget {
  const FormDropdownField({
    super.key,
    this.initialValue,
    required this.items,
    this.label,
    this.required = false,
    this.enabled = true,
    this.hint,
    this.validator,
    this.onChanged,
    this.displayText,
  });

  final T? initialValue;
  final List<DropdownMenuItem<T>> items;
  final String? label;
  final bool required;
  final bool enabled;
  final String? hint;
  final String? Function(T?)? validator;
  final ValueChanged<T?>? onChanged;
  final String? Function(T? item)? displayText;

  @override
  Widget build(BuildContext context) {
    final labelText = label != null && required ? '$label *' : label;

    return DropdownButtonFormField<T>(
      isExpanded: true,
      initialValue: initialValue,
      items: items,
      onChanged: enabled ? onChanged : null,
      style: const TextStyle(color: Color(0xFF222222)),
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF68727D)),
        labelStyle: const TextStyle(color: Color(0xFF68727D)),
        filled: true,
        fillColor: const Color(0xFFF5EBE0),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      validator: validator ??
          (value) {
            if (required && value == null) {
              return '$label is required';
            }
            return null;
          },
    );
  }
}
