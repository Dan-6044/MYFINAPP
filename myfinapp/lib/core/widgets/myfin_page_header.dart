import 'package:flutter/material.dart';

class MyfinPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Color? titleColor;

  const MyfinPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: titleColor ?? theme.colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF8C7B7B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
             if (actions != null) ...[
               ...actions!,
             ],
          ],
        ),
      ],
    );
  }
}
