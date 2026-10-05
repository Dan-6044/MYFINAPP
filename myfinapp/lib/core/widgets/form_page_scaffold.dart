import 'package:flutter/material.dart';

class FormPageScaffold extends StatelessWidget {
  const FormPageScaffold({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.isSaving = false,
    this.onSave,
    this.onCancel,
    this.saveLabel = 'Save',
    this.showSave = true,
    this.footer,
    this.cancelTextStyle,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool isSaving;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final String saveLabel;
  final bool showSave;
  final Widget? footer;
  final TextStyle? cancelTextStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF3D2C2C)),
          onPressed: onCancel ?? () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF3D2C2C),
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth > 720 ? 640.0 : double.infinity;
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth > 720 ? 24 : 16,
                      vertical: 16,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (subtitle != null && subtitle!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  subtitle!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF8C7B7B),
                                  ),
                                ),
                              ),
                            ...children,
                            const SizedBox(height: 24),
                            if (showSave)
                              Row(
                                children: [
                                   Expanded(
                                     child: OutlinedButton(
                                       onPressed: onCancel ?? () => Navigator.pop(context),
                                       child: Text(
                                         'Cancel',
                                         style: cancelTextStyle,
                                       ),
                                     ),
                                   ),
                                  const SizedBox(width: 12),
                                   Expanded(
                                     child: ElevatedButton(
                                       onPressed: isSaving ? null : onSave,
                                       style: ElevatedButton.styleFrom(
                                         backgroundColor: const Color(0xFFF4793A),
                                         foregroundColor: Colors.white,
                                       ),
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
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (footer != null) footer!,
          ],
        ),
      ),
    );
  }
}
