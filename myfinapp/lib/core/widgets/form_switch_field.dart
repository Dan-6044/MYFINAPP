import 'package:flutter/material.dart';

class FormSwitchField extends StatelessWidget {
  const FormSwitchField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveLabel = label ?? '';

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Text(
            effectiveLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF3D2C2C),
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeThumbColor: const Color(0xFFF4793A),
          activeTrackColor: const Color(0xFFFFF7EF),
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFFE0E0E0),
        ),
      ],
    );
  }
}
