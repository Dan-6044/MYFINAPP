import 'package:flutter/material.dart';

class FormDateField extends StatelessWidget {
  const FormDateField({
    super.key,
    required this.controller,
    this.label,
    this.required = false,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
    this.initialDate,
    this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? label;
  final bool required;
  final bool enabled;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final labelText = label != null && required ? '$label *' : label;

    return TextFormField(
      controller: controller,
      enabled: enabled,
      readOnly: true,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: 'YYYY-MM-DD',
        hintStyle: const TextStyle(color: Color(0xFFF4793A)),
        labelStyle: const TextStyle(color: Color(0xFF8C7B7B)),
        suffixIcon: const Icon(Icons.calendar_today_rounded, size: 20),
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
      onTap: enabled
          ? () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: initialDate ??
                    (controller.text.isNotEmpty
                        ? DateTime.tryParse(controller.text) ?? now
                        : now),
                firstDate: firstDate ?? DateTime(now.year - 10),
                lastDate: lastDate ?? DateTime(now.year + 10),
              );
              if (picked != null) {
                final day = picked.day.toString().padLeft(2, '0');
                final month = picked.month.toString().padLeft(2, '0');
                final year = picked.year;
                final formatted = '$year-$month-$day';
                controller.text = formatted;
                onChanged?.call(formatted);
              }
            }
          : null,
    );
  }
}
