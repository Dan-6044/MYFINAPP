import 'package:flutter/material.dart';

class FormActions extends StatelessWidget {
  const FormActions({
    super.key,
    this.isSaving = false,
    this.onSave,
    this.onCancel,
    this.saveLabel = 'Save',
    this.cancelLabel = 'Cancel',
    this.showCancel = true,
  });

  final bool isSaving;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final String saveLabel;
  final String cancelLabel;
  final bool showCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showCancel)
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              child: Text(cancelLabel),
            ),
          ),
        if (showCancel) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: isSaving ? null : onSave,
            child: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(saveLabel),
          ),
        ),
      ],
    );
  }
}
